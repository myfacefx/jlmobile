import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/province.dart';
import 'package:jlf_mobile/models/regency.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/services/user_services.dart';

class EditPasswordPage extends StatefulWidget {
  @override
  _EditPasswordPageState createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  bool autoValidate = false;
  bool passwordVisibility = true;
  bool confirmPasswordVisibility = true;

  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  int _id;
  String _name;
  String _description;
  String _password;
  String _phoneNumber;
  Province _province;
  Regency _regency;

  @override
  void initState() {
    super.initState();

    if (globals.user != null) {
      _name = globals.user.name;
      _description = globals.user.description;
      _id = globals.user.id;
      _phoneNumber = globals.user.phoneNumber;
      _regency = globals.user.regency;
      _province = globals.user.province;
    } else {
      Navigator.of(context).pop();
    }
    globals.getNotificationCount();
  }

  void _updatePassword() async {
    if (isLoading) return;

    _formKey.currentState.save();

    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      User updateUser = User();
      updateUser.password = _password;

      try {
        String result = await updateUserLogin(
            updateUser.toJson(), _id, globals.user.tokenRedis);

        if (result != null) {
          Navigator.of(context).pop();
          globals.showDialogs(result, context);
        } else {
          await globals.showDialogs(
              "Session anda telah berakhir, Silakan melakukan login ulang",
              context,
              isLogout: true);
          return;
        }
      } catch (e) {
        globals.showDialogs("Terjadi error, silahkan ulangi", context);
        globals.mailError("edit password", e.toString());
        setState(() {
          isLoading = false;
          autoValidate = true;
        });
      }
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }

  Widget _buildChangePassword() {
    return Column(children: <Widget>[
      Container(
          width: 300,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: TextFormField(
            focusNode: passwordFocusNode,
            onSaved: (String value) {
              _password = value;
            },
            controller: passwordController,
            onFieldSubmitted: (String value) {
              if (value.length > 0) {
                FocusScope.of(context).requestFocus(confirmPasswordFocusNode);
              }
            },
            validator: (value) {
              if (value.isEmpty || value.length < 8 || value.length > 12) {
                return 'Password minimal 8 maksimal 12 karakter';
              }
            },
            obscureText: passwordVisibility,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(13),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      passwordVisibility = !passwordVisibility;
                    });
                  },
                  child: Icon(passwordVisibility
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
                hintText: "Password Baru",
                labelText: "Password Baru",
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
          )),
      Container(
          width: 300,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: TextFormField(
            focusNode: confirmPasswordFocusNode,
            controller: confirmPasswordController,
            obscureText: confirmPasswordVisibility,
            validator: (value) {
              if (value != passwordController.text) {
                return 'Password tidak sesuai';
              }
            },
            onFieldSubmitted: (String value) {
              _updatePassword();
            },
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(13),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      confirmPasswordVisibility = !confirmPasswordVisibility;
                    });
                  },
                  child: Icon(confirmPasswordVisibility
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
                hintText: "Ulangi Password Baru",
                labelText: "Ulangi Password Baru",
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
          )),
      Container(
          width: 300,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: FlatButton(
              onPressed: () => isLoading ? null : _updatePassword(),
              child: Text(!isLoading ? "Perbaharui Password" : "Mohon Tunggu",
                  style: Theme.of(context).textTheme.display4),
              color: isLoading ? Colors.grey : Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
        body: Scaffold(
            body: Stack(children: <Widget>[
          ListView(children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("Ubah Password",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 23))),
            Form(
              autovalidate: autoValidate,
              key: _formKey,
              child: Column(children: <Widget>[_buildChangePassword()]),
            ),
          ])
        ])),
      ),
    );
  }
}
