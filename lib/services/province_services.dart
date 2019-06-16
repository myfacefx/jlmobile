import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/province.dart';


Future<List<Province>> getProvices(String token) async {
  final header = {"Content-Type": "application/json"};
  http.Response res = await http.get(getBaseUrl() + "/provinces",
      headers: header);
  if (res.statusCode == 200) {
    return provinceFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}