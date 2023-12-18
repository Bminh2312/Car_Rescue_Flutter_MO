import 'package:google_sign_in/google_sign_in.dart';

class Environment {
  static const String API_URL_PLACES_NEW =
      "https://places.googleapis.com/v1/places:searchText";

  static const String API_KEY_MAPS = "AIzaSyChI9DuNbyJd4I5Od1hBrs9n3VB-EYEh2E";

  static const String API_KEY_PREDICTIONS =
      "AIzaSyBZmPE0cCErk-nZtza3mDsXwIKLhS2s8Jg";

  static GoogleSignIn SIGN_IN = GoogleSignIn(
    scopes: <String>[
      'email',
      // 'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  static const String API_URL = "https://rescuecapstoneapi.azurewebsites.net/";
}
