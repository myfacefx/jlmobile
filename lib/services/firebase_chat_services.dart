import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';

Future<int> update(String token, Map<String, dynamic> _data) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/firebase-chats/update";

  debugPrint(url);

  http.Response res =
      await http.put(url, headers: header, body: json.encode(_data));

  if (res.statusCode == 202) {
    return 1;
  } else if (res.statusCode == 406) {
    return 2;
  } else if (res.statusCode == 407) {
    return 3;
  } else if (res.statusCode == 408) {
    return 4;
  } else if (res.statusCode == 444) {
    return 5;
  } else if (res.statusCode == 409) {
    return 6;
  } else {
    throw Exception(res.body);
  }
}

Future<int> resetUnreadCount(String token, Map<String, dynamic> _data) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/firebase-chats/reset";

  debugPrint(url);

  http.Response res =
      await http.put(url, headers: header, body: json.encode(_data));

  if (res.statusCode == 202) {
    return 1;
  } else if (res.statusCode == 406) {
    return 2;
  } else if (res.statusCode == 407) {
    return 3;
  } else if (res.statusCode == 408) {
    return 4;
  } else if (res.statusCode == 444) {
    return 5;
  } else if (res.statusCode == 409) {
    return 6;
  } else {
    throw Exception(res.body);
  }
}

Future<int> getUnreadChatsCount(int userId, String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/users/$userId/firebase-chats/count";

  debugPrint(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return int.parse(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}