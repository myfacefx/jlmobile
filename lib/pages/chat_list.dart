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
  bool isLoading = true;
  List<Auction> auctions = List<Auction>();

  @override
  void initState() {
    super.initState();
    // globals.getNotificationCount();
    this.refreshChats();
  }

  void refreshChats() {
    getAuctionsWithActiveChat(
            "Token", globals.user.id, globals.user.roleId == 1 ? true : false)
        .then((onValue) {
          print(onValue);
      
      auctions = onValue;
      
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError.toString(), context);
      setState(() {
        isLoading = false;
      });
    });
  }

  Widget _buildChat(Auction auction) {
    // DateTime unformattedDate = DateTime(int.parse(document['timestamp'].toString()));
    DateTime unformattedDate = DateTime.parse(auction.winnerAcceptedDate);

    String timestamp =
        "${unformattedDate.month.toString()}/${unformattedDate.day.toString()} ${unformattedDate.hour.toString()}:${unformattedDate.minute.toString()}";

    int bidCount = 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    ChatPage(chatId: auction.firebaseChatId)));
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(2),
          child: Row(
            children: <Widget>[
              Container(
                width: globals.mw(context) * 0.9,
                child: Column(
                  children: <Widget>[
                    globals.myText(
                        text: "ID Lelang #${auction.id} - PIC #Admin",
                        weight: "B"),
                    globals.myText(text: "Tanggal Menang Lelang: $timestamp"),
                    globals.myText(
                        text: "Invoice: " + globals.generateInvoice(auction))
                  ],
                ),
              ),
              // Container(
              //   padding: EdgeInsets.all(3),
              //   width: globals.mw(context) * 0.2,
              //   child: Column(
              //     children: <Widget>[
              //       SizedBox(
              //           child: Container(
              //               padding: EdgeInsets.symmetric(horizontal: 8),
              //               child: Row(
              //                   mainAxisAlignment: MainAxisAlignment.center,
              //                   children: <Widget>[
              //                     // bidCount != null && bidCount > 0
              //                     //     ? Container(
              //                     //         constraints: BoxConstraints(
              //                     //             minWidth: 20, minHeight: 20),
              //                     //         padding: EdgeInsets.all(5),
              //                     //         decoration: BoxDecoration(
              //                     //             color: Theme.of(context)
              //                     //                 .primaryColor,
              //                     //             borderRadius:
              //                     //                 BorderRadius.circular(100)),
              //                     //         child: Text("",
              //                     //             style: TextStyle(
              //                     //                 color: Colors.white,
              //                     //                 fontSize: 20)))
              //                     //     : Container()
              //                   ]))),
              //     ],
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListOfChats() {

    return isLoading == false ? auctions.length > 0
        ? Flexible(
            child: ListView.builder(
            itemCount: auctions.length,
            padding: EdgeInsets.all(5),
            itemBuilder: (BuildContext context, int i) {
              return _buildChat(auctions[i]);
            },
          ))
        : Center(child: globals.myText(text: "Belum ada obrolan")) : globals.isLoading();
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
                child: Column(children: <Widget>[
                  Center(
                    child: Column(children: <Widget>[
                      globals.myText(
                          text: "Obrolan Aktif", weight: "B", size: 24),
                      // globals.spacePadding(),
                    ]),
                  ),
                  _buildListOfChats()
                ]),
              ),
            )));
  }
}
