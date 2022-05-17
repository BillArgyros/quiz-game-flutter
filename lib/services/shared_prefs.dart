import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsServices {

  Future<void> saveNamedPreference(Map obj, key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String rawJson = jsonEncode(obj);
    prefs.setString(key, rawJson);
  }

  Future<Map> getNamedPreference(keys) async {
    Map category = {};
    String key = keys;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.remove(keys);
    String? rawJSON = prefs.getString(key);
    if (rawJSON == null) {
      return category;
    } else {
      Map category = jsonDecode(rawJSON);
      return category;
    }
  }

}