import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:kifiya/core/constants/app_constants.dart';
import 'package:kifiya/core/services/token_storage_service.dart';
import 'package:kifiya/dio_interceptor.dart';
import 'package:kifiya/features/auth/data/api_service/auth_api_service.dart';
import 'package:kifiya/features/auth/data/repository/auth_repository.dart';
import 'package:kifiya/features/account/data/api_service/account_api_service.dart';
import 'package:kifiya/features/account/data/repository/account_repository.dart';
import 'package:kifiya/features/account/presentation/bloc/bloc.dart';
import 'package:kifiya/features/transfer/data/api_service/transfer_api_service.dart';
import 'package:kifiya/features/transfer/data/repository/transfer_repository.dart';
import 'package:kifiya/features/transfer/presentation/bloc/bloc.dart';
import 'package:kifiya/features/transaction/data/api_service/transaction_api_service.dart';
import 'package:kifiya/features/transaction/data/repository/transaction_repository.dart';
import 'package:kifiya/features/transaction/presentation/bloc/bloc.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Register secure storage
  locator.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Register token storage service
  locator.registerLazySingleton<TokenStorageService>(
    () => TokenStorageService(locator<FlutterSecureStorage>()),
  );

  // Register Dio with interceptor
  final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  locator.registerSingleton<Dio>(dio);

  // Add interceptor after dio is registered
  dio.interceptors.add(DioInterceptor(locator<TokenStorageService>(), dio));

  // Register API services
  locator.registerLazySingleton<AuthApiService>(
    () => AuthApiService(locator<Dio>()),
  );

  locator.registerLazySingleton<AccountApiService>(
    () => AccountApiService(locator<Dio>()),
  );

  locator.registerLazySingleton<TransferApiService>(
    () => TransferApiService(locator<Dio>()),
  );

  locator.registerLazySingleton<TransactionApiService>(
    () => TransactionApiService(locator<Dio>()),
  );

  // Register repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(locator<AuthApiService>()),
  );

  locator.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(locator<AccountApiService>()),
  );

  locator.registerLazySingleton<TransferRepository>(
    () => TransferRepositoryImpl(locator<TransferApiService>()),
  );

  locator.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(locator<TransactionApiService>()),
  );

  // Register BLoCs
  locator.registerFactory<AccountBloc>(
    () => AccountBloc(locator<AccountRepository>()),
  );

  locator.registerFactory<TransferBloc>(
    () => TransferBloc(locator<TransferRepository>()),
  );

  locator.registerFactory<TransactionBloc>(
    () => TransactionBloc(locator<TransactionRepository>()),
  );
}
