import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/transaction.dart';
import 'package:jlf_mobile/pages/transaction/edit.dart';
import 'package:jlf_mobile/services/transaction_services.dart';

class TransactionDetailPage extends StatefulWidget {
  final int transactionId;
  TransactionDetailPage({this.transactionId});

  @override
  _TransactionDetailPageState createState() =>
      _TransactionDetailPageState(transactionId);
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  Transaction transaction = Transaction();
  int transactionId = null;

  _TransactionDetailPageState(transactionId) {
    this.transactionId = transactionId;
  }

  @override
  void initState() {
    super.initState();
    _refresh();
    globals.getNotificationCount();
  }

  _refresh() async {
    if (transactionId != null) {
      setState(() => isLoading = true);
      transaction = await get(transactionId, globals.user.tokenRedis);

      if (transaction == null) {
        debugPrint("Transaction Not Found");
      } else {
        debugPrint(transaction.toJson().toString());
      }

      setState(() => isLoading = false);
    } else {
      debugPrint("Transaction Not found");
    }
  }

  Widget _textContainer(String title, String value) {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        width: globals.mw(context) * 0.95,
        child: Wrap(
          children: <Widget>[
            globals.myText(text: "$title: ", weight: "B"),
            globals.myText(text: value)
          ],
        ));
  }

  Widget _buildSellerForm() {
    // double totalPrice = 0;

    // if (transaction.price != null) {
    //   totalPrice += transaction.price;
    // }

    // if (transaction.servicePrice != null) {
    //   totalPrice += transaction.servicePrice;
    // }

    // if (transaction.deliveryPrice != null) {
    //   totalPrice += transaction.deliveryPrice;
    // }

    return Container(
        child: Column(
      children: <Widget>[
        Container(
            width: globals.mw(context),
            child: RaisedButton(
              child: globals.myText(
                  text: "FORM PENJUAL (SELLER)", weight: "B", color: "light"),
              color: globals.myColor("primary"),
              onPressed: () => null,
            )),
        SizedBox(height: 10),
        _textContainer(
            "Nama", globals.printWhenNotNull(transaction.seller.name)),
        _textContainer(
            "Username", globals.printWhenNotNull(transaction.seller.username)),
        _textContainer(
            "Hewan/Produk", globals.printWhenNotNull(transaction.animal.name)),
        _textContainer("Kategori",
            "${globals.printWhenNotNull(transaction.animal.animalSubCategory.animalCategory.name)}/${globals.printWhenNotNull(transaction.animal.animalSubCategory.name)}"),
        _textContainer(
            "Jumlah", globals.printWhenNotNull(transaction.quantity)),
        _textContainer(
            "Garansi", globals.printWhenNotNull(transaction.guarantee)),
        _textContainer(
            "Nominal",
            
            transaction.price != null
                ? "Rp. " + globals.convertToMoney(transaction.price.toDouble())
                : "-"),
        _textContainer("Ekspedisi Pengiriman",
            globals.printWhenNotNull(transaction.expeditionName)),
        _textContainer(
            "Ongkos Kirim (Include Packing)",
            transaction.deliveryPrice != null
                ? "Rp. " + globals.convertToMoney(transaction.deliveryPrice.toDouble())
                : "-"),
        _textContainer(
            "Bank", globals.printWhenNotNull(transaction.sellerBankName)),
        _textContainer("Rekening Atas Nama",
            globals.printWhenNotNull(transaction.sellerBankAccountName)),
        _textContainer("Nomor Rekening",
            globals.printWhenNotNull(transaction.sellerBankAccountNumber)),
        _textContainer("Tanggal Pengiriman",
            globals.convertFormatDate(transaction.deliveryDate)),
        _textContainer("Tanggal Estimasi Sampai",
            globals.convertFormatDate(transaction.receivedDateEstimation)),
        globals.user.id == transaction.sellerUserId
            ? Container(
                width: 100,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: FlatButton(
                    onPressed: () async {
                      await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      TransactionEditPage(
                                          transaction: transaction)));
                      this._refresh();
                    },
                    child: globals.myText(text: "UBAH", color: "light"),
                    color: isLoading
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))))
            : Container(),
      ],
    ));
  }

  Widget _buildBuyerForm() {
    return Container(
        child: Column(children: <Widget>[
      Container(
          width: globals.mw(context),
          child: RaisedButton(
            child: globals.myText(
                text: "FORM PEMBELI (BUYER)", weight: "B", color: "light"),
            color: globals.myColor("primary"),
            onPressed: () => null,
          )),
      SizedBox(height: 10),
      _textContainer("Nama", globals.printWhenNotNull(transaction.buyer.name)),
      _textContainer(
          "Username", globals.printWhenNotNull(transaction.buyer.username)),
      _textContainer("Alamat Pengiriman",
          globals.printWhenNotNull(transaction.buyerAddress)),
      _textContainer(
          "Bank", globals.printWhenNotNull(transaction.buyerBankName)),
      _textContainer("Rekening Atas Nama",
          globals.printWhenNotNull(transaction.buyerBankAccountName)),
      _textContainer("Nomor Rekening",
          globals.printWhenNotNull(transaction.buyerBankAccountNumber)),
      globals.user.id == transaction.buyerUserId
          ? Container(
              width: 100,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: FlatButton(
                  onPressed: () async {
                      await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      TransactionEditPage(
                                          transaction: transaction)));
                      this._refresh();
                    },
                  child: globals.myText(text: "UBAH", color: "light"),
                  color:
                      isLoading ? Colors.grey : Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))))
          : Container(),
    ]));
  }

  Widget _buildDetail() {
    return Container(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          children: <Widget>[
            _textContainer("No. Invoice",
                globals.printWhenNotNull(transaction.invoiceNumber)),
            _textContainer(
                "Biaya Rekber",
                transaction.servicePrice != null
                    ? "Rp. " + globals
                        .convertToMoney(transaction.servicePrice.toDouble())
                    : "-"),
            globals.user.id == transaction.adminUserId || globals.user.roleId == 1
            ? Container(
                
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: FlatButton(
                    onPressed: () async {
                        await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        TransactionEditPage(
                                            transaction: transaction)));
                        this._refresh();
                      },
                    child: globals.myText(text: "Lengkapi Form Rekber Saya", color: "light"),
                    color:
                        isLoading ? Colors.grey : Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))))
            : Container()
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true, showNotification: false),
        body: Scaffold(
            key: _scaffoldKey,
            body: SafeArea(
                child: isLoading
                    ? Center(child: globals.isLoading())
                    : ListView(children: <Widget>[
                        Container(
                            width: globals.mw(context),
                            child: Column(
                              children: <Widget>[
                                _buildDetail(),
                                _buildSellerForm(),
                                _buildBuyerForm()
                              ],
                            )),
                      ]))));
  }
}
