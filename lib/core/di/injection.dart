import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:erpfarmasimobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:erpfarmasimobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:erpfarmasimobile/core/constants/app_constants.dart';
import 'package:erpfarmasimobile/features/app_mode/presentation/cubit/app_mode_cubit.dart';
import 'package:erpfarmasimobile/features/app_mode/presentation/cubit/branch_context_cubit.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/organization/organization_context_cubit.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/permission/permission_cubit.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/product_model.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/cart_item_model.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/transaction_model.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/inventory_batch_model.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/inventory_movement_model.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/product_conversion_model.dart';
import 'package:erpfarmasimobile/features/pos/data/repositories/pos_product_repository_impl.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/pos_product_repository.dart';
import 'package:erpfarmasimobile/features/pos/data/repositories/inventory_repository_impl.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/inventory_repository.dart';
import 'package:erpfarmasimobile/features/pos/data/repositories/pos_transaction_repository_impl.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/pos_transaction_repository.dart';
import 'package:erpfarmasimobile/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:erpfarmasimobile/features/pos/presentation/cubit/cart/cart_cubit.dart';
import 'package:erpfarmasimobile/features/pos/presentation/cubit/sync/product_sync_cubit.dart';
import 'package:erpfarmasimobile/features/owner/data/repositories/owner_repository_impl.dart';
import 'package:erpfarmasimobile/features/owner/domain/repositories/owner_repository.dart';
import 'package:erpfarmasimobile/features/owner/presentation/bloc/owner/owner_bloc.dart';
import 'package:erpfarmasimobile/features/owner/presentation/bloc/organization/owner_organization_cubit.dart';
import 'package:erpfarmasimobile/features/owner/presentation/bloc/branch/owner_branch_cubit.dart';
import 'package:erpfarmasimobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:erpfarmasimobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:erpfarmasimobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/shift_model.dart';
import 'package:erpfarmasimobile/features/pos/data/repositories/shift_repository_impl.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/shift_repository.dart';
import 'package:erpfarmasimobile/features/pos/presentation/cubit/shift_history/shift_history_cubit.dart';
import 'package:erpfarmasimobile/features/pos/presentation/cubit/transaction_history/transaction_history_cubit.dart';
import 'package:erpfarmasimobile/features/pos/presentation/bloc/shift/shift_bloc.dart';
import 'package:erpfarmasimobile/core/theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  // Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(CartItemModelAdapter());
  Hive.registerAdapter(TransactionItemModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(InventoryBatchModelAdapter());
  Hive.registerAdapter(InventoryMovementModelAdapter());
  Hive.registerAdapter(ProductConversionModelAdapter());
  Hive.registerAdapter(ShiftModelAdapter());

  // Open core boxes (more to be opened in features)
  await Hive.openBox(AppConstants.boxSettings);
  await Hive.openBox(AppConstants.boxAuth);
  await Hive.openBox<ProductModel>(AppConstants.boxProducts);
  await Hive.openBox<CartItemModel>(AppConstants.boxCart);
  await Hive.openBox<TransactionModel>(AppConstants.boxTransactionQueue);
  await Hive.openBox<ShiftModel>(AppConstants.boxShifts);
  await Hive.openBox<InventoryBatchModel>(AppConstants.boxInventoryBatches);
  await Hive.openBox<InventoryMovementModel>(
    AppConstants.boxInventoryMovements,
  );
  await Hive.openBox<ProductConversionModel>(
    AppConstants.boxProductConversions,
  );

  // Supabase (Initialized in main.dart, but client accessible here if needed)
  sl.registerLazySingleton(() => Supabase.instance.client);

  //! Core
  sl.registerLazySingleton(() => ThemeCubit(sl()));

  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  //! Features - POS
  // Repositories
  sl.registerLazySingleton<PosProductRepository>(
    () => PosProductRepositoryImpl(
      sl(),
      Hive.box<ProductModel>(AppConstants.boxProducts),
      Hive.box<InventoryBatchModel>(AppConstants.boxInventoryBatches),
      Hive.box<ProductConversionModel>(AppConstants.boxProductConversions),
    ),
  );
  sl.registerLazySingleton<PosTransactionRepository>(
    () => PosTransactionRepositoryImpl(
      sl(),
      Hive.box<TransactionModel>(AppConstants.boxTransactionQueue),
    ),
  );
  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(
      Hive.box<InventoryBatchModel>(AppConstants.boxInventoryBatches),
      Hive.box<InventoryMovementModel>(AppConstants.boxInventoryMovements),
    ),
  );

  // Bloc / Cubit
  sl.registerFactory(() => PosBloc(sl(), sl(), sl()));
  sl.registerFactory(
    () => CartCubit(Hive.box<CartItemModel>(AppConstants.boxCart)),
  );
  sl.registerFactory(() => ProductSyncCubit(sl()));

  sl.registerLazySingleton<ShiftRepository>(
    () =>
        ShiftRepositoryImpl(Hive.box<ShiftModel>(AppConstants.boxShifts), sl()),
  );
  sl.registerFactory(() => ShiftBloc(sl()));
  sl.registerFactory(() => ShiftHistoryCubit(sl()));
  sl.registerFactory(
    () => TransactionHistoryCubit(
      Hive.box<TransactionModel>(AppConstants.boxTransactionQueue),
    ),
  );

  //! Features - Owner
  sl.registerLazySingleton<OwnerRepository>(() => OwnerRepositoryImpl(sl()));
  sl.registerFactory(() => OwnerBloc(sl()));
  sl.registerFactory(() => OwnerOrganizationCubit(sl()));
  sl.registerFactory(() => OwnerBranchCubit(sl()));

  //! Features - AppMode
  sl.registerFactory(() => AppModeCubit());
  sl.registerFactory(() => BranchContextCubit(sl()));

  //! Features - Organization & Permission
  sl.registerFactory(() => OrganizationContextCubit(sl()));
  sl.registerFactory(() => PermissionCubit(sl()));

  //! Features - Profile
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerFactory(() => ProfileBloc(sl()));
}
