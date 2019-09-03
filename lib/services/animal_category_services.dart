import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/animal_category.dart';

Future<List<AnimalCategory>> getAnimalCategory(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  print(getBaseUrl() + "/animal-categories/animal");

  http.Response res = await http.get(getBaseUrl() + "/animal-categories/animal",
      headers: header);
  if (res.statusCode == 200) {
    return animalCategoryFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<AnimalCategory>> getAnimalCategoryWithoutCount(
    String token, String type) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  print(getBaseUrl() + "/type/$type/animal-categories");
  http.Response res = await http
      .get(getBaseUrl() + "/type/$type/animal-categories", headers: header);
  if (res.statusCode == 200) {
    return animalCategoryFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<AnimalCategory>> getAccessoryAnimalCategory(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  print(getBaseUrl() + "/animal-categories/accessory");
  http.Response res = await http
      .get(getBaseUrl() + "/animal-categories/accessory", headers: header);
  if (res.statusCode == 200) {
    return animalCategoryFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<AnimalCategory>> getProductAnimalCategory(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  print(getBaseUrl() + "/animal-categories/product");
  http.Response res = await http
      .get(getBaseUrl() + "/animal-categories/product", headers: header);
  if (res.statusCode == 200) {
    return animalCategoryFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}
