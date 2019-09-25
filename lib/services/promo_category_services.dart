import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/promo_category.dart';

Future<List<PromoCategory>> getAllPromosCategory(
    String token, int categoryAnimalId) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/promo/animal-category/$categoryAnimalId";
  debugPrint(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return promoCategoryFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}
