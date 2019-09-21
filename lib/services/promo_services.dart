import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/promo.dart';

Future<List<Promo>> getAllPromos(
    String token, String type, String location) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/type/$type/location/$location/promos";
  debugPrint(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return promoFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}

Future<int> getCountPromos(String type, String location) async {
  final header = {"Content-Type": "application/json"};

  final url = getBaseUrl() + "/type/$type/location/$location/promos/count";
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
