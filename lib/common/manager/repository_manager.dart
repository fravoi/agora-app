import 'package:agora/common/client/agora_http_client.dart';
import 'package:agora/common/manager/helper_manager.dart';
import 'package:agora/infrastructure/consultation/repository/consultation_repository.dart';
import 'package:agora/infrastructure/consultation/repository/mocks_consultation_repository.dart';
import 'package:agora/infrastructure/demographic/demographic_repository.dart';
import 'package:agora/infrastructure/demographic/mocks_demographic_repository.dart';
import 'package:agora/infrastructure/login/login_repository.dart';
import 'package:agora/infrastructure/login/mocks_login_repository.dart';
import 'package:agora/infrastructure/notification/mocks_notification_repository.dart';
import 'package:agora/infrastructure/notification/notification_repository.dart';
import 'package:agora/infrastructure/qag/mocks_qag_repository.dart';
import 'package:agora/infrastructure/qag/qag_repository.dart';
import 'package:agora/infrastructure/thematique/thematique_repository.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class RepositoryManager {
  static const String _baseUrl = "baseUrl";
  static const String _noAuthenticationHttpClient = "noAuthenticationHttpClient";
  static const String _authenticatedHttpClient = "authenticatedHttpClient";

  static final crashlyticsHelper = HelperManager.getCrashlyticsHelper();

  static void initRepositoryManager({required String baseUrl}) {
    GetIt.instance.registerSingleton(baseUrl, instanceName: _baseUrl);
  }

  static Dio _getDio() {
    if (GetIt.instance.isRegistered<Dio>()) {
      return GetIt.instance.get<Dio>();
    }
    if (!GetIt.instance.isRegistered<String>(instanceName: _baseUrl)) {
      throw Exception("RepositoryManager has not been initialized");
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: GetIt.instance.get<String>(instanceName: _baseUrl),
        connectTimeout: Duration(seconds: 60),
        receiveTimeout: Duration(seconds: 60),
      ),
    );
    final dioLoggerInterceptor = PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    );
    final dioCacheInterceptor = DioCacheInterceptor(
      options: CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.request,
        maxStale: const Duration(days: 14),
      ),
    );
    dio.interceptors
      ..add(dioLoggerInterceptor)
      ..add(dioCacheInterceptor);
    GetIt.instance.registerSingleton(dio);
    return dio;
  }

  static AgoraDioHttpClient getAgoraDioHttpClientWithoutAuthentication() {
    if (GetIt.instance.isRegistered<AgoraDioHttpClient>(instanceName: _noAuthenticationHttpClient)) {
      return GetIt.instance.get<AgoraDioHttpClient>(instanceName: _noAuthenticationHttpClient);
    }
    final agoraDioHttpClient = AgoraDioHttpClient(dio: _getDio());
    GetIt.instance.registerSingleton(agoraDioHttpClient, instanceName: _noAuthenticationHttpClient);
    return agoraDioHttpClient;
  }

  static AgoraDioHttpClient _getAgoraDioHttpClient() {
    if (GetIt.instance.isRegistered<AgoraDioHttpClient>(instanceName: _authenticatedHttpClient)) {
      return GetIt.instance.get<AgoraDioHttpClient>(instanceName: _authenticatedHttpClient);
    }
    final agoraDioHttpClient = AgoraDioHttpClient(
      dio: _getDio(),
      jwtHelper: HelperManager.getJwtHelper(),
    );
    GetIt.instance.registerSingleton(agoraDioHttpClient, instanceName: _authenticatedHttpClient);
    return agoraDioHttpClient;
  }

  static ThematiqueRepository getThematiqueRepository() {
    if (GetIt.instance.isRegistered<ThematiqueDioRepository>()) {
      return GetIt.instance.get<ThematiqueDioRepository>();
    }
    final repository = ThematiqueDioRepository(
      httpClient: _getAgoraDioHttpClient(),
      crashlyticsHelper: crashlyticsHelper,
    );
    GetIt.instance.registerSingleton(repository);
    return repository;
  }

  static ConsultationRepository getConsultationRepository() {
    if (GetIt.instance.isRegistered<MockConsultationRepository>()) {
      return GetIt.instance.get<MockConsultationRepository>();
    }
    final repository = MockConsultationRepository(
      httpClient: _getAgoraDioHttpClient(),
      crashlyticsHelper: crashlyticsHelper,
    );
    GetIt.instance.registerSingleton(repository);
    return repository;
  }

  static QagRepository getQagRepository() {
    if (GetIt.instance.isRegistered<MockQagRepository>()) {
      return GetIt.instance.get<MockQagRepository>();
    }
    final repository = MockQagRepository(
      httpClient: _getAgoraDioHttpClient(),
      crashlyticsHelper: crashlyticsHelper,
    );
    GetIt.instance.registerSingleton(repository);
    return repository;
  }

  static LoginRepository getLoginRepository() {
    if (GetIt.instance.isRegistered<MockLoginRepository>()) {
      return GetIt.instance.get<MockLoginRepository>();
    }
    final repository = MockLoginRepository(
      httpClient: getAgoraDioHttpClientWithoutAuthentication(),
      crashlyticsHelper: crashlyticsHelper,
    );
    GetIt.instance.registerSingleton(repository);
    return repository;
  }

  static DemographicRepository getDemographicRepository() {
    if (GetIt.instance.isRegistered<MockDemographicRepository>()) {
      return GetIt.instance.get<MockDemographicRepository>();
    }
    final repository = MockDemographicRepository(
      httpClient: _getAgoraDioHttpClient(),
      crashlyticsHelper: crashlyticsHelper,
    );
    GetIt.instance.registerSingleton(repository);
    return repository;
  }

  static NotificationRepository getNotificationRepository() {
    if (GetIt.instance.isRegistered<MockNotificationRepository>()) {
      return GetIt.instance.get<MockNotificationRepository>();
    }
    final repository = MockNotificationRepository(
      httpClient: _getAgoraDioHttpClient(),
      crashlyticsHelper: crashlyticsHelper,
    );
    GetIt.instance.registerSingleton(repository);
    return repository;
  }
}
