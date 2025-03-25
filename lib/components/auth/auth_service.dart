import 'dart:typed_data';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

import '../../packages/headerfiles.dart';

class AuthServices {
  final LocalAuthentication localAuth = LocalAuthentication();

  Future<bool> authenticateLocally() async {
    bool isAuthenticated = false;
    try {
      bool canAuthenticate = await localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        print('Biometrics not available');
        return false;
      }

      isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Please authenticate before using the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Authentication error: $e');
      if (e.code == auth_error.notEnrolled) {
        print('No biometrics enrolled');
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        print('Biometrics are locked out');
      }
    } catch (e) {
      print('Error: $e');
    }
    return isAuthenticated;
  }

  Future<Uint8List?> getFingerprintBytes() async {
    return Uint8List.fromList([1, 2, 3, 4, 5]);
  }
}
