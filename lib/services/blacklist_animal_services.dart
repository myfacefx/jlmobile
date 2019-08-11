import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/blacklist_animal.dart';

Future<List<BlacklistAnimal>> getAllBlacklistAnimal(String token) async {
  final header = {"Content-Type": "application/json"};

  final url = getBaseUrl() + "/blacklist-animals";

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return blacklistAnimalFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}
