import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/auction_comment.dart';

Future<int> addCommentAuction(String token, AuctionComment _data) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  http.Response res = await http
      .post(getBaseUrl() + "/auction-comment",
          headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 201) {
    return 1;
  } else if (res.statusCode == 406) {
    return 2;
  } else if (res.statusCode == 407) {
    return 3;
  } else if (res.statusCode == 408) {
    return 4;
  } else if (res.statusCode == 444) {
    return 5;
  } else if (res.statusCode == 409) {
    return 6;
  } else {
    throw Exception(res.body);
  }
}
