import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/animal_category.dart';

Future<List<AnimalCategory>> getAnimalCategory(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  print(getBaseUrl() + "/animal-categories");
  http.Response res =
      await http.get(getBaseUrl() + "/animal-categories", headers: header);
  if (res.statusCode == 200) {
    return animalCategoryFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<List<AnimalCategory>> getNotUserAnimalCategory(
    String token, int userId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  print(getBaseUrl() + "/not/$userId/animal-categories");
  http.Response res = await http
      .get(getBaseUrl() + "/not/$userId/animal-categories", headers: header);
  if (res.statusCode == 200) {
    return animalCategoryFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}
