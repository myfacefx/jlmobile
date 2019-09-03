import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;

Future<int> createProduct(
    Map<String, dynamic> _data, int animalId, String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/animals/$animalId/products/create";

  print(url);

  http.Response res = await http
      .post(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut() + 270));

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

Future<int> sold(String token, int productId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/sold/products/$productId";

  print(url);

  http.Response res = await http
      .put(url, headers: header)
      .timeout(Duration(seconds: getTimeOut() + 270));

  if (res.statusCode == 202) {
    return 1;
  } else if (res.statusCode == 406) {
    return 2;
  } else if (res.statusCode == 444) {
    return 3;
  } else {
    throw Exception(res.body);
  }
}

Future<int> deleteProduct(String token, int productId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/products/$productId";

  print(url);

  http.Response res = await http.delete(url, headers: header);
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

Future<int> updateProduct(
    String token, Map<String, dynamic> _data, int id) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/products/$id";

  print(url);

  http.Response res = await http
      .put(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut() + 270));

  if (res.statusCode == 202) {
    return 1;
  } else if (res.statusCode == 444) {
    return 2;
  } else {
    throw Exception(res.body);
  }
}
