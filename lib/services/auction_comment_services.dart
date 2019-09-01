import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/auction_comment.dart';

Future<String> addCommentAuction(String token, AuctionComment _data) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  http.Response res = await http
      .post(getBaseUrl() + "/auction-comment",
          headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 201) {
    return "";
  } else if (res.statusCode == 407) {
    return res.body;
  } else {
    throw Exception(res.body);
  }
}
