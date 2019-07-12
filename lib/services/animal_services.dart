import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/animal.dart';

Future<List<Animal>> getAnimalByCategory(String token, int animalCategoryId,
    String sortBy, String filterName, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?animal_category_id=$animalCategoryId";
  if (sortBy == "Populer") {
    params = params + "&sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  print(getBaseUrl() + "/animals/filter/$userId$params");
  http.Response res =
      await http.get(getBaseUrl() + "/animals/filter/$userId$params", headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getAnimalBySubCategory(
    String token,
    int animalSubCategoryId,
    String sortBy,
    String filterName,
    int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?animal_sub_category_id=$animalSubCategoryId";
  if (sortBy == "Populer") {
    params = params + "&sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  print(getBaseUrl() + "/animals/filter/$userId$params");
  http.Response res =
      await http.get(getBaseUrl() + "/animals/filter/$userId$params", headers: header);
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

Future<List<Animal>> getUserUnauctionedAnimals(String token, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/users/$userId/animals/unauctioned";
  print(url);

  http.Response res = await http.get(url, headers: header);

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

Future<List<Animal>> getUserBidsAnimals(
    String token, int userId, String sortBy) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  String params = "?";

  params = params + "sort_by=$sortBy";

  print(getBaseUrl() + "/users/$userId/bids/animals$params");
  http.Response res = await http.get(
      getBaseUrl() + "/users/$userId/bids/animals$params",
      headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getUserCommentAnimals(
    String token, int userId, String sortBy) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  String params = "?";

  params = params + "sort_by=$sortBy";

  print(getBaseUrl() + "/users/$userId/comments/animals$params");
  http.Response res = await http.get(
      getBaseUrl() + "/users/$userId/comments/animals$params",
      headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<bool> create(Map<String, dynamic> _data) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/animals";

  http.Response res = await http
      .post(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut() + 270));

  print(url);
  // print(_data);

  if (res.statusCode == 201) {
    // print(res.body);
    return true;
  } else {
    throw Exception(res.body);
  }
}

Future<bool> activate(Map<String, dynamic> _data, int animalId) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/animals/$animalId/auction/create";

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
