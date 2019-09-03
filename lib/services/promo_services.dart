import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/promo.dart';

Future<List<Promo>> getAllPromos(
    String token, String type, String location) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/type/$type/location/$location/promos";
  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return promoFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}
