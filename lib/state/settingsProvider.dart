import 'dart:convert';

import 'package:e9pass_cs/models/appSettings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings appSettings;

  Future<AppSettings> getSettings(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      appSettings = AppSettings.fromJson(jsonDecode(prefs.getString(key)));
    } catch (Excepetion) {
      appSettings = null;
    }
    notifyListeners();
    return appSettings;
  }

  Future<bool> setSettings(String key, AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(key, json.encode(settings));
      return true;
    } catch (Excepetion) {
      return false;
    }
  }
}
