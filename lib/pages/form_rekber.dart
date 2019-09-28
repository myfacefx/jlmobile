import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;

class FormRekberPage extends StatefulWidget {
  @override
  _FormRekberPageState createState() => _FormRekberPageState();
}

class _FormRekberPageState extends State<FormRekberPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    globals.getNotificationCount();
  }

  Widget _buildSellerForm() {
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
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: globals.mw(context) * 0.95,
            child: globals.myText(text: "Nama: Suharto Kuro")),
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: globals.mw(context) * 0.95,
            child: globals.myText(text: "Username: kuroniko")),
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: globals.mw(context) * 0.95,
            child: globals.myText(text: "Nama Hewan: Kura-Kura Ninja")),
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: globals.mw(context) * 0.95,
            child: globals.myText(text: "Kategori: Kura-Kura/Kura-Kura Darat")),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              onSaved: (String value) {
                // _name = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context)
                //       .requestFocus(descriptionFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Jumlah tidak boleh kosong';
                }
              },
              style: TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.number,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Jumlah",
                  labelText: "Jumlah Hewan/Produk (Quantity)",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              onSaved: (String value) {
                // _name = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context)
                //       .requestFocus(descriptionFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Garansi tidak boleh kosong';
                }
              },
              style: TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText:
                      "Jelaskan garansi yang anda berikan untuk produk ini",
                  labelText: "Garansi",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: globals.mw(context) * 0.95,
            child: globals.myText(text: "Nominal Lelang: Rp. 1.000.000")),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              onSaved: (String value) {
                // _name = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context)
                //       .requestFocus(descriptionFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Nama ekspedisi tidak boleh kosong';
                }
              },
              style: TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Nama Ekspedisi Pengiriman",
                  labelText: "Nama Ekspedisi Pengiriman",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              onSaved: (String value) {
                // _name = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context)
                //       .requestFocus(descriptionFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Biaya pengiriman tidak boleh kosong';
                }
              },
              style: TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.number,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Biaya Pengiriman",
                  labelText: "Biaya Pengiriman",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: globals.mw(context) * 0.95,
            child: globals.myText(text: "Biaya Rekber: Rp. 15.000")),
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: globals.mw(context) * 0.95,
            child: globals.myText(text: "Total Biaya: Rp. 1.515.000")),
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: globals.mw(context) * 0.95,
            child: globals.myText(text: "Poin Yang Didapat: 2 Poin")),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              onSaved: (String value) {
                // _name = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context)
                //       .requestFocus(descriptionFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Nama bank tidak boleh kosong';
                }
              },
              style: TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Nama Bank",
                  labelText: "Nama Bank",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              onSaved: (String value) {
                // _name = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context)
                //       .requestFocus(descriptionFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Nama pemilik rekening tidak boleh kosong';
                }
              },
              style: TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Nama Sesuai Buku Rekening",
                  labelText: "Nama Sesuai Buku Rekening",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              onSaved: (String value) {
                // _name = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context)
                //       .requestFocus(descriptionFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Tanggal pengiriman tidak boleh kosong';
                }
              },
              style: TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Tanggal Pengiriman",
                  labelText: "Tanggal Pengiriman",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              onSaved: (String value) {
                // _name = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context)
                //       .requestFocus(descriptionFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Tanggal estimasi sampai tidak boleh kosong';
                }
              },
              style: TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Tanggal Estimasi Sampai",
                  labelText: "Tanggal Estimasi Sampai",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
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
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: globals.mw(context) * 0.95,
            child: globals.myText(text: "Nama: Suharto Kuro")),
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: globals.mw(context) * 0.95,
            child: globals.myText(text: "Username: kuroniko")),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              onSaved: (String value) {
                // _name = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context)
                //       .requestFocus(descriptionFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Alamat pengiriman tidak boleh kosong';
                }
              },
              style: TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText:
                      "Alamat pengiriman",
                  labelText: "Alamat pengiriman",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              onSaved: (String value) {
                // _name = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context)
                //       .requestFocus(descriptionFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Nama bank tidak boleh kosong';
                }
              },
              style: TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Nama Bank",
                  labelText: "Nama Bank",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              onSaved: (String value) {
                // _name = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context)
                //       .requestFocus(descriptionFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Nama pemilik rekening tidak boleh kosong';
                }
              },
              style: TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Nama Sesuai Buku Rekening",
                  labelText: "Nama Sesuai Buku Rekening",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
        body: Scaffold(
            key: _scaffoldKey,
            body: SafeArea(
                child: ListView(children: <Widget>[
              Container(
                  width: globals.mw(context),
                  child: Column(
                    children: <Widget>[_buildSellerForm(), _buildBuyerForm()],
                  )),
            ]))));
  }
}
