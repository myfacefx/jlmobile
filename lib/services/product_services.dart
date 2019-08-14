import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;

Future<bool> create(Map<String, dynamic> _data, int animalId) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/animals/$animalId/products/create";

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

Future<bool> sold(String token, int productId) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/sold/products/$productId";

  print(url);

  http.Response res = await http
      .put(url, headers: header)
      .timeout(Duration(seconds: getTimeOut() + 270));

  if (res.statusCode == 202) {
    return true;
  } else if (res.statusCode == 406) {
    return false;
  } else {
    throw Exception(res.body);
  }
}
