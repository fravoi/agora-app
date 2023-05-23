import 'package:agora/bloc/login/login_event.dart';
import 'package:agora/bloc/login/login_state.dart';
import 'package:agora/common/helper/device_info_helper.dart';
import 'package:agora/common/helper/jwt_helper.dart';
import 'package:agora/infrastructure/login/login_repository.dart';
import 'package:agora/infrastructure/login/login_storage_client.dart';
import 'package:agora/push_notification/push_notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository repository;
  final LoginStorageClient loginStorageClient;
  final DeviceInfoHelper deviceInfoHelper;
  final PushNotificationService pushNotificationService;
  final JwtHelper jwtHelper;

  LoginBloc({
    required this.repository,
    required this.loginStorageClient,
    required this.deviceInfoHelper,
    required this.pushNotificationService,
    required this.jwtHelper,
  }) : super(LoginInitialLoadingState()) {
    on<CheckLoginEvent>(_handleCheckLoginEvent);
  }

  Future<void> _handleCheckLoginEvent(CheckLoginEvent event, Emitter<LoginState> emit) async {
    final fcmToken = await pushNotificationService.getMessagingToken();

    final loginToken = await loginStorageClient.getLoginToken();
    if (loginToken != null) {
      emit(await _login(loginToken: loginToken, fcmToken: fcmToken));
    } else {
      emit(await _signup(fcmToken: fcmToken));
    }
  }

  Future<LoginState> _login({required String loginToken, required String fcmToken}) async {
    final deviceId = await deviceInfoHelper.getDeviceId();
    if (deviceId == null) {
      return LoginErrorState();
    }

    final response = await repository.login(
      deviceId: deviceId,
      firebaseMessagingToken: fcmToken,
      loginToken: loginToken,
    );
    if (response is LoginSucceedResponse) {
      jwtHelper.setJwtToken(response.jwtToken);
      return LoginSuccessState();
    } else {
      return LoginErrorState();
    }
  }

  Future<LoginState> _signup({required String fcmToken}) async {
    final deviceId = await deviceInfoHelper.getDeviceId();
    if (deviceId == null) {
      return LoginErrorState();
    }

    final response = await repository.signup(deviceId: deviceId, firebaseMessagingToken: fcmToken);
    if (response is SignupSucceedResponse) {
      loginStorageClient.save(response.loginToken);
      jwtHelper.setJwtToken(response.jwtToken);
      return LoginSuccessState();
    } else {
      return LoginErrorState();
    }
  }
}