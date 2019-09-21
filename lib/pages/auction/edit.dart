import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/services/auction_services.dart';

class EditAuctionPage extends StatefulWidget {
  final int animalId;
  final String description;
  EditAuctionPage(
      {Key key, @required this.animalId, @required this.description})
      : super(key: key);
  @override
  _EditAuctionPageState createState() =>
      _EditAuctionPageState(animalId, description);
}

class _EditAuctionPageState extends State<EditAuctionPage> {
  TextEditingController descController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  int animalId;

  _EditAuctionPageState(int animalId, String desc) {
    this.animalId = animalId;

    descController.text = desc;
  }

  Widget _topHeader() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        padding: EdgeInsets.symmetric(vertical: 10),
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Text(
            "Ubah Lelang",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ));
  }

  Widget _textFieldDeskripsi() {
    return Container(
        width: globals.mw(context) * 0.95,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: TextFormField(
          controller: descController,
          keyboardType: TextInputType.multiline,
          maxLines: 8,
          onFieldSubmitted: (String value) {},
          validator: (value) {
            if (value.isEmpty) {
              return 'Deskripsi wajib diisi';
            }
          },
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(13),
              hintText:
                  "Tuliskan deskripsi, jenis pengiriman dan catatan penting lainnya",
              labelText: "Deskripsi",
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
        ));
  }

  Widget _buttonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton.icon(
          icon: Icon(
            Icons.edit,
            color: Colors.white,
          ),
          color: globals.myColor("primary"),
          label: globals.myText(text: "Edit Lelang", color: "light"),
          onPressed: () async {
            _formKey.currentState.save();
            if (_formKey.currentState.validate()) {
              var animal = {"id": animalId, "description": descController.text};

              try {
                globals.loadingModel(context);
                final result = await editDescAuction(
                    globals.user.tokenRedis, animal, animalId);
                Navigator.pop(context);
                if (result == 1) {
                  globals.showDialogs(
                    "Deskripsi berhasil diubah",
                    context,
                    isDouble: true
                  );
                } else if (result == 2) {
                  await globals.showDialogs(
                      "Session anda telah berakhir, Silakan melakukan login ulang",
                      context,
                      isLogout: true);
                  return;
                } else {
                  globals.showDialogs(
                      "Terjadi kesalahan, coba untuk hubungi admin", context);
                }
              } catch (e) {
                Navigator.pop(context);
                globals.showDialogs(
                    "Terjadi kesalahan, coba untuk hubungi admin", context);
                globals.debugPrint(e.toString());
                globals.mailError("Edit desc auction", e.toString());
              }
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
        body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _topHeader(),
              _textFieldDeskripsi(),
              _buttonBar()
            ],
          ),
        ));
  }
}
