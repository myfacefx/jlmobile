import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<User> login(Map<String, dynamic> _data) async {
  final header = {"Content-Type": "application/json"};
  http.Response res = await http.post(getBaseUrl() + "/login",
      headers: header, body: json.encode(_data));
  if (res.statusCode == 200) {
    return userFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<bool> logout(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  http.Response res = await http.get(getBaseUrl() + "/logout", headers: header);
  if (res.statusCode == 202) {
    return true;
  } else {
    throw Exception(res.body);
  }
}

Future<User> changePassword(String token, Map<String, dynamic> input) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  http.Response res = await http.put(getBaseUrl() + "/users",
      headers: header, body: json.encode(input));
  if (res.statusCode == 200) {
    return userFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

/**
 * User data access from/to local storage
 */
/// Save Key-Value Pair to local storage
saveLocalData(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

/// Return Value using Key from local storage
Future<String> readLocalData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  String a = prefs.getString(key);
  return a;
}

/// Remove Key-Value Pair from local storage
deleteLocalData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

Future<List<User>> getBlacklistedUser() async {
  final header = {"Content-Type": "application/json"};
  
  http.Response res = await http.get(getBaseUrl() + "/blacklists",
      headers: header).timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return listUserFromJson(res.body);
  } else {
    throw Exception(res.body);
  }

  // try {
  //   http.Response res = await http.get(getBaseUrl() + "/blacklists",
  //       headers: header).timeout(const Duration(seconds: 10));
  //   if (res.statusCode == 200) {
  //     return listUserFromJson(res.body);
  //   } else {
  //     throw Exception(res.body);
  //   }
  // } on TimeoutException catch (_) {
  //   throw Exception(TimeoutException("Time out bruh"));
  //   // throw Exception("Timeout Bruh");
  // } on SocketException catch (_) {
  //   print("ERROR #2");
  //   throw Exception("Socket exception");
  // }
}