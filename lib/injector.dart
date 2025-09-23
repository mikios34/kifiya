import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:kifiya/core/constants/app_constants.dart';
import 'package:kifiya/dio_interceptor.dart';
import 'package:kifiya/features/auth/data/api_service/auth_api_service.dart';
import 'package:kifiya/features/auth/data/repository/auth_repository.dart';
import 'package:kifiya/features/auth/presentation/bloc/bloc.dart';

final locator = GetIt.instance;

void setupLocator() {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  dio.interceptors.add(DioInterceptor());
  locator.registerSingleton<Dio>(dio);

  locator.registerSingleton<AuthApiService>(AuthApiService(locator<Dio>()));

  locator.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(locator<AuthApiService>()),
  );
}
