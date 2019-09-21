import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/article.dart';

Future<List<Article>> getAllArticle(String token, String type) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/type/$type/article";
  debugPrint(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return articleFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}
