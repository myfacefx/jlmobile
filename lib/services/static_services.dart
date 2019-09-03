import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/static.dart';

Future<List<Static>> getAllStatics() async {
  final header = {"Content-Type": "application/json"};

  final url = getBaseUrl() + "/statics";

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return staticFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<dynamic> checkAvailable(String token, String type) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/check-available/$type";

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return true;
  } else if (res.statusCode == 401) {
    return false;
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}
