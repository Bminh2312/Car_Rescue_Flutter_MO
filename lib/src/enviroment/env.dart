import 'package:google_sign_in/google_sign_in.dart';

class Environment {
  static const String API_URL_PLACES_NEW =
      "https://places.googleapis.com/v1/places:searchText";

  static const String API_KEY_MAPS = "AIzaSyAi5WnYjSGtYS_L7nudU2i0d4aFY_3jPVo";

  static const String API_KEY_PREDICTIONS =
      "AIzaSyBZmPE0cCErk-nZtza3mDsXwIKLhS2s8Jg";

  static const String API_KEY_GOONG =
      "uYO7jxleAR8KO17JgxrimjEvKQy0M7EOSc21T9Xr";

  static GoogleSignIn SIGN_IN = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  static const String API_URL = "https://rescuecapstoneapi.azurewebsites.net/";
}
