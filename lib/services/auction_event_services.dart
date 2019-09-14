import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/auction.dart';

Future<List<Auction>> getAuctionEventParticipants(String token) async {
  final header = {"Content-Type": "application/json", "Authorization": token};

  final url = getBaseUrl() + "/auctions/events";

  print(url);

  http.Response res = await http.get(url, headers: header);
  if (res.statusCode == 200) {
    return auctionFromJson(res.body);
  } else if (res.statusCode == 444) {
    return null;
  } else {
    throw Exception(res.body);
  }
}