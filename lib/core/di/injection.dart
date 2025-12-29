import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../constants/app_constants.dart';
import '../../features/app_mode/presentation/cubit/app_mode_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  // Hive
  await Hive.initFlutter();
  // Open core boxes (more to be opened in features)
  await Hive.openBox(AppConstants.boxSettings);
  await Hive.openBox(AppConstants.boxAuth);

  // Supabase (Initialized in main.dart, but client accessible here if needed)
  sl.registerLazySingleton(() => Supabase.instance.client);

  //! Core
  // NetworkInfo, etc.

  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Data Sources (Supabase Client already registered as SupabaseClient)

  //! Features - AppMode
  sl.registerFactory(() => AppModeCubit());
}
