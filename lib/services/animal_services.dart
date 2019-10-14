import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/pagination.dart';

Future<Paginate> getLoadMore(String token, String nextUrl) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  debugPrint(nextUrl);

  http.Response res = await http.get(nextUrl, headers: header);
  if (res.statusCode == 200) {
    return paginateFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<Paginate> getAnimalAuctionByCategory(String token, int animalCategoryId,
    String sortBy, String filterName, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  if (sortBy == "Expiry Date") {
    sortBy = "Expiry_Date";
  }

  String params = "?";
  if (sortBy.length > 0) {
    params = params + "sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  debugPrint(
      getBaseUrl() + "/animals/category/$animalCategoryId/auction$params");
  http.Response res = await http.get(
      getBaseUrl() + "/animals/category/$animalCategoryId/auction$params",
      headers: header);
  if (res.statusCode == 200) {
    return paginateFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
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

  if (sortBy == "Expiry Date") {
    sortBy = "Expiry_Date";
  }

  String params = "?";
  if (sortBy.length > 0) {
    params = params + "sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  debugPrint(getBaseUrl() +
      "/animals/sub-category/$animalSubCategoryId/auction$params");
  http.Response res = await http.get(
      getBaseUrl() +
          "/animals/sub-category/$animalSubCategoryId/auction$params",
      headers: header);
  if (res.statusCode == 200) {
    return paginateFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<Paginate> getAnimalProductByCategory(String token, int animalCategoryId,
    String sortBy, String filterName, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?";
  if (sortBy.length > 0) {
    params = params + "sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  debugPrint(
      getBaseUrl() + "/animals/category/$animalCategoryId/product$params");
  http.Response res = await http.get(
      getBaseUrl() + "/animals/category/$animalCategoryId/product$params",
      headers: header);
  if (res.statusCode == 200) {
    return paginateFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
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
  if (sortBy.length > 0) {
    params = params + "sort_by=$sortBy";
  }
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  debugPrint(getBaseUrl() +
      "/animals/sub-category/$animalSubCategoryId/product$params");
  http.Response res = await http.get(
      getBaseUrl() +
          "/animals/sub-category/$animalSubCategoryId/product$params",
      headers: header);
  if (res.statusCode == 200) {
    return paginateFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<Animal> getAnimalById(String token, int animalId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  debugPrint(getBaseUrl() + "/animals/$animalId");
  http.Response res =
      await http.get(getBaseUrl() + "/animals/$animalId", headers: header);
  if (res.statusCode == 200) {
    return Animal.fromJson(json.decode(res.body));
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<int> deleteAnimalById(String token, int animalId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  debugPrint(getBaseUrl() + "/animals/$animalId");
  http.Response res =
      await http.delete(getBaseUrl() + "/animals/$animalId", headers: header);
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

Future<List<Animal>> getUserUnauctionedAnimals(String token, int userId, String filterName) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?";

  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  final url = getBaseUrl() + "/users/$userId/animals/draft$params";
  debugPrint(url);

  http.Response res = await http.get(url, headers: header);

  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getUserAuctionAnimals(String token, int userId, String filterName) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?";

  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  debugPrint(getBaseUrl() + "/users/$userId/auctions/animals$params");
  http.Response res = await http.get(
      getBaseUrl() + "/users/$userId/auctions/animals$params",
      headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getUserProductAnimals(String token, int userId, String filterName) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  String params = "?";
  if (filterName != "") {
    params = params + "&animal_name=$filterName";
  }

  debugPrint(getBaseUrl() + "/users/$userId/products/animals$params");
  http.Response res = await http
      .get(getBaseUrl() + "/users/$userId/products/animals$params", headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getUserBidsAnimals(
    String token, int userId, String sortBy) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  String params = "?";

  params = params + "sort_by=$sortBy";

  debugPrint(getBaseUrl() + "/users/$userId/bids/animals$params");
  http.Response res = await http.get(
      getBaseUrl() + "/users/$userId/bids/animals$params",
      headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getUserCommentAuctionAnimals(
    String token, int userId, String sortBy) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  String params = "?";

  params = params + "sort_by=$sortBy";

  debugPrint(getBaseUrl() + "/users/$userId/comments-auction/animals$params");
  http.Response res = await http.get(
      getBaseUrl() + "/users/$userId/comments-auction/animals$params",
      headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getUserCommentProductAnimals(
    String token, int userId, String sortBy) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  String params = "?";

  params = params + "sort_by=$sortBy";

  debugPrint(getBaseUrl() + "/users/$userId/comments-product/animals$params");
  http.Response res = await http.get(
      getBaseUrl() + "/users/$userId/comments-product/animals$params",
      headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<int> create(Map<String, dynamic> _data, String token,
    [http.MultipartFile videoToSent]) async {
  var uri = Uri.parse(getBaseUrl() + "/animals");
  http.MultipartRequest request = new http.MultipartRequest("POST", uri);
  request.fields['data'] = json.encode(_data);
  if (videoToSent != null) {
    request.files.add(videoToSent);
  }

  request.headers['Content-Type'] = "multipart/form-data";
  request.headers['Authorization'] = token;

  http.StreamedResponse response = await request.send();
  http.Response res = await http.Response.fromStream(response);

  debugPrint(uri);

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
  } else {
    throw Exception(res.body);
  }
}

Future<int> getAnimalsCount() async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/animals/count";

  debugPrint(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return int.parse(res.body);
  } else {
    throw Exception(res.body);
  }
}

// Future<int> updateAnimal(
//     String token, Map<String, dynamic> _data, int id) async {
//   final header = {"Content-Type": "application/json", "Authorization": token};

//   final url = getBaseUrl() + "/animals/$id";

//   debugPrint(url);

//   http.Response res = await http
//       .put(url, headers: header, body: json.encode(_data))
//       .timeout(Duration(seconds: getTimeOut() + 60));

//   if (res.statusCode == 202) {
//     return 1;
//   } else if (res.statusCode == 444) {
//     return 2;
//   } else {
//     throw Exception(res.body);
//   }
// }

// update with attachment
Future<int> updateAnimal(String token, Map<String, dynamic> _data, int id,
    [http.MultipartFile videoToSent]) async {
  var uri = Uri.parse(getBaseUrl() + "/animals-update/$id");
  // debugPrint(json.encode(_data));
  http.MultipartRequest request = new http.MultipartRequest("POST", uri);
  request.fields['data'] = json.encode(_data);
  if (videoToSent != null) {
    request.files.add(videoToSent);
  }
  request.headers['Authorization'] = token;
  request.headers['Content-Type'] = "multipart/form-data";

  http.StreamedResponse response = await request.send();
  http.Response res = await http.Response.fromStream(response);

  debugPrint(uri);

  if (res.statusCode == 202) {
    return 1;
  } else if (res.statusCode == 444) {
    return 2;
  } else {
    throw Exception(res.body);
  }
}

Future<List<Animal>> getSponsoredProducts(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/is-sponsored-animals";

  debugPrint(url);

  http.Response res = await http.get(url, headers: header);
  if (res.statusCode == 200) {
    return animalFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

// Future<bool> deleteImage(String token, int animalImageId) async {
//   final header = {"Content-Type": "application/json"};
//   final url = getBaseUrl() + "/animal-images/$animalImageId";

//   debugPrint(url);

//   http.Response res = await http
//       .delete(url, headers: header)
//       .timeout(Duration(seconds: getTimeOut() + 60));

//   if (res.statusCode == 204) {
//     return true;
//   } else if (res.statusCode == 406) {
//     return false;
//   } else {
//     throw Exception(res.body);
//   }
// }

// Future<bool> createImage(
//     String token, Map<String, dynamic> _data, int animalId) async {
//   final header = {"Content-Type": "application/json", "Authorization": token};
//   final url = getBaseUrl() + "/animals/$animalId/animal-images";

//   debugPrint(url);

//   http.Response res = await http
//       .post(url, headers: header, body: json.encode(_data))
//       .timeout(Duration(minutes: 10));

//   if (res.statusCode == 201) {
//     // debugPrint(res.body);
//     return true;
//   } else {
//     throw Exception(res.body);
//   }
// }
