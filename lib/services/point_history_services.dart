import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/point_history.dart';

Future<List<PointHistory>> getPointHistories(String token, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/users/$userId/point-histories";

  debugPrint(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return pointHistoryFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}