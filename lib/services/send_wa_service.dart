import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';

Future<Map<String, dynamic>> sendOTP(Map<String, dynamic> _data) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/send-OTP";

  debugPrint(url);
  http.Response res =
      await http.post(url, headers: header, body: json.encode(_data));

  var response = json.decode(res.body);

  if (res.statusCode == 201) {
    return response;
  } else {
    throw Exception(response['message']);
  }
}
