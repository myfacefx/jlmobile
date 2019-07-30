import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/auction.dart';
import 'package:jlf_mobile/pages/chat.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/auction_services.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Auction> auctions = List<Auction>();

  @override
  void initState() {
    super.initState();
    // globals.getNotificationCount();
    this.refreshChats();
  }

  void refreshChats() {
    getAuctionsWithActiveChat("Token").then((onValue) {
      auctions = onValue;
      print(auctions.toString());
      setState(() {
        
      });
    }).catchError((onError) {
      globals.showDialogs(onError.toString(), context);
    });
  }

  Widget _buildChat(Auction auction) {
    // DateTime unformattedDate = DateTime(int.parse(document['timestamp'].toString()));
    DateTime unformattedDate = DateTime.parse(auction.winnerAcceptedDate);

    String timestamp = "${unformattedDate.month.toString()}/${unformattedDate.day.toString()} ${unformattedDate.hour.toString()}:${unformattedDate.minute.toString()}";

    return ListTile(
      title: globals.myText(text: "ID #${auction.id} - PIC #Admin"),
      subtitle: globals.myText(text: "Tanggal Menang Lelang: $timestamp"),
      onTap: () {
         Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  ChatPage(
                      chatId: auction
                          .firebaseChatId)));
      }
    );
  }

  Widget _buildListOfChats() {
    return auctions.length > 0 ? Flexible(child: ListView.builder(
      itemCount: auctions.length,
      padding: EdgeInsets.all(5),
      itemBuilder: (BuildContext context, int i) {
        return _buildChat(auctions[i]);
      },
    )) : Container(child: globals.myText(text: "Tidak ada chat aktif saat ini"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(_scaffoldKey, context),
      body: Scaffold(
        key: _scaffoldKey,
        drawer: drawer(context),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
            child: Column(
              children: <Widget>[
                Center(
                  child: Column(children: <Widget>[
                    globals.myText(text: "DAFTAR CHAT LELANG", weight: "B", size: 24),
                    // globals.spacePadding(),
                  ]),
                ),
                _buildListOfChats()
              ] 
            ),
          ),
        )));
  }
}