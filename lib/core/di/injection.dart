import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../constants/app_constants.dart';
import '../../features/app_mode/presentation/cubit/app_mode_cubit.dart';
import '../../features/pos/data/models/hive/product_model.dart';
import '../../features/pos/data/models/hive/transaction_model.dart';
import '../../features/pos/data/repositories/pos_product_repository_impl.dart';
import '../../features/pos/domain/repositories/pos_product_repository.dart';
import '../../features/pos/data/repositories/pos_transaction_repository_impl.dart';
import '../../features/pos/domain/repositories/pos_transaction_repository.dart';

import '../../features/pos/presentation/bloc/pos/pos_bloc.dart';
import '../../features/pos/presentation/cubit/cart/cart_cubit.dart';
import 'package:erpfarmasimobile/features/owner/data/repositories/owner_repository_impl.dart';
import 'package:erpfarmasimobile/features/owner/domain/repositories/owner_repository.dart';
import 'package:erpfarmasimobile/features/owner/presentation/bloc/owner/owner_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  // Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(TransactionItemModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  // Open core boxes (more to be opened in features)
  await Hive.openBox(AppConstants.boxSettings);
  await Hive.openBox(AppConstants.boxAuth);
  await Hive.openBox<ProductModel>(AppConstants.boxProducts);
  await Hive.openBox<TransactionModel>(AppConstants.boxTransactionQueue);

  // Supabase (Initialized in main.dart, but client accessible here if needed)
  sl.registerLazySingleton(() => Supabase.instance.client);

  //! Core
  // NetworkInfo, etc.

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
    ),
  );
  sl.registerLazySingleton<PosTransactionRepository>(
    () => PosTransactionRepositoryImpl(
      sl(),
      Hive.box<TransactionModel>(AppConstants.boxTransactionQueue),
    ),
  );

  // Bloc
  sl.registerFactory(() => PosBloc(sl(), sl()));
  sl.registerFactory(() => CartCubit());

  //! Features - Owner
  sl.registerLazySingleton<OwnerRepository>(() => OwnerRepositoryImpl(sl()));
  sl.registerFactory(() => OwnerBloc(sl()));

  //! Features - AppMode
  sl.registerFactory(() => AppModeCubit());
}
