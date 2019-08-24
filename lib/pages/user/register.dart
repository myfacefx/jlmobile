import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/province.dart';
import 'package:jlf_mobile/models/regency.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/services/province_services.dart';
import 'package:jlf_mobile/services/regency_services.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:permission_handler/permission_handler.dart';

class RegisterPage extends StatefulWidget {
  final User user;
  RegisterPage({this.user});

  @override
  _RegisterPageState createState() => _RegisterPageState(user);
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  bool autoValidate = false;
  bool passwordVisibility = true;
  bool confirmPasswordVisibility = true;

  bool registerLoading = false;
  bool lockEmailFromFacebook = false;

  FocusNode usernameFocusNode = FocusNode();
  FocusNode nameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  FocusNode provinceFocusNode = FocusNode();
  FocusNode regencyFocusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  User user;

  String _name;
  String _email;
  String _username;
  String _password;
  String _photo;
  String _photoBase64;
  String _gender = "M";
  String _phoneNumber;
  String _facebookUserId;
  Province _province;
  Regency _regency;

  List<Province> provinces = List<Province>();
  List<Regency> regencies = List<Regency>();

  _RegisterPageState(User user) {
    requestPermission();
    if (user != null) {
      if (user.email != null) { // testing purpose 
      // if (user.email != null) {
        this.lockEmailFromFacebook = true;
        this._email = user.email;
      }

      this.user = user;
      // this._name = user.name;
      this._facebookUserId = user.facebookUserId;
      nameController.text = user.name;
      this._photo = user.photo;
    }
  }

  void requestPermission() async {
    print("Checking Permission storage");
    PermissionStatus permissionStorage = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    PermissionStatus permissionCamera =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);

