import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/auction.dart';
import 'package:jlf_mobile/models/bid.dart';
import 'package:jlf_mobile/models/chat_list_pagination.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/pages/chat.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/services/auction_services.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  List<Auction> auctions = List<Auction>();

  ChatListPagination chatListPagination = ChatListPagination();
  String _search;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // globals.getNotificationCount();
    this.refreshChats();
    globals.getNotificationCount();
  }

  void refreshChats({int page = 1, String search = ''}) {
    setState(() {
      isLoading = true;
    });
    getAuctionsWithActiveChat(globals.user.tokenRedis, globals.user.id,
            globals.user.roleId == 1 ? true : false, page, search)
        .then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }

      chatListPagination = null;
      chatListPagination = onValue;

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

    User winner = User();
    int amount;
    bool winnerFound = false,
        isWinner = false,
        isOwner = false,
        isAdmin = false;

    List<Bid> bids = auction.animal.auction.bids;

    if (auction.adminUserId == globals.user.id) isAdmin = true;

    if (auction != null && auction.winnerBidId != null) {
      for (var i = 0; i < bids.length; i++) {
        if (bids[i].id == auction.winnerBidId) {
          winner = bids[i].user;
          amount = bids[i].amount;
          winnerFound = true;
          if (winner.id == globals.user.id) isWinner = true;

          break;
        }
      }
    }
    if (auction.ownerUserId == globals.user.id) isOwner = true;

    int unreadCount = 0;
    if (isWinner || isOwner || isAdmin) {
      unreadCount = isWinner
          ? auction.buyerUnreadCount
          : isOwner
              ? auction.sellerUnreadCount
              : isAdmin ? auction.adminUnreadCount : 0;
    }

    return Card(
      child: Container(
        padding: EdgeInsets.all(2),
        child: Row(
          children: <Widget>[
            Container(
              width: globals.mw(context) * 0.9,
              child: Column(
                children: <Widget>[
                  isWinner || isOwner
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              width: 85,
                              padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                  color: isWinner
                                      ? globals.myColor("success")
                                      : globals.myColor("warning"),
                                  borderRadius: BorderRadius.circular(5)),
                              child: globals.myText(
                                  text: isWinner ? 'Pemenang' : 'Pelapak',
                                  color: 'light',
                                  size: 10,
                                  align: TextAlign.center),
                            ),
                          ],
                        )
                      : Container(),
                  SizedBox(height: 5),
                  globals.myText(
                      text: "Lelang Hewan '${auction.animal.name}'",
                      weight: "B"),
                  !isOwner
                      ? globals.myText(
                          text: "Pelapak: ${auction.owner.username}")
                      : Container(),
                  winnerFound && !isWinner
                      ? globals.myText(text: "Pemenang: ${winner.username}")
                      : Container(),
                  globals.myText(text: "Tanggal: $timestamp"),
                  globals.myText(
                      text: "Invoice: " + globals.generateInvoice(auction)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: FlatButton(
                          color: globals.myColor("primary"),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Icon(Icons.card_travel,
                                    color: globals.myColor('light')),
                              ),
                              globals.myText(
                                  text: "Lihat Lelang", color: "light"),
                            ],
                          ),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ProductDetailPage(
                                        animalId: auction.animal.id,
                                        from: 'LELANG',
                                      ))),
                        ),
                      ),
                      FlatButton(
                          color: globals.myColor("success"),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Icon(Icons.chat,
                                    color: globals.myColor('light')),
                              ),
                              globals.myText(
                                  text: "Chat Rekber", color: "light"),
                              unreadCount != null && unreadCount > 0
                                  ? Container(
                                      margin: EdgeInsets.only(left: 5),
                                      constraints: BoxConstraints(
                                          minWidth: 10, minHeight: 10),
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: globals.myColor("danger"),
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: Text("$unreadCount",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10)))
                                  : Container()
                            ],
                          ),
                          onPressed: () {
                            if (auction.firebaseChatId == null) {
                              globals.showDialogs(
                                  "Terjadi kesalahan pada pointing ruangan chat",
                                  context);
                              return null;
                            } else {
                              globals.debugPrint("FIREBASECHATID ${auction.firebaseChatId}");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ChatPage(auction: auction)));
                            }
                          })
                    ],
                  )
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
    );
  }

  Widget _buildListOfChats() {
    bool hasChat = true;

    if (chatListPagination == null ||
        chatListPagination.data == null ||
        chatListPagination.total == 0) {
      hasChat = false;
    }

    globals.debugPrint("Has Chat $hasChat");

    return Flexible(
        child: isLoading == false
            ? hasChat
                ? ListView.builder(
                    itemCount: chatListPagination.data.length,
                    padding: EdgeInsets.all(5),
                    itemBuilder: (BuildContext context, int i) {
                      return _buildChat(chatListPagination.data[i]);
                    },
                  )
                : Center(child: globals.myText(text: "Tidak ada Chat Rekber"))
            : globals.isLoading());
  }

  Widget _buildSearch() {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: globals.mw(context),
              // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: TextFormField(
                textInputAction: TextInputAction.next,
                validator: (String value) {
                  if (value.isEmpty) return 'Silahkan masukkan nomor pencarian';
                },
                onFieldSubmitted: (String value) {
                  refreshChats(page: 1, search: value);
                },
                onSaved: (String value) => _search = value,
                // onFieldSubmitted: (String value) {},
                style: TextStyle(color: Colors.black),
                controller: searchController,
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: () {
                        refreshChats(page: 1, search: searchController.text);
                      },
                      child: Icon(Icons.search),
                    ),
                    // filled: true,
                    // fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(13),
                    hintText: "Nomor Invoice",
                    labelText: "Cari Nomor Invoice",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ))
        ],
      ),
    );
  }

  Widget _buildPagination() {
    bool hasChat = true;

    if (chatListPagination == null ||
        chatListPagination.data == null ||
        chatListPagination.total == 0) {
      hasChat = false;
    }

    return !hasChat
        ? Container()
        : Container(
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                  onTap: () => isLoading
                      ? null
                      : chatListPagination.currentPage > 1
                          ? refreshChats(
                              page: chatListPagination.currentPage - 1)
                          : null,
                  child: Icon(Icons.navigate_before,
                      color: chatListPagination.currentPage > 1
                          ? Colors.black
                          : Colors.black12)),
              globals.myText(
                  text:
                      "Halaman ${chatListPagination.currentPage} dari ${chatListPagination.lastPage}"),
              GestureDetector(
                  onTap: () => isLoading
                      ? null
                      : chatListPagination.currentPage <
                              chatListPagination.lastPage
                          ? refreshChats(
                              page: chatListPagination.currentPage + 1)
                          : null,
                  child: Icon(Icons.navigate_next,
                      color: chatListPagination.currentPage <
                              chatListPagination.lastPage
                          ? Colors.black
                          : Colors.black12)),
            ],
          ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context,
            isSubMenu: true, showNotification: false),
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
                          text: "CHAT REKBER", weight: "B", size: 24),
                    ]),
                  ),
                  globals.spacePadding(padding: 5),
                  _buildSearch(),
                  globals.spacePadding(padding: 5),
                  _buildListOfChats(),
                  globals.spacePadding(padding: 5),
                  _buildPagination()
                ]),
              ),
            )));
  }
}
