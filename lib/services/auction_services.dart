import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/auction.dart';
import 'package:jlf_mobile/models/chat_list_pagination.dart';

Future<int> createAuction(
    Map<String, dynamic> _data, int animalId, String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/animals/$animalId/auctions/create";

  print(url);

  http.Response res = await http
      .post(url, headers: header, body: json.encode(_data))
      .timeout(Duration(minutes: 10));

  if (res.statusCode == 201) {
    return 1;
  } else if (res.statusCode == 406) {
    return 2;
  } else if (res.statusCode == 444) {
    return 3;
  } else {
    throw Exception(res.body);
  }
}

Future<dynamic> cancelAuction(String token, int auctionId) async {
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
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

// Future<bool> startAuction(String token, int auctionId) async {
//   final header = {"Content-Type": "application/json", "Authorization": token};
//   final url = getBaseUrl() + "/auctions/$auctionId/start";

//   print(url);

//   http.Response res = await http
//       .put(url, headers: header)
//       .timeout(Duration(seconds: getTimeOut()));

//   if (res.statusCode == 202) {
//     return true;
//   } else if (res.statusCode == 406) {
//     return false;
//   } else {
//     throw Exception(res.body);
//   }
// }

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
  } else if (res.statusCode == 444) {
    return false;
  } else {
    throw Exception(res.body);
  }
}

// Future<String> checkFirebaseChatId(String token) async {
//   final header = {"Content-Type": "application/json", "Authorization": token};
//   final url = getBaseUrl() + "/auctions/checkFirebaseChatId";

//   print(url);

//   http.Response res = await http
//       .get(url, headers: header)
//       .timeout(Duration(seconds: getTimeOut()));

//   if (res.statusCode == 202) {
//     return res.body;
//   } else if (res.statusCode == 406) {
//     return "";
//   } else {
//     throw Exception(res.body);
//   }
// }

Future<dynamic> updateFirebaseChatId(
    String token, Map<String, dynamic> _data, int id) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/auctions/$id/set-chat-room";

  print(url);

  http.Response res = await http
      .put(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut() + 270));

  if (res.statusCode == 202) {
    return true;
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<int> deleteAuction(String token, int id) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/auctions/$id";

  print(url);

  http.Response res = await http
      .delete(url, headers: header)
      .timeout(Duration(seconds: getTimeOut() + 270));

  if (res.statusCode == 204) {
    return 1;
  } else if (res.statusCode == 406) {
    return 2;
  } else if (res.statusCode == 444) {
    return 3;
  } else {
    throw Exception(res.body);
  }
}

Future<String> getFirebaseChatId(String token, int auctionId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/auctions/$auctionId/get-chat-room";

  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut() + 270));

  if (res.statusCode == 200) {
    return res.body;
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<ChatListPagination> getAuctionsWithActiveChat(
    String token, int userId, bool isAdmin, int page, String search) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  String url = getBaseUrl();

  if (isAdmin)
    url += "/auctions/active-chats-admin?page=$page";
  else
    url += "/users/" + userId.toString() + "/auctions/chats?page=$page";

  if (search != null && search.length > 0) url += "&search=$search";

  print(url);

  http.Response res = await http.get(url, headers: header);

  if (res.statusCode == 200) {
    return chatListPaginationFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<Auction>> getAuctionsWithActiveChatNoPaginate(
    String token, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  String url = getBaseUrl();

  url += "/users/$userId/auctions/chats/no-paginate";

  print(url);

  http.Response res = await http.get(url, headers: header);

  if (res.statusCode == 200) {
    return auctionFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<int> editDescAuction(String token, var data, int animalId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  String url = getBaseUrl() + "/animals/$animalId/auctions/update";

  print(url);
  print(json.encode(data));

  http.Response res =
      await http.put(url, headers: header, body: json.encode(data));

  if (res.statusCode == 202) {
    return 1;
  } else if (res.statusCode == 444) {
    return 2;
  } else {
    throw Exception(res.body);
  }
}
