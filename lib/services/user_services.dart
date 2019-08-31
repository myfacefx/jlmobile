import 'dart:convert';

import 'package:jlf_mobile/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> login(Map<String, dynamic> _data) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/login";

  print(url);
  http.Response res =
      await http.post(url, headers: header, body: json.encode(_data));

  print(res.statusCode);

  var response = json.decode(res.body);

  if (res.statusCode == 200) {
    return response;
  } else {
    throw Exception(response['message']);
  }
  // User user;

  // if (res.statusCode == 200) {
  //   user = userFromJson(res.body);
  //   user.statusCode = 1;
  // } else if (res.statusCode == 404) {
  //   user = User();
  //   user.statusCode = 2;
  // } else if (res.statusCode == 405) {
  //   user = User();
  //   user.statusCode = 3;
  // } else {
  //   throw Exception(res.body);
  // }

  // return user;
}

Future<bool> logout(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  http.Response res = await http.get(getBaseUrl() + "/logout", headers: header);
  if (res.statusCode == 202) {
    return true;
  } else {
    throw Exception(res.body);
  }
}

Future<User> register(Map<String, dynamic> _data) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/register";

  http.Response res = await http
      .post(url, headers: header, body: json.encode(_data))
      .timeout(Duration(minutes: 60));

  if (res.statusCode == 200) {
    return userFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<User> get(int userId) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/users/$userId";

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  print(res.body);

  if (res.statusCode == 200) {
    return userFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<String> update(Map<String, dynamic> _data, int userId) async {
  final header = {"Content-Type": "application/json"};
  final String url = getBaseUrl() + "/users/$userId/update";

  print(url);

  http.Response res = await http
      .put(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 202) {
    return json.decode(res.body)['content'];
  } else {
    throw Exception(res.body);
  }
}

Future<Map<String, dynamic>> updateVerification(
    Map<String, dynamic> _data, int userId) async {
  final header = {"Content-Type": "application/json"};
  final String url = getBaseUrl() + "/users/$userId/update-verification";

  print(url);

  http.Response res = await http
      .put(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut() + 200));

  print(res.statusCode);

  var response = json.decode(res.body);

  if (res.statusCode == 202) {
    return response;
  } else {
    throw Exception(response['message']);
  }
}

Future<String> updateProfilePicture(
    Map<String, dynamic> _data, int userId) async {
  final header = {"Content-Type": "application/json"};
  final String url = getBaseUrl() + "/users/$userId/updateProfilePicture";

  print(url);

  http.Response res = await http
      .put(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 202) {
    return json.decode(res.body)['content'];
  } else {
    throw Exception(res.body);
  }
}

Future<User> changePassword(String token, Map<String, dynamic> input) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  http.Response res = await http.put(getBaseUrl() + "/users",
      headers: header, body: json.encode(input));
  if (res.statusCode == 200) {
    return userFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

/**
 * User data access from/to local storage
 */
/// Save Key-Value Pair to local storage
saveLocalData(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

/// Return Value using Key from local storage
Future<String> readLocalData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  String a = prefs.getString(key);
  return a;
}

/// Remove Key-Value Pair from local storage
deleteLocalData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

Future<List<User>> getBlacklistedUser() async {
  final header = {"Content-Type": "application/json"};

  http.Response res = await http
      .get(getBaseUrl() + "/blacklists", headers: header)
      .timeout(Duration(seconds: getTimeOut()));
  if (res.statusCode == 200) {
    return listUserFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<List<User>> getByEmail(Map<String, dynamic> _data) async {
  final header = {"Content-Type": "application/json"};
  http.Response res = await http
      .post(getBaseUrl() + "/users/search/email",
          headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return listUserFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<List<User>> fbLoginSearch(Map<String, dynamic> _data) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/users/facebook-login-search";

  print(url);

  http.Response res = await http
      .post(url, headers: header, body: json.encode(_data))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return listUserFromJson(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<int> getHistoriesCount(int userId) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/users/$userId/histories/count";

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return int.parse(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<int> getBidsCount(int userId) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/users/$userId/bids/count";

  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return int.parse(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<Map<String, int>> getHistoriesAndBidsCount(int userId) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/users/$userId/historiesAndBids/count";

  final Map<String, int> response = Map<String, int>();

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    // return json.decode(res.body).map((x) =>
    // response.
    // );
    // return res.body;
    // return int.parse(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<int> getUsersCount() async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/users/count";

  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return int.parse(res.body);
  } else {
    throw Exception(res.body);
  }
}

Future<bool> getUsersByPhoneNumber(String phoneNumber) async {
  final header = {"Content-Type": "application/json"};
  final url = getBaseUrl() + "/users/$phoneNumber/phone-number";

  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    print(res.body);
    return res.body == "true" ? true : false;
  } else {
    throw Exception(res.body);
  }
}

// Future<List<User>> getTopSellers(String token, ) async {
//   final header = {"Content-Type": "application/json"};

//   http.Response res = await http
//       .get(getBaseUrl() + "/blacklists", headers: header)
//       .timeout(Duration(seconds: getTimeOut()));
//   if (res.statusCode == 200) {
//     return listUserFromJson(res.body);
//   } else {
//     throw Exception(res.body);
//   }
// }

Future<User> verifyToken(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};
  final url = getBaseUrl() + "/verify-token";

  print(url);

  http.Response res = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    return userFromJson(res.body);
  } else if (res.statusCode == 400) {
    return null;
  } else {
    throw Exception(res.body);
  }
}
