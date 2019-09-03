import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/jlf_partner.dart';

Future<List<JlfPartner>> getAllJlfPartner(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/jlf-partners";
  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return jlfPartnerFromJson(res.body);
  } else if (res.statusCode == 200) {
    return null;
  } else {
    throw Exception(res.body);
  }
}
