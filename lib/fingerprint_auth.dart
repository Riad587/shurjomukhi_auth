import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

class FingerprintAuth {

final localAuth = LocalAuthentication();
  Future<bool> fingerAuthenticate()async {
     bool isFingerAuthenticated = false;

     try{
       isFingerAuthenticated = await localAuth.authenticate(
        localizedReason: "we need to authenticate you",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
        );

     }
     on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
      
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        
      } else {
   
      }
    }
     catch(e){
        isFingerAuthenticated = false;
        print(e);
     }

    return isFingerAuthenticated;
  }
}