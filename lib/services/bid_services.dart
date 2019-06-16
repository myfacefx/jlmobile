import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
// import 'package:jlf_mobile/models/bid.dart';

Future<String> placeBid(Map<String, dynamic> _data) async {
  final header = {"Content-Type": "application/json"};
  http.Response res = await http.post(getBaseUrl() + "/bids",
      headers: header, body: json.encode(_data)).timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return res.body;
    // return userFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}