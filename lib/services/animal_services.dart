import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/pagination.dart';

Future<Paginate> getLoadMore(String token, String nextUrl) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  print("============================");
  print(nextUrl);
  print("============================");

  http.Response res = await http.get(nextUrl, headers: header);
  if (res.statusCode == 200) {
    return paginateFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<Paginate> getAnimalAuctionByCategory(String token, int animalCategoryId,
    String sortBy, String filterName, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?";
  if (sortBy == "Populer") {
    params = params + "sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  print(getBaseUrl() + "/animals/category/$animalCategoryId/auction$params");
  http.Response res = await http.get(
      getBaseUrl() + "/animals/category/$animalCategoryId/auction$params",
      headers: header);
  if (res.statusCode == 200) {
    return paginateFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<Paginate> getAnimalAuctionBySubCategory(
    String token,
    int animalSubCategoryId,
    String sortBy,
    String filterName,
    int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?";
  if (sortBy == "Populer") {
    params = params + "sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  print(getBaseUrl() +
      "/animals/sub-category/$animalSubCategoryId/auction$params");
  http.Response res = await http.get(
      getBaseUrl() +
          "/animals/sub-category/$animalSubCategoryId/auction$params",
      headers: header);
  if (res.statusCode == 200) {
    return paginateFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<Paginate> getAnimalProductByCategory(String token, int animalCategoryId,
    String sortBy, String filterName, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?";
  if (sortBy == "Populer") {
    params = params + "sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  print(getBaseUrl() + "/animals/category/$animalCategoryId/product$params");
  http.Response res = await http.get(
      getBaseUrl() + "/animals/category/$animalCategoryId/product$params",
      headers: header);
  if (res.statusCode == 200) {
    return paginateFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<Paginate> getAnimalProductBySubCategory(
    String token,
    int animalSubCategoryId,
    String sortBy,
    String filterName,
    int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?";
  if (sortBy == "Populer") {
    params = params + "sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  print(getBaseUrl() +
      "/animals/sub-category/$animalSubCategoryId/product$params");
  http.Response res = await http.get(
      getBaseUrl() +
          "/animals/sub-category/$animalSubCategoryId/product$params",
      headers: header);
  if (res.statusCode == 200) {
    return paginateFromJson(res.body);
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

Future<bool> deleteAnimalById(String token, int animalId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  print(getBaseUrl() + "/animals/$animalId");
  http.Response res =
      await http.delete(getBaseUrl() + "/animals/$animalId", headers: header);
  if (res.statusCode == 204) {
    return true;
  } else if (res.statusCode == 406) {
    return false;
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
  final url = getBaseUrl() + "/users/$userId/animals/draft";
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

Future<List<Animal>> getUserProductAnimals(String token, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  print(getBaseUrl() + "/users/$userId/products/animals");
  http.Response res = await http
      .get(getBaseUrl() + "/users/$userId/products/animals", headers: header);
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

Future<List<Animal>> getUserCommentAuctionAnimals(
    String token, int userId, String sortBy) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  String params = "?";

  params = params + "sort_by=$sortBy";

  print(getBaseUrl() + "/users/$userId/comments-auction/animals$params");
  http.Response res = await http.get(
      getBaseUrl() + "/users/$userId/comments-auction/animals$params",
      headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getUserCommentProductAnimals(
    String token, int userId, String sortBy) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  String params = "?";

  params = params + "sort_by=$sortBy";

  print(getBaseUrl() + "/users/$userId/comments-product/animals$params");
  http.Response res = await http.get(
      getBaseUrl() + "/users/$userId/comments-product/animals$params",
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
