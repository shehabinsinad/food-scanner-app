import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  /// Save user data keyed by the current user's UID.
  Future<void> saveUserData(String height, String weight, String allergies, String conditions) async {
    final prefs = await SharedPreferences.getInstance();
    // Use the current user's UID as part of the key.
    String userKey = FirebaseAuth.instance.currentUser?.uid ?? 'default';
    
    await prefs.setString('${userKey}_height', height);
    await prefs.setString('${userKey}_weight', weight);
    await prefs.setString('${userKey}_allergies', allergies);
    await prefs.setString('${userKey}_conditions', conditions);
  }

  /// Retrieve user data for the current user.
  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = FirebaseAuth.instance.currentUser?.uid ?? 'default';
    return {
      'height': prefs.getString('${userKey}_height') ?? '',
      'weight': prefs.getString('${userKey}_weight') ?? '',
      'allergies': prefs.getString('${userKey}_allergies') ?? '',
      'conditions': prefs.getString('${userKey}_conditions') ?? '',
    };
  }
}
