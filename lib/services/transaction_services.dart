import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/transaction.dart';

Future<Transaction> getOrGenerateAuctionTransaction(int auctionId, String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/auctions/$auctionId/transactions";
  
  debugPrint(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return transactionFromJson(res.body);
  } else if (res.statusCode == 201) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<Transaction> get(int transactionId, String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/transactions/$transactionId";
  
  debugPrint(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return transactionFromJson(res.body);
  } else if (res.statusCode == 201) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<String> update(int transactionId, Map<String, dynamic> _data, String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/transactions/$transactionId";
  
  debugPrint(url);

  http.Response res = await http
      .put(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 202) {
    return json.decode(res.body)['content'];
  } else {
    throw Exception(res.body);
  }
}