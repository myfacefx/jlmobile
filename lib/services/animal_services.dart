import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/animal.dart';

Future<List<Animal>> getAnimalByCategory(
    String token, int animalCategoryId) async {
  final header = {"Content-Type": "application/json"};
  print(getBaseUrl() + "/animals?animal_category_id=$animalCategoryId");
  http.Response res = await http.get(
      getBaseUrl() + "/animals?animal_category_id=$animalCategoryId",
      headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getAnimalBySubCategory(
    String token, int animalSubCategoryId) async {
  final header = {"Content-Type": "application/json"};
  print(getBaseUrl() + "/animals?animal_sub_category_id=$animalSubCategoryId");
  http.Response res = await http.get(
      getBaseUrl() + "/animals?animal_sub_category_id=$animalSubCategoryId",
      headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}
