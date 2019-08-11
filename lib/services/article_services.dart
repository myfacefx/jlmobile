import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/article.dart';

Future<List<Article>> getAllArticle(String token, String type) async {
  final header = {"Content-Type": "application/json"};

  final url = getBaseUrl() + "/type/$type/article";
  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return articleFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}
