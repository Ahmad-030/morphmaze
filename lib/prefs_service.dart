import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyHighScore = 'high_score';
  static const _keyLastLevel = 'last_level';
  static const _keySound = 'sound_enabled';
  static const _keyScoreHistory = 'score_history';

  static Future<int> getHighScore() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_keyHighScore) ?? 0;
  }

  static Future<void> saveHighScore(int score) async {
    final p = await SharedPreferences.getInstance();
    final current = p.getInt(_keyHighScore) ?? 0;
    if (score > current) await p.setInt(_keyHighScore, score);
  }

  static Future<void> addScoreHistory(int score) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_keyScoreHistory) ?? [];
    list.insert(0, score.toString());
    if (list.length > 10) list.removeLast();
    await p.setStringList(_keyScoreHistory, list);
  }

  static Future<List<int>> getScoreHistory() async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_keyScoreHistory) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).toList();
  }

  static Future<void> resetHighScore() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyHighScore);
    await p.remove(_keyScoreHistory);
  }

  static Future<int> getLastLevel() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_keyLastLevel) ?? 1;
  }

  static Future<void> saveLastLevel(int level) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_keyLastLevel, level);
  }

  static Future<bool> getSoundEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_keySound) ?? true;
  }

  static Future<void> setSoundEnabled(bool val) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keySound, val);
  }
}