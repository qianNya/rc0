import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/tokens.dart';

const String _tokenKey = 'tokens';

Future<bool> setTokens(Tokens tokens) async {
  final sp = await SharedPreferences.getInstance();
  return sp.setString(_tokenKey, jsonEncode(tokens.toJson()));
}

Future<bool> removeTokens() async {
  final sp = await SharedPreferences.getInstance();
  return sp.remove(_tokenKey);
}

Future<Tokens?> getTokens() async {
  try {
    final sp = await SharedPreferences.getInstance();
    final str = sp.getString(_tokenKey);
    if (str == null || str.isEmpty) {
      return null;
    }
    return Tokens.fromJson(jsonDecode(str) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}
