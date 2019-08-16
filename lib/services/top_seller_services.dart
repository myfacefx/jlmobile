import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/top_seller.dart';

Future<List<TopSeller>> getTopSellersByCategoryId(String token, int animalCategoryId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  
  final url = getBaseUrl() + "/animal-categories/$animalCategoryId/top-sellers";

  print(url);

  http.Response res =
      await http.get(url, headers: header);
  if (res.statusCode == 200) {
    return topSellerFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<List<TopSeller>> getTopSellersBySubCategoryId(String token, int animalSubCategoryId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  
  final url = getBaseUrl() + "/animal-sub-categories/$animalSubCategoryId/top-sellers";

  print(url);

  http.Response res =
      await http.get(url, headers: header);
  if (res.statusCode == 200) {
    return topSellerFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}