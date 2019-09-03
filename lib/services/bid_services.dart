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

  } else if (res.statusCode == 444) {
    return null;

  } else if (res.statusCode == 408) {
    return 4;

  } else {
    throw Exception(res.body);
  }
}

Future<bool> delete(String token, int bidId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/bids/$bidId";

  print(url);

  http.Response res = await http
      .delete(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  // var response = json.decode(res.body);

  // return response;
  if (res.statusCode == 204) {
    return true;
  } else if (res.statusCode == 406) {
    return false;
  } else {
    throw Exception(res.body);
  }
}