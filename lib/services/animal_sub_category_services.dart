import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';

Future<List<AnimalSubCategory>> getAnimalSubCategoryByCategoryId(
    String token, int id) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/animal-categories/$id/animal-sub-categories";
  print(url);
  http.Response res = await http.get(url, headers: header);
  if (res.statusCode == 200) {
    return animalSubCategoryFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}
