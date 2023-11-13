import 'package:CarRescue/src/enviroment/env.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GmailProvider {

  final GoogleSignIn _googleSignIn = Environment.SIGN_IN;

  Future<String?> handleSignIn() async {
    try {
        GoogleSignInAccount? user = await _googleSignIn.signIn();

        if (user != null) {
            GoogleSignInAuthentication? googleSignInAuthentication =
                await user.authentication;
                print("Token: "+ googleSignInAuthentication.accessToken!);
            return googleSignInAuthentication.accessToken;
        } else {
            return null;
        }
    } catch (error) {
        return error.toString();
    }
}

  Future<void> handleSignOut() => _googleSignIn.disconnect();

  
}
