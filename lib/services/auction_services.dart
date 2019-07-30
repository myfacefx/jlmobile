import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/auction.dart';

Future<bool> create(Map<String, dynamic> _data, int animalId) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/animals/$animalId/auctions/create";

  print(url);

  http.Response res = await http
      .post(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut() + 270));

  if (res.statusCode == 201) {
    return true;
  } else if (res.statusCode == 406) {
    return false;
  } else {
    throw Exception(res.body);
  }
}

Future<bool> setWinner(String token, int auctionId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/auctions/$auctionId/set/winner";

  print(url);

  http.Response res = await http
      .put(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 202) {
    return true;
  } else if (res.statusCode == 406) {
    return false;
  } else {
    throw Exception(res.body);
  }
}

Future<bool> cancelAuction(String token, int auctionId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/auctions/$auctionId/cancel";

  print(url);

  http.Response res = await http
      .put(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 202) {
    return true;
  } else if (res.statusCode == 406) {
    return false;
  } else {
    throw Exception(res.body);
  }
}

Future<bool> startAuction(String token, int auctionId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/auctions/$auctionId/start";

  print(url);

  http.Response res = await http
      .put(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 202) {
    return true;
  } else if (res.statusCode == 406) {
    return false;
  } else {
    throw Exception(res.body);
  }
}

Future<bool> autoClose(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/auctions/autoClose";

  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 202) {
    return true;
  } else if (res.statusCode == 406) {
    return false;
  } else {
    throw Exception(res.body);
  }
}

Future<String> checkFirebaseChatId(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/auctions/checkFirebaseChatId";

  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 202) {
    return res.body;
  } else if (res.statusCode == 406) {
    return "";
  } else {
    throw Exception(res.body);
  }
}

Future<bool> updateFirebaseChatId(String token, Map<String, dynamic> _data, int id) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/auctions/$id/update";

  print(url);
  print(_data);

  http.Response res = await http
      .put(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut() + 270));
      
  if (res.statusCode == 202) {
    return true;
  } else {
    throw Exception(res.body);
  }
}

Future<List<Auction>> getAuctionsWithActiveChat(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  String url = getBaseUrl() + "/auctions/active-chats";

  print(url);

  http.Response res = await http.get(url,
      headers: header);
  if (res.statusCode == 200) {
    return auctionFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}