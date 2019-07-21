import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/auction_comment.dart';
import 'package:jlf_mobile/models/bid.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/pages/image_popup.dart';
import 'package:jlf_mobile/pages/user/profile.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/auction_comment_services.dart';
import 'package:jlf_mobile/services/auction_services.dart';
import 'package:jlf_mobile/services/bid_services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPage extends StatefulWidget {
  final int animalId;

  ProductDetailPage({Key key, @required this.animalId}) : super(key: key);
  @override
  _ProductDetailPage createState() => _ProductDetailPage(animalId);
}

class _ProductDetailPage extends State<ProductDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKeyComment = GlobalKey<FormState>();
  final _formKeyBid = GlobalKey<FormState>();

  var auctionHasExpired = false;

  // final bidController = MoneyMaskedTextController(leftSymbol: "Rp. ", precision: 0);

  int _current = 0;
  bool isLoading = true;
  Animal animal = Animal();

  TextEditingController bidController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  _ProductDetailPage(int animalId) {
    loadAnimal(animalId);
    globals.getNotificationCount();
    globals.autoClose();
  }

  _checkAuctionActivity() {
    var expiry_date = DateTime.parse(animal.auction.expiryDate);
    var now = DateTime.now();

    if (now.year >= expiry_date.year &&
        now.month >= expiry_date.month &&
        now.day >= expiry_date.day &&
        now.hour >= expiry_date.hour &&
        now.minute >= expiry_date.minute &&
        now.second >= expiry_date.second) {
      print("AUCTION EXPIRED");
      setState(() {
        auctionHasExpired = true;
      });
    }
  }

  void loadAnimal(int animalId) async {
    isLoading = true;
    getAnimalById("token", animalId).then((onValue) {
      animal = onValue;
      _checkAuctionActivity();
      setState(() {
        isLoading = false;
      });
    });
  }

  Widget _buildImage() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      margin: EdgeInsets.fromLTRB(2, 2, 2, 0),
      height: 180,
      color: Colors.white,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(1), child: _buildCarousel()),
    );
  }

  Widget _buildCarousel() {
    List<Widget> listImage = [];
    List<int> indexImage = [];
    int count = 0;
    animal.animalImages.forEach((image) {
      indexImage.add(count);
      count++;
      listImage.add(
        GestureDetector(
          onTap: () {
            // showDialog(
            //   context: context,
            //   builder: (BuildContext context) {
            //     return AlertDialog(
            //       title: Text("Foto", style: TextStyle(color: Colors.black)),
            //       content: FadeInImage.assetNetwork(
            //         placeholder: 'assets/images/loading.gif',
            //         image: image.image,
            //       ),
            //       actions: <Widget>[
            //         FlatButton(
            //           child: Text("Close"),
            //           onPressed: () {
            //             Navigator.of(context).pop();
            //           },
            //         ),
            //       ],
            //     );
            //   },
            // );

            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return ImagePopupPage(
                image: image.image,
                tagCount: "image$count",
                animalName: animal.name,
              );
            }));
          },
          child: Hero(
            tag: "image$count",
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/loading.gif',
              image: image.image,
            ),
          ),
        ),
      );
    });

    return Stack(
      children: <Widget>[
        Container(
          child: CarouselSlider(
            autoPlay: true,
            viewportFraction: 1.0,
            height: 153,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
            items: listImage,
          ),
        ),
        Positioned(
            bottom: 10,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[_buildDoted(_current + 1, listImage.length)],
            ))
      ],
    );
  }

  Widget _buildDoted(int index, int total) {
    return Container(
      child:
          globals.myText(text: "$index / $total", color: "light", weight: "XB"),
    );
  }

  Widget _buildDesc() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
              onTap: () => globals.share(),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container()
                  ),
                  Container(
                    padding: EdgeInsets.all(3),
                    width: globals.mw(context) * 0.3,
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: globals.myColor("primary"),
                    ), 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        globals.myText(text: "BAGIKAN", color: "light"),
                        Icon(Icons.share, size: 14, color: globals.myColor("light")),
                      ],
                    )),
                ],
              )),
          SizedBox(
            height: 8,
          ),
          Text(
              //"${animal.name} / ${animal.gender} / ${globals.convertToAge(animal.dateOfBirth)}",
              "${animal.name}",
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Theme.of(context).primaryColor)),
          SizedBox(
            height: 8,
          ),
          globals.myText(
              text: "${animal.description}", color: "dark", size: 13),
          SizedBox(
            height: 8,
          ),
          Divider(),
          Container(
            alignment: Alignment.centerLeft,
            child: Wrap(
              children: <Widget>[
                globals.myText(
                    text:
                        "Kategori: ${animal.animalSubCategory.name}, ${animal.animalSubCategory.animalCategory.name}",
                    color: "dark",
                    size: 13),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Divider(),
          Container(
            alignment: Alignment.centerLeft,
            child: Wrap(
              children: <Widget>[
                globals.myText(
                    text: "Lelang berakhir pada ", color: "dark", size: 13),
                globals.myText(
                    text:
                        "${globals.convertFormatDateTimeProduct(animal.auction.expiryDate)}",
                    color: "dark",
                    weight: "B",
                    size: 13),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Divider(),
          Container(
              alignment: Alignment.centerLeft,
              child: animal.auction.innerIslandShipping != null &&
                      animal.auction.innerIslandShipping == 0
                  ? globals.myText(
                      text: "Pengiriman ke seluruh nusantara",
                      color: "dark",
                      size: 13)
                  : globals.myText(
                      text: "Pengiriman dalam pulau saja",
                      color: "dark",
                      size: 13)),
        ],
      ),
    );
  }

  _sendWhatsApp(phone, message) async {
    if (phone.isNotEmpty && message.isNotEmpty) {
      String url = 'https://api.whatsapp.com/send?phone=$phone&text=$message';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Widget _buildOwnerDetail() {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          //avatar
          Container(
              height: 100,
              child: CircleAvatar(
                  radius: 40,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: animal.owner.photo != null &&
                              animal.owner.photo.isNotEmpty
                          ? FadeInImage.assetNetwork(
                              image: animal.owner.photo,
                              placeholder: 'assets/images/loading.gif',
                              fit: BoxFit.cover)
                          : Image.asset('assets/images/account.png')))),
          SizedBox(width: 5),
          Container(
            child: Column(
              children: <Widget>[
                Text(animal.owner.username),
                globals.myText(
                    text: animal.owner.regency.name, color: "light", size: 10),
                globals.myText(
                    text: animal.owner.province.name, color: "light", size: 10),
                Row(
                  children: <Widget>[
                    Icon(Icons.star, size: 10, color: Colors.yellow),
                    globals.myText(text: "4.5", color: "light", size: 10)
                  ],
                ),
                // Row(
                //   children: <Widget>[
                //     globals.myText(text: "1000", color: "light", size: 10),
                //     globals.myText(text: " | ", color: "light", size: 10),
                //     globals.myText(
                //         text: "10 Barang Terjual", color: "light", size: 10),
                //   ],
                // )
              ],
            ),
          ),
          SizedBox(width: 5),
          Column(
            children: <Widget>[
              Container(
                width: globals.mw(context) * 0.22,
                alignment: Alignment.center,
                child: RaisedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ProfilePage(userId: animal.owner.id))),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: globals.myText(
                        text: "PROFIL PELAPAK",
                        color: "unprime",
                        size: 10,
                        align: TextAlign.center),
                    color: Colors.white),
              ),
              Container(
                width: globals.mw(context) * 0.22,
                alignment: Alignment.center,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: globals.myText(
                      text: "CHAT WA PELAPAK",
                      color: "light",
                      size: 10,
                      align: TextAlign.center),
                  onPressed: () {
                    String phone = "62${animal.owner.phoneNumber.substring(1)}";
                    String message = "Halo";
                    _sendWhatsApp(phone, message);
                  },
                  color: Color.fromRGBO(37, 211, 102, 1),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _cancelAuction() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.red[900], borderRadius: BorderRadius.circular(30)),
      child: FlatButton(
        onPressed: () {
          return showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Batalkan Lelang",
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
                      textAlign: TextAlign.center),
                  content: Text("Batalkan lelang ini?",
                      style: TextStyle(color: Colors.black)),
                  actions: <Widget>[
                    FlatButton(
                        child: Text("Batal",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        }),
                    FlatButton(
                        color: Theme.of(context).primaryColor,
                        child:
                            Text("Ya", style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          try {
                            globals.loadingModel(context);
                            final result =
                                await cancelAuction("Token", animal.auction.id);
                            Navigator.pop(context);
                            if (result) {
                              await globals.showDialogs(
                                  "Berhasil membatalkan lelang", context);
                            } else {
                              await globals.showDialogs(
                                  "Gagal, silahkan coba kembali", context);
                            }

                            bidController.text = '';
                            Navigator.pop(context);
                            loadAnimal(animal.id);
                          } catch (e) {
                            Navigator.pop(context);
                            globals.showDialogs(e.toString(), context);
                            print(e);
                            print("######################");
                            print(e.toString());
                          }
                        })
                  ],
                );
              });
        },
        child: Text(
          "Batalkan Lelang",
          style: Theme.of(context)
              .textTheme
              .title
              .copyWith(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  // Widget _startAuction() {
  //   return Container(
  //     decoration: BoxDecoration(
  //         color: Colors.red[900], borderRadius: BorderRadius.circular(30)),
  //     child: FlatButton(
  //       onPressed: () {
  //         return showDialog(
  //             context: context,
  //             builder: (context) {
  //               return AlertDialog(
  //                 title: Text("Mulai Lelang",
  //                     style:
  //                         TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
  //                     textAlign: TextAlign.center),
  //                 content: Text("Mulai lelang ini?",
  //                     style: TextStyle(color: Colors.black)),
  //                 actions: <Widget>[
  //                   FlatButton(
  //                       child: Text("Batal",
  //                           style: TextStyle(
  //                               color: Theme.of(context).primaryColor)),
  //                       onPressed: () {
  //                         Navigator.of(context).pop(true);
  //                       }),
  //                   FlatButton(
  //                       color: Theme.of(context).primaryColor,
  //                       child:
  //                           Text("Ya", style: TextStyle(color: Colors.white)),
  //                       onPressed: () async {
  //                         try {
  //                           globals.loadingModel(context);
  //                           final result =
  //                               await startAuction("Token", animal.auction.id);
  //                           Navigator.pop(context);
  //                           if (result) {
  //                             await globals.showDialogs(
  //                                 "Berhasil memulai lelang", context);
  //                           } else {
  //                             await globals.showDialogs(
  //                                 "Gagal, silahkan coba kembali", context);
  //                           }

  //                           bidController.text = '';
  //                           Navigator.pop(context);
  //                           loadAnimal(animal.id);
  //                         } catch (e) {
  //                           Navigator.pop(context);
  //                           globals.showDialogs(e.toString(), context);
  //                         }
  //                       })
  //                 ],
  //               );
  //             });
  //       },
  //       child: Text(
  //         "Mulai Lelang",
  //         style: Theme.of(context)
  //             .textTheme
  //             .title
  //             .copyWith(color: Colors.white, fontSize: 16),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildRule(String title, double nominal) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 10),
            alignment: Alignment.centerRight,
            width: globals.mw(context) * 0.4,
            child: Text(
              title,
              style: Theme.of(context).textTheme.display3,
            ),
          ),
          Container(
              width: globals.mw(context) * 0.4,
              child: Container(
                decoration: BoxDecoration(
                    color: title == "Saat Ini"
                        ? globals.myColor("mimosa")
                        : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.fromLTRB(10, 3, 5, 3),
                child: Text(
                  globals.convertToMoney(nominal),
                  style: Theme.of(context)
                      .textTheme
                      .display3
                      .copyWith(color: Colors.white),
                ),
              )),

          // Text(
          //   title,
          //   style: Theme.of(context).textTheme.display3,
          // ),
          // SizedBox(
          //   width: 5,
          // ),
          // Container(
          //   decoration: BoxDecoration(
          //       color: Theme.of(context).primaryColor,
          //       borderRadius: BorderRadius.circular(5)),
          //   padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
          //   child: Text(
          //     globals.convertToMoney(nominal),
          //     style: Theme.of(context)
          //         .textTheme
          //         .display3
          //         .copyWith(color: Colors.white),
          //   ),
          // )
        ],
      ),
    );
  }

  TableRow _buildTableRow(
      bool isFirst, String name, String date, double amount) {
    return TableRow(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 3.5),
            width: globals.mw(context) * 0.3,
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .display4
                  .copyWith(color: Color.fromRGBO(136, 136, 136, 1)),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            globals.convertFormatDateTimeProduct(date),
            style: Theme.of(context).textTheme.display1,
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: isFirst ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(5)),
            width: globals.mw(context) * 0.25,
            padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
            margin: EdgeInsets.fromLTRB(5, 3, 0, 3),
            child: Text(
              globals.convertToMoney(amount),
              style: Theme.of(context).textTheme.display3.copyWith(
                  color: isFirst
                      ? Colors.white
                      : Color.fromRGBO(178, 178, 178, 1)),
            ),
          ),
          // Spacer()
        ],
      ),
    ]);
  }

  TableRow _buildHeaderTable() {
    return TableRow(children: [
      Text("BIDER",
          style: Theme.of(context)
              .textTheme
              .subtitle
              .copyWith(color: Theme.of(context).primaryColor)),
      Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Text("STATUS",
            style: Theme.of(context)
                .textTheme
                .subtitle
                .copyWith(color: Theme.of(context).primaryColor)),
      ),
    ]);
  }

  Widget _buildBidStatus() {
    List<TableRow> myList = [];
    int count = 0;
    myList.add(_buildHeaderTable());
    myList = animal.auction.bids.map((i) {
      count++;
      return _buildTableRow(
          count == 1, i.user.username, i.createdAt, i.amount.toDouble());
    }).toList();

    // Last 5 Bids

    return animal.auction.bids.length != 0
        ? Container(
            margin: EdgeInsets.fromLTRB(25, 0, 10, 0),
            child: Table(
                columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
                border: TableBorder(
                    bottom: BorderSide(color: Colors.grey[300]),
                    verticalInside: BorderSide(color: Colors.grey[300]),
                    horizontalInside: BorderSide(color: Colors.grey[300])),
                children: myList),
          )
        : Container(
            alignment: Alignment.center,
            child: Text(
              "Belum ada tawaran",
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ));
  }

  Widget _buildWinnerSection() {
    User winner;
    int amount;

    bool winnerFound = false;
    bool isOwner = false;
    bool isWinner = false;

    if (animal.auction.winnerBidId != null) {
      for (var i = 0; i < animal.auction.bids.length - 1; i++) {
        if (animal.auction.bids[i].id == animal.auction.winnerBidId) {
          winner = animal.auction.bids[i].user;
          amount = animal.auction.bids[i].amount;
          winnerFound = true;
          if (winner.id == globals.user.id) isWinner = true;
          break;
        }
      }
    }
    if (animal.auction.ownerUserId == globals.user.id) isOwner = true;

    return winnerFound
        ? Container(
            padding: EdgeInsets.fromLTRB(15, 25, 0, 0),
            width: globals.mw(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                globals.myText(
                    text: isWinner
                        ? "LELANG INI TELAH ANDA MENANGKAN"
                        : "LELANG DIMENANGKAN OLEH",
                    color: "dark",
                    size: 16),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ProfilePage(userId: winner.id))),
                  child: Container(
                      height: 90,
                      child: CircleAvatar(
                          radius: 40,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: winner.photo != null &&
                                      winner.photo.isNotEmpty
                                  ? FadeInImage.assetNetwork(
                                      image: winner.photo,
                                      placeholder: 'assets/images/loading.gif',
                                      fit: BoxFit.cover)
                                  : Image.network(
                                      'assets/images/account.png')))),
                ),
                globals.myText(
                    text: "${winner.username}",
                    size: 20,
                    color: 'primary',
                    align: TextAlign.center),
                SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.location_on, size: 13),
                    globals.myText(
                        text: winner.regency.name + ", " + winner.province.name,
                        size: 13,
                        textOverflow: TextOverflow.ellipsis),
                  ],
                ),
                SizedBox(height: 4),
                globals.myText(text: winner.phoneNumber, size: 15),
                SizedBox(height: 4),
                globals.myText(
                    text:
                        "Bid Terpasang: Rp. ${globals.convertToMoney(amount.toDouble())}",
                    size: 15,
                    align: TextAlign.center),
                SizedBox(height: 4),
                globals.myText(
                    text: "Tanggal: ${animal.auction.winnerAcceptedDate}",
                    size: 15,
                    align: TextAlign.center),
                SizedBox(height: 4),
                Container(
                    padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
                    child: Card(
                        color: Colors.grey[100],
                        child: Container(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: <Widget>[
                              globals.myText(
                                  text: animal.auction.verificationCode != null
                                      ? animal.auction.verificationCode
                                      : "19191",
                                  weight: "B",
                                  size: 30,
                                  letterSpacing: 3,
                                  color: "dark"),
                              globals.myText(
                                  text:
                                      "Ini adalah kode unik yang dimiliki oleh pemilik lelang dan pemenang lelang, gunakan kode unik ini untuk melakukan pengecekan",
                                  align: TextAlign.center,
                                  color: "dark",
                                  size: 13)
                            ],
                          ),
                        ))),
                // Wrap(children: <Widget>[
                //   globals.myText(text: "Kode Verifikasi: ", size: 16),
                // ],),
                globals.user.id == winner.id || isOwner
                    ? Container(
                        width: 300,
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: FlatButton(
                            onPressed: () {
                              String phone;
                              String message = "Halo";

                              if (isOwner) {
                                phone =
                                    "62${animal.owner.phoneNumber.substring(1)}";
                                _sendWhatsApp(phone, message);
                              } else if (isWinner) {
                                phone = "62${winner.phoneNumber.substring(1)}";
                                _sendWhatsApp(phone, message);
                              } else {
                                return null;
                              }
                            },
                            color: globals.myColor('primary'),
                            child: globals.myText(
                                text: isOwner
                                    ? "HUBUNGI PEMENANG"
                                    : "HUBUNGI PELELANG",
                                color: 'light',
                                weight: "B"),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))))
                    : Container(),
              ],
            ))
        : Container();
  }

  Widget _cancelledAuctionSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: <Widget>[
          Container(
              child: globals.myText(
                  text:
                      "Lelang dibatalkan pada ${animal.auction.cancellationDate}",
                  color: 'danger',
                  weight: 'B')),
        ],
      ),
    );
  }

  Widget _buildWinnerPicker() {
    // return winnerName != null && winnerName.isNotEmpty
    //     ? _winnerSection(winnerName, winnerUserName, amount)
    //     : animal.ownerUserId == globals.user.id &&
    //             animal.auction.winnerBidId == null &&
    //             animal.auction.active == 1
    //         ? Container(
    //             margin: EdgeInsets.symmetric(vertical: 15),
    //             child: Column(
    //               children: <Widget>[
    //                 Container(
    //                   decoration: BoxDecoration(
    //                       color: Theme.of(context).primaryColor,
    //                       borderRadius: BorderRadius.circular(30)),
    //                   child: FlatButton(
    //                     onPressed: () {
    //                       return showDialog(
    //                           context: context,
    //                           builder: (context) {
    //                             return AlertDialog(
    //                               title: Text("Pilih Pemenang Lelang",
    //                                   style: TextStyle(
    //                                       fontWeight: FontWeight.w800,
    //                                       fontSize: 25),
    //                                   textAlign: TextAlign.center),
    //                               content: Text(
    //                                   "Ambil pemenang lelang dengan tawaran tertinggi?",
    //                                   style: TextStyle(color: Colors.black)),
    //                               actions: <Widget>[
    //                                 FlatButton(
    //                                     child: Text("Batal",
    //                                         style: TextStyle(
    //                                             color: Theme.of(context)
    //                                                 .primaryColor)),
    //                                     onPressed: () {
    //                                       Navigator.of(context).pop(true);
    //                                     }),
    //                                 FlatButton(
    //                                     color: Theme.of(context).primaryColor,
    //                                     child: Text("Ya",
    //                                         style:
    //                                             TextStyle(color: Colors.white)),
    //                                     onPressed: () async {
    //                                       try {
    //                                         globals.loadingModel(context);
    //                                         final result = await setWinner(
    //                                             "Token", animal.auction.id);
    //                                         Navigator.pop(context);
    //                                         if (result) {
    //                                           await globals.showDialogs(
    //                                               "Berhasil memilih pemenang",
    //                                               context);
    //                                         } else {
    //                                           await globals.showDialogs(
    //                                               "Gagal, silahkan coba kembali",
    //                                               context);
    //                                         }

    //                                         bidController.text = '';
    //                                         Navigator.pop(context);
    //                                         loadAnimal(animal.id);
    //                                       } catch (e) {
    //                                         Navigator.pop(context);
    //                                         globals.showDialogs(
    //                                             e.toString(), context);
    //                                         print(e);
    //                                         print("######################");
    //                                         print(e.toString());
    //                                       }
    //                                     })
    //                               ],
    //                             );
    //                           });
    //                     },
    //                     child: Text(
    //                       "Ambil Pemenang",
    //                       style: Theme.of(context)
    //                           .textTheme
    //                           .title
    //                           .copyWith(color: Colors.white, fontSize: 16),
    //                     ),
    //                   ),
    //                 ),
    //                 SizedBox(height: 10),
    //                 animal.auction.cancellationDate == null
    //                     ? _cancelAuction()
    //                     : Container()
    //               ],
    //             ),
    //           )
    //         : Container();
  }

  Widget _buildBidRule() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
      child: Column(
        children: <Widget>[
          globals.myText(
              text: "- TAWARAN LELANG -", weight: "B", color: "dark", size: 16),
          SizedBox(
            height: 20,
          ),
          Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildRule("Harga Awal", animal.auction.openBid.toDouble()),
              _buildRule("Saat Ini", animal.auction.currentBid.toDouble()),
              _buildRule("Beli Sekarang", animal.auction.buyItNow.toDouble()),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          _buildBidStatus(),
          _buildWinnerSection()
        ],
      ),
    );
  }

  Widget textField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Form(
          key: _formKeyBid,
          child: Container(
            width: globals.mw(context) * 0.65,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            padding: EdgeInsets.fromLTRB(20, 5, 0, 5),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(30),
                  bottomLeft: const Radius.circular(30),
                )),
            child: TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              controller: bidController,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
              validator: (String bid) {
                // if (bid == null || bid == "" || bid == "0") {
                //   return "Tawaran tidak boleh kosong";
                // } else if (animal.auction.openBid > int.parse(bid)) {
                //   return "Jumlah tawaran terlalu kecil dari harga bukaan";
                // } else if (animal.auction.currentBid >= int.parse(bid)) {
                //   return "Jumlah tawaran terlalu kecil";
                // } else if ((int.parse(bid) % animal.auction.multiply) != 0) {
                //   return "Jumlah tawaran tidak sesuai kelipatan";
                // }
              },
              decoration: InputDecoration(
                  errorStyle: TextStyle(fontSize: 12),
                  border: InputBorder.none,
                  hintText: 'Masukkan Tawaran Anda',
                  hintStyle: TextStyle(fontSize: 12)),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                topRight: const Radius.circular(30),
                bottomRight: const Radius.circular(30),
              )),
          child: FlatButton(
            onPressed: () {
              _formKeyBid.currentState.save();

              String bid = bidController.text;

              if (bidController.text.isEmpty) {
                globals.showDialogs("Tawaran Anda masih kosong", context);
                return null;
              } else if (animal.auction.openBid > int.parse(bid)) {
                globals.showDialogs("Tawaran terlalu kecil", context);
                return null;
              } else if (animal.auction.currentBid >= int.parse(bid)) {
                globals.showDialogs(
                    "Tawaran terlalu kecil atau sama dengan harga saat ini",
                    context);
                return null;
              } else if (((int.parse(bid) - animal.auction.openBid) %
                      animal.auction.multiply) !=
                  0) {
                globals.showDialogs("Tawaran tidak sesuai kelipatan", context);
                return null;
              } else if (int.parse(bid) > animal.auction.buyItNow) {
                globals.showDialogs(
                    "Tawaran lebih besar dari pada harga beli sekarang",
                    context);
                return null;
              } else {
                _addBid(int.parse(bidController.text));
              }
            },
            child: Text(
              "PASANG",
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  _addBid(int amount) {
    Bid newBid = Bid();
    newBid.auctionId = animal.auction.id;
    newBid.userId = globals.user.id;
    newBid.amount = amount;

    double amountDouble = newBid.amount.toDouble();

    bool biddingBIN = amountDouble >= animal.auction.buyItNow.toInt();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Memasang Bid",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
                textAlign: TextAlign.center),
            content: Text(
                "Yakin memasang bid Rp. ${globals.convertToMoney(amountDouble)} ?" +
                    (biddingBIN ? " (Beli Sekarang)" : "") +
                    " " +
                    (animal.auction.innerIslandShipping != null &&
                            animal.auction.innerIslandShipping == 1
                        ? "(Pengiriman dalam pulau saja)"
                        : ""),
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              FlatButton(
                  child: Text("Batal",
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  }),
              FlatButton(
                  color: Theme.of(context).primaryColor,
                  child: Text("Ya", style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    try {
                      globals.loadingModel(context);
                      final result = await placeBid("Token", newBid);
                      Navigator.pop(context);

                      if (result) {
                        await globals.showDialogs("Tawaran terpasang", context);
                      } else {
                        await globals.showDialogs(
                            "Gagal, tawaran lebih rendah dari tawaran tertinggi saat ini",
                            context);
                      }

                      bidController.text = '';
                      Navigator.pop(context);
                      loadAnimal(animal.id);
                    } catch (e) {
                      print(e.toString());
                      Navigator.pop(context);
                      globals.showDialogs(e.toString(), context);
                    }
                  })
            ],
          );
        });
  }

  Widget _buildPutBid() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        children: <Widget>[
          globals.myText(
              text: "- PASANG BID -", weight: "B", color: "dark", size: 16),
          SizedBox(
            height: 10,
          ),
          Column(
            children: <Widget>[
              _buildRule("Kelipatan", animal.auction.multiply.toDouble()),
            ],
          ),
          SizedBox(height: 10),
          textField(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {
                  _addBid(this.animal.auction.buyItNow.toInt());
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: globals.myText(
                    text: "Beli Sekarang / BIN", color: "light", size: 15),
                color: globals.myColor("primary"),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextComment(AuctionComment auctionComment, int sellerId) {
    String username = sellerId != auctionComment.userId
        ? auctionComment.user.username
        : "SELLER";
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: sellerId != auctionComment.userId
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: sellerId != auctionComment.userId
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: <Widget>[
              //avatar
              sellerId != auctionComment.userId
                  ? Container(
                      height: 35,
                      child: CircleAvatar(
                          radius: 25,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: auctionComment.user.photo != null &&
                                      auctionComment.user.photo.isNotEmpty
                                  ? FadeInImage.assetNetwork(
                                      image: auctionComment.user.photo,
                                      placeholder: 'assets/images/loading.gif',
                                      fit: BoxFit.cover)
                                  : Image.network(
                                      'assets/images/account.png'))))
                  : Container(),
              Container(
                width: globals.mw(context) * 0.7,
                child: Column(
                  crossAxisAlignment: sellerId != auctionComment.userId
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: <Widget>[
                    globals.myText(
                        text:
                            "$username - ${globals.convertFormatDateTimeProduct(auctionComment.createdAt)}",
                        color: "disabled",
                        size: 10),
                    auctionComment.comment != "UP"
                        ? globals.myText(
                            text: auctionComment.comment,
                            color: "unprime",
                            size: 13)
                        : globals.myText(
                            text: "UP", color: "danger", size: 16, weight: "XB")
                  ],
                ),
              ),
              sellerId == auctionComment.userId
                  ? Container(
                      height: 35,
                      child: CircleAvatar(
                          radius: 25,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: auctionComment.user.photo != null &&
                                      auctionComment.user.photo.isNotEmpty
                                  ? FadeInImage.assetNetwork(
                                      image: auctionComment.user.photo,
                                      placeholder: 'assets/images/loading.gif',
                                      fit: BoxFit.cover)
                                  : Image.asset('assets/images/account.png'))))
                  : Container(),
            ],
          )
        ],
      ),
    );
  }

  void _addComment(String comment) async {
    AuctionComment auctionComment = AuctionComment();
    auctionComment.comment = comment;
    auctionComment.auctionId = animal.auction.id;
    auctionComment.userId = globals.user.id;

    try {
      globals.loadingModel(context);
      final result = await addComment("token", auctionComment);
      Navigator.pop(context);
      if (result) {
        await globals.showDialogs("Comment Sended", context);
        commentController.text = '';
        setState(() {
          isLoading = true;
        });
        loadAnimal(animal.id);
      }
    } catch (e) {
      Navigator.pop(context);
      globals.showDialogs(e.toString(), context);
    }
  }

  Widget textAddComment() {
    return Row(
      children: <Widget>[
        Container(
          width: globals.mw(context) * 0.65,
          margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
          padding: EdgeInsets.fromLTRB(20, 3, 20, 3),
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(30),
                bottomLeft: const Radius.circular(30),
              )),
          child: TextFormField(
            textInputAction: TextInputAction.newline,
            controller: commentController,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            validator: (text) {
              if (text == null || text == "" || text == " ") {
                return "Teks tidak boleh kosong";
              }
            },
            onSaved: (text) {
              commentController.text = text;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Tanyakan Sesuatu',
                hintStyle: TextStyle(fontSize: 12)),
          ),
        ),
        Container(
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
              topRight: const Radius.circular(30),
              bottomRight: const Radius.circular(30),
            ),
          ),
          child: FlatButton(
            onPressed: () {
              _formKeyComment.currentState.save();
              if (_formKeyComment.currentState.validate()) {
                _addComment(commentController.text);
              }
            },
            child: Text(
              "PASANG",
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForum() {
    return Container(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                globals.myText(text: "- ", color: "disabled", size: 16),
                globals.myText(
                    text: "FORUM PRODUK", color: "dark", size: 16, weight: "B"),
                globals.myText(
                    text: " (${animal.auction.countComments} comment)",
                    color: "disabled",
                    size: 16),
                globals.myText(text: " -", color: "disabled", size: 16),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            // Column(
            //   children: animal.auction.auctionComments.map((comment) {
            //     return _buildTextComment(comment, animal.ownerUserId);
            //   }).toList(),
            // ),
            animal.auction.countComments > 0
                ? Container(
                    height: globals.mh(context) * 0.4,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: animal.auction.countComments,
                      itemBuilder: (context, int index) {
                        return _buildTextComment(
                            animal.auction.auctionComments[index],
                            animal.ownerUserId);
                      },
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Belum ada komentar",
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    )),
            SizedBox(
              height: 20,
            ),
            animal.auction.active == 1 && auctionHasExpired == false
                ? Form(key: _formKeyComment, child: textAddComment())
                : Container(
                    child: globals.myText(
                        text: "Lelang berakhir",
                        color: "dark",
                        align: TextAlign.center)),
            animal.auction.active == 1 && auctionHasExpired == false
                ? Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          _addComment("UP");
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: globals.myText(
                            text: "UP", color: "light", size: 15),
                        color: globals.myColor("primary"),
                      ),
                    ),
                  )
                : Container()
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
      body: Scaffold(
        body: isLoading
            ? globals.isLoading()
            : SafeArea(
                child: ListView(
                  children: <Widget>[
                    animal.auction.cancellationDate != null
                        ? _cancelledAuctionSection()
                        : Container(),
                    _buildImage(),
                    SizedBox(
                      height: 8,
                    ),
                    _buildDesc(),
                    SizedBox(
                      height: 8,
                    ),
                    // If the logged in was the auction owner, hide element
                    (animal.ownerUserId == globals.user.id)
                        ? Container()
                        : _buildOwnerDetail(),
                    SizedBox(
                      height: 8,
                    ),
                    _buildBidRule(),
                    SizedBox(
                      height: 16,
                    ),
                    // If the logged in was the auction owner or the auction has been inactive, hide element
                    (animal.ownerUserId == globals.user.id ||
                                animal.auction.active ==
                                    0) || // Or the currentBid is equal or more than buy it now
                            (animal.auction.buyItNow.toInt() <=
                                animal.auction.currentBid.toInt()) ||
                            animal.auction.winnerBidId != null ||
                            auctionHasExpired == true
                        ? Container()
                        : _buildPutBid(),
                    SizedBox(
                      height: 16,
                    ),
                    _buildForum(),
                  ],
                ),
              ),
      ),
    );
  }
}