    if (permissionStorage != PermissionStatus.granted &&
        permissionCamera != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions(
          [PermissionGroup.storage, PermissionGroup.camera]);
      requestPermission();
    }
  }

  @override
  void initState() {
    super.initState();

    this.registerLoading = true;

    getProvinces("token").then((value) {
      provinces = value;
      setState(() {
        this.registerLoading = false;
      });
    });
  }

  _updateRegencies() {
    _regency = null;
    regencies = List<Regency>();
    this.registerLoading = true;
    getRegenciesByProvinceId("token", _province.id).then((onValue) {
      setState(() {
        regencies = onValue;
        this.registerLoading = false;
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

  void _handleGenderChange(String value) {
    setState(() {
      _gender = value;
    });
  }

  void _register() async {
    if (registerLoading) return;

    if (_photoBase64 == null && _photo == null) {
      globals.showDialogs("Foto belum dipilih", context);
      return;
    }

    if (_gender == null) {
      globals.showDialogs("Gender belum dipilih", context);
      return;
    }

    _formKey.currentState.save();

    if (_formKey.currentState.validate()) {
      setState(() {
        registerLoading = true;
      });

      //check phone number mush unique
      try {
        final isFound = await getUsersByPhoneNumber(_phoneNumber);
        if (isFound) {
          await globals.showDialogs(
              "Nomer whatsapp sudah digunakan, Silakan coba dengan nomer lain",
              context);
          setState(() {
            registerLoading = false;
          });
          return;
        }
      } catch (e) {
        await globals.showDialogs(
            "Sedang terjadi gangguan, coba lagi atau hubungi admin", context);
        globals.mailError("Check WA", e.toString());
        setState(() {
          registerLoading = false;
        });
        return;
      }

      User user = User();
      user.email = _email;
      user.photo = _photo;
      user.gender = _gender;
      user.name = _name;
      user.username = _username;
      user.password = _password;
      user.regencyId = _regency.id;
      user.phoneNumber = _phoneNumber;
      user.facebookUserId = _facebookUserId;
      user.roleId = 2;

      print(user.toJson());

      Map<String, dynamic> formData = user.toJson();

      formData['photoBase64'] = _photoBase64;

      try {
        // User userResult = await register(user.toJson());
        User userResult = await register(formData);

        if (userResult != null) {
          saveLocalData('user', userToJson(userResult));

          globals.user = userResult;
          globals.state = "home";

          Navigator.of(context).pop();
          Navigator.pushNamed(context, "/");
        }
      } catch (e) {
        print(e);
        globals.showDialogs(e.toString(), context);
        globals.mailError("Register", e.toString());
        setState(() {
          registerLoading = false;
          autoValidate = true;
        });
      }
    } else {
      globals.showDialogs(
          "Form kurang lengkap/masih kurang sesuai, silahkan cek kembali",
          context);
      setState(() {
        autoValidate = true;
      });
    }
  }

  Future _chooseProfilePicture() async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      // print(imageFile);
      _cropImage(imageFile);
      // uploadFile();
    }
  }

  Future<Null> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 150,
      maxHeight: 150,
    );

    File compressedFile = await FlutterNativeImage.compressImage(imageFile.path,
        quality: 30, percentage: 100);

    List<int> imageBytes = compressedFile.readAsBytesSync();

    String base64Image = base64Encode(imageBytes);

    setState(() {
      _photoBase64 = base64Image;
    });
  }

  //  Future<Null> _uploadPhoto(File imageFile) async {
  //   List<int> imageBytes = imageFile.readAsBytesSync();

  //   String base64Image = base64Encode(imageBytes);

  //   Map<String, dynamic> formData = Map<String, dynamic>();
  //   formData['image_base64'] = base64Image;

  //   String newFileName = globals.user.id.toString() + "-" + _randomDigits(6);
  //   formData['file_name'] = newFileName;

  //   await updateProfilePicture(formData, globals.user.id);

  //   setState(() {
  //     globals.user.photo = globals.getBaseUrl() + "/images/profile_pictures/$newFileName.jpg";
  //   });

  //   globals.showDialogs("Foto berhasil diubah", context);
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(children: <Widget>[
        _buildBackground(),
        ListView(children: <Widget>[
          Container(
              height: globals.mh(context) * 0.3,
              child: Center(
                child: Image.asset("assets/images/logo.png", height: 120),
              )),
          Form(
            autovalidate: autoValidate,
            key: _formKey,
            child: Column(children: <Widget>[
              _photo != null
                  ? FadeInImage.assetNetwork(
                      height: 150,
                      fit: BoxFit.fill,
                      placeholder: 'assets/images/loading.gif',
                      image: _photo)
                  : Container(),
              _photo == null
                  ? GestureDetector(
                      onTap: () => _chooseProfilePicture(),
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                          height: 150,
                          child: CircleAvatar(
                              radius: 100,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: _photoBase64 != null
                                      ? Image.memory(base64Decode(_photoBase64),
                                          fit: BoxFit.cover)
                                      : Image.asset(
                                          'assets/images/account.png')))),
                    )
                  : Container(),
              Container(
                  alignment: Alignment.center,
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: lockEmailFromFacebook
                      ? Text(_email, style: TextStyle(color: Colors.black))
                      : TextFormField(
                          onSaved: (String value) {
                            _email = value;
                          },
                          onFieldSubmitted: (String value) {
                            if (value.length > 0) {
                              FocusScope.of(context)
                                  .requestFocus(usernameFocusNode);
                            }
                          },
                          validator: (value) {
                            Pattern pattern =
                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                            RegExp regex = new RegExp(pattern);
                            if (!regex.hasMatch(value))
                              return 'Email tidak valid';
                            else
                              return null;
                          },
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(13),
                              hintText: "Email",
                              labelText: "Email",
                              // filled: true,
                              // fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20))),
                        )),
              Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextFormField(
                    focusNode: usernameFocusNode,
                    onSaved: (String value) {
                      _username = value;
                    },
                    onFieldSubmitted: (String value) {
                      if (value.length > 0) {
                        FocusScope.of(context).requestFocus(nameFocusNode);
                      }
                    },
                    validator: (value) {
                      if (value.isEmpty ||
                          value.length < 5 ||
                          value.length > 12) {
                        return 'Username minimal 5 maksimal 12 huruf';
                      }
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(13),
                        hintText: "Username",
                        labelText: "Username",
                        // filled: true,
                        // fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  )),
              Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextFormField(
                    controller: nameController,
                    focusNode: nameFocusNode,
                    onSaved: (String value) {
                      _name = value;
                    },
                    onFieldSubmitted: (String value) {
                      if (value.length > 0) {
                        // FocusScope.of(context).requestFocus(passwordFocusNode);
                      }
                    },
                    validator: (value) {
                      if (value.isEmpty || value.length < 3) {
                        return 'Silahkan isi nama lengkap Anda';
                      }
                    },
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(13),
                        hintText: "Nama Lengkap",
                        labelText: "Nama Lengkap",
                        // filled: true,
                        // fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  )),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                        value: "M",
                        onChanged: _handleGenderChange,
                        groupValue: _gender),
                    Text("Laki-Laki", style: TextStyle(color: Colors.black)),
                    Radio(
                        value: "F",
                        onChanged: _handleGenderChange,
                        groupValue: _gender),
                    Text("Perempuan", style: TextStyle(color: Colors.black))
                  ]),
              Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextFormField(
                    focusNode: phoneNumberFocusNode,
                    onSaved: (String value) {
                      _phoneNumber = value;
                    },
                    onFieldSubmitted: (String value) {
                      if (value.length > 0) {
                        FocusScope.of(context).requestFocus(passwordFocusNode);
                      }
                    },
                    validator: (value) {
                      if (value.isEmpty ||
                          value.length < 10 ||
                          value.length > 13) {
                        return 'Silahkan masukkan digit yang sesuai 10-13 digit';
                      }
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(13),
                        hintText: "Format 08xx",
                        labelText: "Nomor Handphone (WA)",
                        // filled: true,
                        // fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  )),
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
                        FocusScope.of(context)
                            .requestFocus(confirmPasswordFocusNode);
                      }
                    },
                    validator: (value) {
                      if (value.isEmpty ||
                          value.length < 8 ||
                          value.length > 12) {
                        return 'Password minimal 8 maksimal 12 huruf';
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
                        hintText: "Password",
                        labelText: "Password",
                        // filled: true,
                        // fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
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
                      // FocusScope.of(context).requestFocus(regencyFocusNode);
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(13),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              confirmPasswordVisibility =
                                  !confirmPasswordVisibility;
                            });
                          },
                          child: Icon(confirmPasswordVisibility
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        hintText: "Ulangi Password",
                        labelText: "Ulangi Password",
                        // filled: true,
                        // fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  )),
              Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: DropdownButtonFormField<Province>(
                    decoration: InputDecoration(
                        // filled: true,
                        // fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
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
                          child: Text(province.name,
                              style: TextStyle(color: Colors.black)));
                    }).toList(),
                  )),
              Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: DropdownButtonFormField<Regency>(
                    decoration: InputDecoration(
                        // filled: true,
                        // fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
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
                          child: Container(
                              child: globals.myText(
                                  text: regency.name,
                                  size: 16,
                                  textOverflow: TextOverflow.ellipsis)));
                      // child: Text(regency.name,
                      // style: TextStyle(color: Colors.black)));
                    }).toList(),
                  )),
              Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: FlatButton(
                      onPressed: () => registerLoading ? null : _register(),
                      child: Text(!registerLoading ? "Daftar" : "Mohon Tunggu",
                          style: Theme.of(context).textTheme.display4),
                      color: registerLoading
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)))),
              Container(
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text("Kembali ke halaman login",
                          style: TextStyle(color: Colors.grey)))),
              SizedBox(height: 20),
              // FlatButton(
              //     onPressed: () => setState(() {
              //           registerLoading = false;
              //         }),
              //     child: Text("RESET"))
            ]),
          ),
        ]),
        Positioned(
          child: Align(
            alignment: Alignment.center,
            child: !registerLoading
                ? Container()
                : Container(child: Center(child: CircularProgressIndicator())),
          ),
        )
      ])),
    );
  }
}
