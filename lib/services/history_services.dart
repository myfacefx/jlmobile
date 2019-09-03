import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/history.dart';

Future<List<History>> getHistories(String token, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/users/$userId/histories";

  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return historyFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<dynamic> setHistories(String token, List<int> listOfHistoryId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/histories/mark";

  print(url);

  http.Response res = await http
      .put(url, headers: header, body: json.encode(listOfHistoryId))
      .timeout(Duration(seconds: getTimeOut()));

  print(res.statusCode);

  if (res.statusCode == 202) {
    return true;
  } else if (res.statusCode == 406) {
    return false;
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<bool> deleteHistory(String token, int historyId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/history/$historyId";

  print(url);

  http.Response res = await http
      .delete(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  print(res.statusCode);

  if (res.statusCode == 204) {
    return true;
  } else if (res.statusCode == 406) {
    return false;
  } else {
    throw Exception(res.body);
  }
}
