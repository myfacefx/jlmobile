import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/top_seller.dart';
import 'package:jlf_mobile/models/top_seller_point.dart';

Future<List<TopSeller>> getTopSellersByCategoryId(
    String token, int animalCategoryId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/animal-categories/$animalCategoryId/top-sellers";

  debugPrint(url);

  http.Response res = await http.get(url, headers: header);
  if (res.statusCode == 200) {
    return topSellerFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<TopSeller>> getTopSellersBySubCategoryId(
    String token, int animalSubCategoryId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url =
      getBaseUrl() + "/animal-sub-categories/$animalSubCategoryId/top-sellers";

  debugPrint(url);

  http.Response res = await http.get(url, headers: header);
  if (res.statusCode == 200) {
    return topSellerFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<TopSeller>> getPromotedTopSeller(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/is-promoted-top-sellers";

  debugPrint(url);

  http.Response res = await http.get(url, headers: header);
  if (res.statusCode == 200) {
    return topSellerFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<TopSellerPoint>> getTopSellerPointCategory(
    String token, int categoryId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/top-seller/category/$categoryId";

  debugPrint(url);

  http.Response res = await http.get(url, headers: header);
  if (res.statusCode == 200) {
    return topSellerPointFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<List<TopSellerPoint>> getTopSellerPointSubCategory(
    String token, int subCategoryId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/top-seller/sub-category/$subCategoryId";

  debugPrint(url);

  http.Response res = await http.get(url, headers: header);
  if (res.statusCode == 200) {
    return topSellerPointFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}
