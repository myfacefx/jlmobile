import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/regency.dart';

Future<List<Regency>> getRegenciesByProvinceId(provinceId) async {
  final header = {"Content-Type": "application/json"};

  final url = getBaseUrl() + "/provinces/$provinceId/regencies";

  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return regencyFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}
