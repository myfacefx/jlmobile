import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/product_comment.dart';

Future<String> addCommentProduct(String token, ProductComment _data) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/product-comment";

  print(url);

  http.Response res = await http
      .post(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 201) {
    return "";
  } else if (res.statusCode == 407) {
    return res.body;
  } else {
    throw Exception(res.body);
  }
}
