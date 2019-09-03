import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/product_comment.dart';

Future<int> addCommentProduct(String token, ProductComment _data) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/product-comment";

  print(url);

  http.Response res = await http
      .post(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 201) {
    return 1;
  } else if (res.statusCode == 444) {
    return null;
  } else if (res.statusCode == 406) {
    return 2;
  } else if (res.statusCode == 407) {
    return 3;
  } else if (res.statusCode == 408) {
    return 4;
  } else {
    throw Exception(res.body);
  }
}
