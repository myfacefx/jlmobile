import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/province.dart';

Future<List<Province>> getProvinces() async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/provinces";

  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return provinceFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}
