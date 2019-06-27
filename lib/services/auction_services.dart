import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/auction.dart';

Future<Auction> create(Map<String, dynamic> _data) async {
  final header = {"Content-Type": "application/json"};
  http.Response res = await http
      .post(getBaseUrl() + "/auctions",
          headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return Auction.fromJson(json.decode(res.body));
  } else {
    throw Exception(res.body);
  }
}

Future<bool> setWinner(String token, int auctionId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  http.Response res = await http
      .put(getBaseUrl() + "/auctions/$auctionId/set/winner", headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 202) {
    return true;
  } else if (res.statusCode == 406) {
    return false;
  } else {
    throw Exception(res.body);
  }
}
