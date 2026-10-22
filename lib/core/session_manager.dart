import 'package:shared_preferences/shared_preferences.dart';
import '../ip.dart' as legacy;

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const String keyUserId = 'user_id';
  static const String keyRole = 'user_role'; // patient, doctor, admin
  static const String keyLang = 'user_lang'; // 1 for Tamil, 2 for English
  static const String keyName = 'user_name';
  static const String keyEmail = 'user_email';
  static const String keyContact = 'user_contact';
  static const String keyAge = 'user_age';
  static const String keyGender = 'user_gender';
  static const String keyQuitTimestamp = 'quit_timestamp';
  static const String keyCigarettesPerDay = 'cigs_per_day';
  static const String keyPricePerPack = 'price_per_pack';
  static const String keyPoints = 'user_points';
  static const String keyMoneySaved = 'money_saved';
  static const String keyThemeMode = 'theme_mode'; // light, dark, system

  Future<void> saveUserSession({
    required String username,
    required String role,
    String? lang,
    String name = '',
    String email = '',
    String contact = '',
    String age = '',
    String gender = '',
    String points = '0',
    String moneySaved = '0',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserId, username);
    await prefs.setString(keyRole, role);

    final existingLang = prefs.getString(keyLang) ?? legacy.lang;
    final targetLang = (lang != null && lang.isNotEmpty)
        ? lang
        : (existingLang.isNotEmpty ? existingLang : '2');
    await prefs.setString(keyLang, targetLang);

    await prefs.setString(keyName, name);
    await prefs.setString(keyEmail, email);
    await prefs.setString(keyContact, contact);
    await prefs.setString(keyAge, age);
    await prefs.setString(keyGender, gender);
    await prefs.setString(keyPoints, points);
    await prefs.setString(keyMoneySaved, moneySaved);

    // Sync legacy ip.dart variables for backward compatibility
    legacy.userid = username;
    legacy.lang = targetLang;
    legacy.user_name = name;
    legacy.user_email = email;
    legacy.user_cont = contact;
    legacy.user_age = age;
    legacy.user_gender = gender;
    legacy.user_pnts = points;
    legacy.user_monsav = moneySaved;
  }

  Future<bool> loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString(keyUserId);
    if (savedUserId != null && savedUserId.isNotEmpty) {
      legacy.userid = savedUserId;
      legacy.lang = prefs.getString(keyLang) ?? (legacy.lang.isNotEmpty ? legacy.lang : '2');
      legacy.user_name = prefs.getString(keyName) ?? '';
      legacy.user_email = prefs.getString(keyEmail) ?? '';
      legacy.user_cont = prefs.getString(keyContact) ?? '';
      legacy.user_age = prefs.getString(keyAge) ?? '';
      legacy.user_gender = prefs.getString(keyGender) ?? '';
      legacy.user_pnts = prefs.getString(keyPoints) ?? '0';
      legacy.user_monsav = prefs.getString(keyMoneySaved) ?? '0';
      return true;
    }
    return false;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    legacy.userid = '';
    legacy.doctid = '';
    legacy.user_name = '';
    legacy.user_pnts = '0';
    legacy.user_monsav = '0';
  }
}
