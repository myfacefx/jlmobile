import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/animal.dart';

Future<List<Animal>> getAnimalByCategory(String token, int animalCategoryId,
    String sortBy, String filterName) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?animal_category_id=$animalCategoryId";
  if (sortBy == "Populer") {
    params = params + "&sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  print(getBaseUrl() + "/animals$params");
  http.Response res =
      await http.get(getBaseUrl() + "/animals$params", headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getAnimalBySubCategory(String token,
    int animalSubCategoryId, String sortBy, String filterName) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?animal_sub_category_id=$animalSubCategoryId";
  if (sortBy == "Populer") {
    params = params + "&sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  print(getBaseUrl() + "/animals$params");
  http.Response res =
      await http.get(getBaseUrl() + "/animals$params", headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<Animal> getAnimalById(String token, int animalId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  print(getBaseUrl() + "/animals/$animalId");
  http.Response res =
      await http.get(getBaseUrl() + "/animals/$animalId", headers: header);
  if (res.statusCode == 200) {
    return Animal.fromJson(json.decode(res.body));
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getUserAnimals(String token, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  print(getBaseUrl() + "/users/$userId/animals");
  http.Response res =
      await http.get(getBaseUrl() + "/users/$userId/animals", headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getUserAuctionAnimals(String token, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  print(getBaseUrl() + "/users/$userId/auctions/animals");
  http.Response res = await http
      .get(getBaseUrl() + "/users/$userId/auctions/animals", headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getUserBidsAnimals(String token, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  print(getBaseUrl() + "/users/$userId/bids/animals");
  http.Response res = await http
      .get(getBaseUrl() + "/users/$userId/bids/animals", headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}
