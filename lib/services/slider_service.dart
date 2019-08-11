import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/slider.dart';

// Future<List<Slider>> getAllSliders(String token) async {
//   final header = {"Content-Type": "application/json"};

//   final url = getBaseUrl() + "/sliders";

//   http.Response res = await http
//       .get(url, headers: header)
//       .timeout(Duration(seconds: getTimeOut()));
//   if (res.statusCode == 200) {
//     return sliderFromJson(res.body);
//   } else {
//     throw Exception(res.body);
//   }
// }
