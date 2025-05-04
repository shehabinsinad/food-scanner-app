import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  Future<void> addScan(Map<String, dynamic> scanData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList("scanHistory") ?? [];
    history.add(jsonEncode(scanData));
    await prefs.setStringList("scanHistory", history);
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList("scanHistory") ?? [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}
