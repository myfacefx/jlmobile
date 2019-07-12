import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/promo.dart';

Future<List<Promo>> getAllPromos(String token) async {
  final header = {"Content-Type": "application/json"};

  final url = getBaseUrl() + "/promos";

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return promoFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}
