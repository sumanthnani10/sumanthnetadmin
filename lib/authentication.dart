import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';


class LocalAuthenticationService {
  final _auth = LocalAuthentication();
  bool _isProtectionEnabled = true;

  bool get isProtectionEnabled => _isProtectionEnabled;

  set isProtectionEnabled(bool enabled) => _isProtectionEnabled = enabled;

  bool isAuthenticated = false;

  Future<bool> get canAuthenticate async => await _auth.canCheckBiometrics;

  Future<bool> authenticate() async {
    if (_isProtectionEnabled) {
      try {
        isAuthenticated = await _auth.authenticate(
          localizedReason: 'Login',
          options: AuthenticationOptions(biometricOnly: false, stickyAuth: true, useErrorDialogs: true, sensitiveTransaction: false),
        );
        return isAuthenticated;
      } on PlatformException catch (e) {
        print(e);
        return false;
      }
    }
  }
}

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => LocalAuthenticationService());
}