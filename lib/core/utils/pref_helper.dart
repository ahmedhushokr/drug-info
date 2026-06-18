import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
   static const String tocenKey = 'auth_tocen';

   static Future<void> saveToken(String token)async{
    final prefs =await SharedPreferences.getInstance();
    await prefs.setString(tocenKey, token);

   }

   static Future<String?> getToken()async{
    final prefs =await SharedPreferences.getInstance();
    return prefs.getString(tocenKey);

   }

   static Future<void> clearToken()async{
    final prefs =await SharedPreferences.getInstance();
     prefs.remove(tocenKey);

   }
}
