import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/history.dart';

Future<List<History>> getHistories(String token, int userId) async {
  final header = {"Content-Type": "application/json"};
  
  final url = getBaseUrl() + "/users/$userId/histories";

  print(url);

  http.Response res = await http.get(url,
      headers: header).timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return historyFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}