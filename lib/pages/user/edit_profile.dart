import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/province.dart';
import 'package:jlf_mobile/models/regency.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/province_services.dart';
import 'package:jlf_mobile/services/regency_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jlf_mobile/services/user_services.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferences prefs;
  final _formKey = GlobalKey<FormState>();

  bool autoValidate = false;
  bool passwordVisibility = true;
  bool confirmPasswordVisibility = true;

  bool registerLoading = false;
  bool regencyLoading = false;

  FocusNode usernameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  int _id;
  String _name;
  String _description;
  String _password;
  String _phoneNumber;
  Province _province;
  Regency _regency;

  List<Province> provinces = List<Province>();
  List<Regency> regencies = List<Regency>();

  @override
  void initState() {
    super.initState();

    if (globals.user != null) {
      _name = globals.user.name;
      _description = globals.user.description;
      _id = globals.user.id;
      _phoneNumber = globals.user.phoneNumber;
    } else {
      Navigator.of(context).pop();
    }
    globals.getNotificationCount();

    getProvinces("token").then((value) {
      provinces = value;
      provinces.forEach((province) {
        if (province.id == globals.user.regency.provinceId) {
          setState(() {
            _province = province;
          });
        }
      });
      setState(() {
        this.registerLoading = false;
      });
    });

    getRegenciesByProvinceId("token", globals.user.regency.provinceId)
        .then((onValue) {
      setState(() {
        regencies = onValue;
        regencies.forEach((regency) {
          if (regency.id == globals.user.regency.id) {
            setState(() {
              _regency = regency;
            });
          }
        });

        this.regencyLoading = false;
      });
    });
    //_updateRegencies(_regency.provinceId);
  }

  _updateRegencies() {
    regencies = List<Regency>();
    _regency = null;
    this.regencyLoading = true;
    getRegenciesByProvinceId("token", _province.id).then((onValue) {
      setState(() {
        regencies = onValue;
        this.regencyLoading = false;
      });
    });
  }

  Widget _buildBackground() {
    return Center(
      child: Image.asset(
        'assets/images/jlf-back.png',
        width: globals.mw(context),
        height: globals.mh(context),
        fit: BoxFit.fill,
      ),
    );
  }

  void _register() async {
    if (registerLoading) return;

    if (_formKey.currentState.validate()) {
      setState(() {
        registerLoading = true;
      });

      _formKey.currentState.save();

      User updateUser = User();
      updateUser.name = _name;
      updateUser.description = _description;
      updateUser.regencyId = _regency.id;
      updateUser.phoneNumber = _phoneNumber;

      try {
        String result = await update(updateUser.toJson(), _id);

        if (result != null) {
          globals.user.name = _name;
          globals.user.description = _description;
          globals.user.regencyId = _regency.id;
          globals.user.phoneNumber = _phoneNumber;

          Navigator.of(context).pop();
          globals.showDialogs(result, context);
        } else {
          globals.showDialogs("Terjadi error, silahkan ulangi", context);
          setState(() {
            registerLoading = false;
            autoValidate = true;
          });
        }
      } catch (e) {
        globals.showDialogs("Terjadi error, silahkan ulangi", context);
        setState(() {
          registerLoading = false;
          autoValidate = true;
        });
      }
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }

  Widget _fullname() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: TextFormField(
          initialValue: _name,
          onSaved: (String value) {
            _name = value;
          },
          onFieldSubmitted: (String value) {
            if (value.length > 0) {
              FocusScope.of(context).requestFocus(usernameFocusNode);
            }
          },
          style: TextStyle(color: Colors.black),
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(13),
              hintText: "Nama Pengguna",
              labelText: "Nama Pengguna",
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
        ));
  }

  Widget _descriptionInput() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: TextFormField(
          initialValue: _description,
          focusNode: usernameFocusNode,
          onSaved: (String value) {
            _description = value;
          },
          onFieldSubmitted: (String value) {
            if (value.length > 0) {
              FocusScope.of(context).requestFocus(passwordFocusNode);
            }
          },
          validator: (value) {
            if (value.isEmpty || value.length < 5 || value.length > 100) {
              return 'Deskripsi panjang 5 hingga 100 huruf';
            }
          },
          style: TextStyle(color: Colors.black),
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          maxLines: 8,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(13),
              hintText: "Deskripsi",
              labelText: "Deskripsi",
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
        ));
  }

  Widget _provinceInput() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: DropdownButtonFormField<Province>(
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: EdgeInsets.all(13),
              hintText: "Provinsi",
              labelText: "Provinsi"),
          value: _province,
          validator: (province) {
            if (province == null) {
              return 'Silahkan pilih provinsi';
            }
          },
          onChanged: (Province province) {
            setState(() {
              _province = province;
            });
            _updateRegencies();
            // FocusScope.of(context)
            //   .requestFocus(regencyFocusNode);
          },
          items: provinces.map((Province province) {
            return DropdownMenuItem<Province>(
                value: province,
                child:
                    Text(province.name, style: TextStyle(color: Colors.black)));
          }).toList(),
        ));
  }

  Widget _regencyInput() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: DropdownButtonFormField<Regency>(
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: EdgeInsets.all(13),
              hintText: "Kota/Kabupaten",
              labelText: "Kota/Kabupaten"),
          onChanged: (Regency regency) {
            setState(() {
              _regency = regency;
            });
          },
          value: _regency,
          validator: (regency) {
            if (regency == null) {
              return 'Silahkan pilih wilayah kota/kabupaten';
            }
          },
          items: regencies.map((Regency regency) {
            return DropdownMenuItem<Regency>(
                value: regency,
                child: Text(
                  regency.name,
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ));
          }).toList(),
        ));
  }

  Widget _phoneNumberInput() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: TextFormField(
          initialValue: _phoneNumber,
          onSaved: (String value) {
            _phoneNumber = value;
          },
          validator: (value) {
            if (value.isEmpty || value.length < 10 || value.length > 13) {
              return 'Silahkan masukkan digit yang sesuai 10-13 digit';
            }
          },
          keyboardType: TextInputType.number,
          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(13),
              hintText: "Format 08xx",
              labelText: "Nomor Handphone (WA)",
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
        ));
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
                child: Text("Edit Profil",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 23))),
            Form(
              autovalidate: autoValidate,
              key: _formKey,
              child: Column(children: <Widget>[
                _fullname(),
                _descriptionInput(),
                _provinceInput(),
                regencyLoading ? globals.isLoading() : _regencyInput(),
                _phoneNumberInput(),

                // Container(
                //     width: 300,
                //     padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                //     child: TextFormField(
                //       focusNode: passwordFocusNode,
                //       onSaved: (String value) {
                //         _password = value;
                //       },
                //       controller: passwordController,
                //       onFieldSubmitted: (String value) {
                //         if (value.length > 0) {
                //           FocusScope.of(context)
                //               .requestFocus(confirmPasswordFocusNode);
                //         }
                //       },
                //       validator: (value) {
                //         if (value.isEmpty ||
                //             value.length < 8 ||
                //             value.length > 12) {
                //           return 'Password minimal 8 maksimal 12 huruf';
                //         }
                //       },
                //       obscureText: passwordVisibility,
                //       style: TextStyle(color: Colors.black),
                //       decoration: InputDecoration(
                //           contentPadding: EdgeInsets.all(13),
                //           suffixIcon: GestureDetector(
                //             onTap: () {
                //               setState(() {
                //                 passwordVisibility = !passwordVisibility;
                //               });
                //             },
                //             child: Icon(passwordVisibility
                //                 ? Icons.visibility
                //                 : Icons.visibility_off),
                //           ),
                //           hintText: "Password",
                //           labelText: "Password",
                //           fillColor: Colors.white,
                //           border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(20))),
                //     )),
                // Container(
                //     width: 300,
                //     padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                //     child: TextFormField(
                //       focusNode: confirmPasswordFocusNode,
                //       controller: confirmPasswordController,
                //       obscureText: confirmPasswordVisibility,
                //       validator: (value) {
                //         if (value != passwordController.text) {
                //           return 'Password tidak sesuai';
                //         }
                //       },
                //       onFieldSubmitted: (String value) {
                //         _register();
                //       },
                //       style: TextStyle(color: Colors.black),
                //       decoration: InputDecoration(
                //           contentPadding: EdgeInsets.all(13),
                //           suffixIcon: GestureDetector(
                //             onTap: () {
                //               setState(() {
                //                 confirmPasswordVisibility =
                //                     !confirmPasswordVisibility;
                //               });
                //             },
                //             child: Icon(confirmPasswordVisibility
                //                 ? Icons.visibility
                //                 : Icons.visibility_off),
                //           ),
                //           hintText: "Ulangi Password",
                //           labelText: "Ulangi Password",
                //           fillColor: Colors.white,
                //           border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(20))),
                //     )),
                Container(
                    width: 300,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: FlatButton(
                        onPressed: () => registerLoading ? null : _register(),
                        child: Text(
                            !registerLoading
                                ? "Perbaharui Profil"
                                : "Mohon Tunggu",
                            style: Theme.of(context).textTheme.display4),
                        color: registerLoading
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)))),
              ]),
            ),
          ])
        ])),
      ),
    );
  }
}
