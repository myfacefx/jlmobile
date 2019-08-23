import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/bid.dart';

Future<int> placeBid(String token, Bid _data) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  print(json.encode(_data));
  http.Response res = await http
      .post(getBaseUrl() + "/bids", headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 201) {
    return 1;
  } else if (res.statusCode == 406) {
    return 2;
  } else if (res.statusCode == 407) {
    return 3;
  } else {
    throw Exception(res.body);
  }
}
