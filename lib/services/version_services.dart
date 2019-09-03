import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/version.dart';

Future<Version> verifyVersion(String version) async {
  final header = {"Content-Type": "application/json"};

  final url = getBaseUrl() + "/check-version/$version";
  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return versionFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}
