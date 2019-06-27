import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/auction_comment.dart';
import 'package:jlf_mobile/models/bid.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/auction_comment_services.dart';
import 'package:jlf_mobile/services/auction_services.dart';
import 'package:jlf_mobile/services/bid_services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

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

  // final bidController = MoneyMaskedTextController(leftSymbol: "Rp. ", precision: 0);

  int _current = 0;
  bool isLoading = true;
  Animal animal = Animal();

  TextEditingController bidController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  _ProductDetailPage(int animalId) {
    loadAnimal(animalId);
  }

  void loadAnimal(int animalId) async {
    isLoading = true;
    getAnimalById("token", animalId).then((onValue) {
      animal = onValue;
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
      color: Colors.black,
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
        FadeInImage.assetNetwork(
          placeholder: 'assets/images/loading.gif',
          image: image.image,
        ),
      );
    });

    return Stack(
      children: <Widget>[
        Container(
          child: CarouselSlider(
            autoPlay: true,
            enlargeCenterPage: true,
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
            bottom: 0,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: indexImage.map((i) {
                return _buildDoted(i);
              }).toList(),
            ))
      ],
    );
  }

  Widget _buildDoted(int index) {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _current == index ? Colors.black : Colors.grey),
    );
  }

  Widget _buildDesc() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
              "${animal.name} / ${animal.gender} / ${globals.convertToAge(animal.dateOfBirth)}",
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Theme.of(context).primaryColor)),
          SizedBox(
            height: 8,
          ),
          Text(
            "${animal.description}",
            style: Theme.of(context).textTheme.display2,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
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
                      child: animal.owner.photo.isNotEmpty
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
                Row(
                  children: <Widget>[
                    Icon(Icons.star),
                    globals.myText(text: "4.0/5.0", color: "light", size: 10)
                  ],
                ),
                Row(
                  children: <Widget>[
                    globals.myText(text: "1000", color: "light", size: 10),
                    globals.myText(text: " |", color: "light", size: 10),
                    globals.myText(
                        text: "10 Barang Terjual", color: "light", size: 10),
                  ],
                )
              ],
            ),
          ),
          SizedBox(width: 5),
          Container(
            width: globals.mw(context) * 0.3,
            alignment: Alignment.center,
            child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: globals.myText(
                    text: "PROFIL PELAPAK",
                    color: "unprime",
                    size: 10,
                    align: TextAlign.center),
                onPressed: () {},
                color: Colors.white),
          )
        ],
      ),
    );
  }

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
                        ? Color.fromRGBO(184, 134, 11, 1)
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

  Widget _buildBidRule() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
      child: Column(
        children: <Widget>[
          globals.myText(
              text: "-- TAWARAN LELANG --",
              weight: "B",
              color: "dark",
              size: 16),
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
          animal.ownerUserId != globals.user.id || animal.auction.active == 0
              ? animal.auction.winnerBidId != null ? globals.myText(text: "Winner Bid ID = ${animal.auction.winnerBidId}", size: 30, weight: "B") : Container()
              : Container(
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: FlatButton(
                    onPressed: () {
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Pilih Pemenang Lelang",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 25),
                                  textAlign: TextAlign.center),
                              content: Text(
                                  "Ambil pemenang lelang dengan tawaran tertinggi?",
                                  style: TextStyle(color: Colors.black)),
                              actions: <Widget>[
                                FlatButton(
                                    child: Text("Batal",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    }),
                                FlatButton(
                                    color: Theme.of(context).primaryColor,
                                    child: Text("Ya",
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () async {
                                      try {
                                        globals.loadingModel(context);
                                        final result = await setWinner(
                                            "Token", animal.auction.id);
                                        Navigator.pop(context);
                                        if (result) {
                                          await globals.showDialogs(
                                              "Berhasil memilih pemenang",
                                              context);
                                        } else {
                                          await globals.showDialogs(
                                              "Gagal, silahkan coba kembali",
                                              context);
                                        }

                                        bidController.text = '';
                                        Navigator.pop(context);
                                        loadAnimal(animal.id);
                                      } catch (e) {
                                        Navigator.pop(context);
                                        globals.showDialogs(
                                            e.toString(), context);
                                      }
                                    })
                              ],
                            );
                          });
                    },
                    child: Text(
                      "Ambil Pemenang",
                      style: Theme.of(context)
                          .textTheme
                          .title
                          .copyWith(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
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
            width: globals.mw(context) - 138,
            padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(30)),
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
                if (bid == null || bid == "" || bid == "0") {
                  return "Tawaran tidak boleh kosong";
                } else if (animal.auction.openBid >= int.parse(bid)) {
                  return "Jumlah tawaran terlalu kecil dari harga bukaan";
                } else if (animal.auction.currentBid >= int.parse(bid)) {
                  return "Jumlah tawaran terlalu kecil";
                } else if ((int.parse(bid) % animal.auction.multiply) != 0) {
                  return "Jumlah tawaran tidak sesuai kelipatan";
                }
              },
              decoration: InputDecoration(
                  errorStyle: TextStyle(fontSize: 10),
                  border: InputBorder.none,
                  hintText: 'Masukkan Tawaran Anda',
                  hintStyle: TextStyle(fontSize: 10)),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(30)),
          child: FlatButton(
            onPressed: () {
              _formKeyBid.currentState.save();
              if (_formKeyBid.currentState.validate()) {
                _addBid();
              }
            },
            child: Text(
              "PASANG",
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  _addBid() {
    Bid newBid = Bid();
    newBid.auctionId = animal.auction.id;
    newBid.userId = globals.user.id;
    newBid.amount = int.parse(bidController.text);

    double amountDouble = newBid.amount.toDouble();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Memasang Bid",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
                textAlign: TextAlign.center),
            content: Text(
                "Yakin memasang bid Rp. ${globals.convertToMoney(amountDouble)} ?",
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
      padding: EdgeInsets.fromLTRB(0, 10, 20, 20),
      child: Column(
        children: <Widget>[
          globals.myText(
              text: "-- PASANG BID --", weight: "B", color: "dark", size: 16),
          SizedBox(
            height: 10,
          ),
          Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // _buildRule("Harga Awal", animal.auction.openBid.toDouble()),
              _buildRule("Kelipatan", animal.auction.multiply.toDouble()),
            ],
          ),
          // Center(
          //   child: Text("")
          // ),
          // globals.convertToMoney(nominal)
          SizedBox(height: 10),
          textField(),
          SizedBox(
            height: 8,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {},
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: globals.myText(text: "B.I.N", color: "light", size: 15),
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
                              child: auctionComment.user.photo.isNotEmpty
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
                              child: auctionComment.user.photo.isNotEmpty
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
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(30)),
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
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(30)),
          child: FlatButton(
            onPressed: () {
              _formKeyComment.currentState.save();
              if (_formKeyComment.currentState.validate()) {
                _addComment(commentController.text);
              }
            },
            child: Text(
              "SUBMIT",
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Colors.white, fontSize: 16),
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
                globals.myText(text: "--   ", color: "disabled", size: 16),
                globals.myText(
                    text: "FORUM PRODUK", color: "dark", size: 16, weight: "B"),
                globals.myText(
                    text: " (${animal.auction.countComments} comment)",
                    color: "disabled",
                    size: 16),
                globals.myText(text: "   --", color: "disabled", size: 16),
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
            Form(key: _formKeyComment, child: textAddComment()),
            Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    _addComment("UP");
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: globals.myText(text: "UP", color: "light", size: 15),
                  color: globals.myColor("primary"),
                ),
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(_scaffoldKey, context),
      body: Scaffold(
        key: _scaffoldKey,
        drawer: drawer(context),
        body: isLoading
            ? globals.isLoading()
            : SafeArea(
                child: ListView(
                  children: <Widget>[
                    _buildImage(),
                    SizedBox(
                      height: 8,
                    ),
                    _buildDesc(),
                    SizedBox(
                      height: 8,
                    ),
                    // If the logged in was the auction owner or the auction has been inactive, hide element
                    animal.ownerUserId == globals.user.id ||
                            animal.auction.active == 0
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
                    animal.ownerUserId == globals.user.id ||
                            animal.auction.active == 0
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
