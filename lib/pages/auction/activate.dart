import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/animal_image.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/animal_category_services.dart';
import 'package:jlf_mobile/models/auction.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/animal_sub_category_services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ActivateAuctionPage extends StatefulWidget {
  final int animalId;

  ActivateAuctionPage({@required this.animalId});

  @override
  _ActivateAuctionPageState createState() => _ActivateAuctionPageState(animalId);
}

class _ActivateAuctionPageState extends State<ActivateAuctionPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>(); 

  bool autoValidate = false;
  bool passwordVisibility = true;
  bool confirmPasswordVisibility = true;

  bool isLoading = true;

  FocusNode usernameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController openBidController = TextEditingController();
  TextEditingController multiplyController = TextEditingController();
  TextEditingController binController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();

  List<AnimalCategory> animalCategories = List<AnimalCategory>();
  AnimalCategory _animalCategory;

  List<AnimalSubCategory> animalSubCategories = List<AnimalSubCategory>();
  // AnimalSubCategory _animalSubCategory;

  var images_base64 = List<String>();

  String _name;
  String _description;
  String _openBid;
  String _bin;
  String _multiply;
  String _bidType;
  String _auctionExpiryDateType;
  String _gender = "M";
  DateTime _dateOfBirth;

  List<String> auctionTypes = ["24 Jam", "48 Jam"];

  List<Asset> images = List<Asset>();
  String _error;

  int _postToAuction = 1;

  // int _id;
  // String _name;
  // String _email;
  // String _username;
  // String _password;

  Animal animal;
  int animalId;

  @override
  void initState() {
    super.initState();

    this.isLoading = true;
  }

  _ActivateAuctionPageState(int animalId) {
    this.animalId = animalId;

    isLoading = true;
    getAnimalById("token", animalId).then((onValue) {
      animal = onValue;
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      print(onError.toString());
    }).then((_) {
      this._name = animal.name;
      this._animalCategory = animal.animalSubCategory.animalCategory;
      this._animalCategory = animal.animalSubCategory.animalCategory;
      // getAnimalCategory("token").then((onValue) {
      //   animalCategories = onValue;
      //   setState(() {
      //     isLoading = false;
      //   });
      // }).catchError((onError) {
      //   // failedDataCategories = true;
      // }).then((_) {
      //   // isLoadingCategories = false;

      //   if (!mounted) return;
      //   setState(() {
      //     isLoading = false;
      //   });
      // });
      // _getAnimalSubCategories(animal.animalSubCategory);
      // this._animalSubCategory = animal.animalSubCategory;
      this._description = animal.description;
      this._gender = animal.gender;
      this._dateOfBirth = animal.dateOfBirth;

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  // Future<Null> _selectDate(BuildContext context) async {
  //   final DateTime picked = await showDatePicker(
  //       context: context,
  //       initialDate: DateTime.now(),
  //       lastDate: DateTime.now(),
  //       firstDate: DateTime(2000, 1),
  //       builder: (BuildContext context, Widget child) {
  //         return Theme(
  //           data: ThemeData.dark(),
  //           child: child,
  //         );
  //       });

  //   if (picked != null) {
  //     setState(() {
  //       _dateOfBirth = picked;
  //       dateOfBirthController.text = _dateOfBirth.day.toString() + "-" + _dateOfBirth.month.toString() + "-" + _dateOfBirth.year.toString();
  //     });
  //   }
  // }

  // _getAnimalSubCategories(setId) {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   if (_animalCategory != null) {
  //     getAnimalSubCategoryByCategoryId("token", _animalCategory.id)
  //         .then((onValue) {
  //       animalSubCategories = onValue;
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }).catchError((onError) {
  //       // failedDataCategories = true;
  //     }).then((_) {
  //       // isLoadingCategories = false;
  //       // if (setId != null) this._animalSubCategory = animal.animalSubCategory;
  //       if (!mounted) return;
  //       setState(() {
  //         isLoading = false;
  //       });
  //     });
  //   } else {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  Widget _buildGridViewImages() {
    return Container(
      padding: EdgeInsets.all(5),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        children: List.generate(images.length, (index) {
          Asset asset = images[index];
          return Container(
            padding: EdgeInsets.all(5),
            child: AssetThumb(
              asset: asset,
              width: 300,
              height: 300,
            ),
          );
        }),
      ),
    );
  }

  Future<void> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 3,
      );
    } on PlatformException catch (e) {
      error = e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      // if (error == null) _error = 'No Error Detected';
    });

    _generateImageBase64();
  }

  _generateImageBase64() async {
    images_base64 = List<String>();

    for (int i = 0; i < images.length; i++) {
      ByteData byteData = await images[i].requestOriginal(quality: 75);

      List<int> imageData = byteData.buffer.asUint8List();
      // byteData.buffer.asByteData();

      images_base64.add(base64Encode(imageData));
    }
  }

  _save() async {
    if (isLoading) return;

    // if (_gender == null) {
    //   globals.showDialogs("Gender belum dipilih", context);
    //   return;
    // }

    // if (images_base64.length == 0) {
    //   globals.showDialogs("Wajib upload foto hewan 1-3 foto", context);
    //   return;
    // }

    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      _formKey.currentState.save();

      Map<String, dynamic> formData = Map<String, dynamic>();

      // Animal animal = Animal();
      // animal.animalSubCategoryId = _animalSubCategory.id;
      // animal.name = _name;
      // animal.gender = _gender;
      // animal.dateOfBirth = _dateOfBirth;
      // animal.description = _description;
      // animal.ownerUserId = globals.user.id;
      // animal.regencyId = globals.user.regencyId;
      // animal.slug = _name + "-" + DateTime.now().toString();

      // formData['animal'] = animal;

      // if (_postToAuction == 1) {
        // If user want to start the auction of the animal
      Auction auction = Auction();

      auction.openBid = int.parse(_openBid);
      auction.multiply = int.parse(_multiply);
      auction.buyItNow = int.parse(_bin);
      auction.expiryDate = _auctionExpiryDateType;
      auction.ownerUserId = globals.user.id;
      auction.active = 1;
      auction.slug = 'test' + "-" + DateTime.now().toString();

      formData['auction'] = auction;

      try {
        bool response = await activate(formData, animal.id);
        print(response);
        if (response) {
          await globals.showDialogs("Berhasil memulai lelang", context);
        } else {
          await globals.showDialogs("Gagal membuat lelang, silahkan ulangi kembali", context);
        }

        Navigator.pop(context);
        Navigator.pushNamed(context, "/profile");
      } catch (e) {
        globals.showDialogs(e.toString(), context);
        print(e);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }

  void _handlePostToAuctionChange(int value) {
    setState(() {
      _postToAuction = value;
    });
  }

  void _handleGenderChange(String value) {
    setState(() {
      _gender = value;
    });
  }

  Widget _buildAnimalImages(List<AnimalImage> animalImages) {
    
    return Container(
      padding: EdgeInsets.all(5),
      child: GridView.count(
        shrinkWrap: true,
        // mainAxisSpacing: ,
        crossAxisCount: 3,
        children: List.generate(animalImages.length, (index) {
          // Asset asset = images[index];

          return Container(
            padding: EdgeInsets.all(5),
            child: Image.network(animalImages[index].image)
            // child: AssetThumb(
            //   asset: asset,
            //   width: 300,
            //   height: 300,
            // ),
          );
        }),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
            drawer: drawer(context),
            key: _scaffoldKey,
            body: Stack(children: <Widget>[
              ListView(children: <Widget>[
                Form(
                  autovalidate: autoValidate,
                  key: _formKey,
                  child: Column(children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        color: Theme.of(context).primaryColor,
                        child: Center(
                          child: Text(
                            "Mulai Lelang",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        )),
                    // Container(
                    //     width: 300,
                    //     padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    //     child: DropdownButtonFormField<AnimalCategory>(
                    //       decoration: InputDecoration(
                    //           fillColor: Colors.white,
                    //           border: OutlineInputBorder(
                    //               borderRadius: BorderRadius.circular(20)),
                    //           contentPadding: EdgeInsets.all(13),
                    //           hintText: "Kategori Hewan",
                    //           labelText: "Kategori Hewan"),
                    //       value: _animalCategory,
                    //       validator: (animalCategory) {
                    //         if (animalCategory == null) {
                    //           return 'Silahkan pilih kategori hewan';
                    //         }
                    //       },
                    //       onChanged: (AnimalCategory category) {
                    //         setState(() {
                    //           _animalCategory = category;
                    //         });
                    //         _getAnimalSubCategories(null);
                    //       },
                    //       items:
                    //           animalCategories.map((AnimalCategory category) {
                    //         return DropdownMenuItem<AnimalCategory>(
                    //             value: category,
                    //             child: Text(category.name,
                    //                 style: TextStyle(color: Colors.black)));
                    //       }).toList(),
                    //     )),
                    // Container(
                    //     width: 300,
                    //     padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    //     child: DropdownButtonFormField<AnimalSubCategory>(
                    //       decoration: InputDecoration(
                    //           fillColor: Colors.white,
                    //           border: OutlineInputBorder(
                    //               borderRadius: BorderRadius.circular(20)),
                    //           contentPadding: EdgeInsets.all(13),
                    //           hintText: "Sub Kategori Hewan",
                    //           labelText: "Sub Kategori Hewan"),
                    //       value: _animalSubCategory,
                    //       validator: (animalSubCategory) {
                    //         if (animalSubCategory == null) {
                    //           return 'Silahkan pilih sub kategori hewan';
                    //         }
                    //       },
                    //       onChanged: (AnimalSubCategory category) {
                    //         setState(() {
                    //           _animalSubCategory = category;
                    //         });
                    //       },
                    //       items: animalSubCategories
                    //           .map((AnimalSubCategory category) {
                    //         return DropdownMenuItem<AnimalSubCategory>(
                    //             value: category,
                    //             child: Text(category.name,
                    //                 style: TextStyle(color: Colors.black)));
                    //       }).toList(),
                    //     )),

                    // Container(
                    //     width: 300,
                    //     padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    //     child: TextFormField(
                    //       controller: nameController,
                    //       onSaved: (String value) {
                    //         _name = value;
                    //       },
                    //       onFieldSubmitted: (String value) {
                    //         // if (value.length > 0) {
                    //         // FocusScope.of(context).requestFocus(usernameFocusNode);
                    //         // }
                    //       },
                    //       validator: (value) {
                    //         if (value.isEmpty) {
                    //           return 'Nama hewan wajib diisi';
                    //         }
                    //       },
                    //       style: TextStyle(color: Colors.black),
                    //       textCapitalization: TextCapitalization.words,
                    //       decoration: InputDecoration(
                    //           contentPadding: EdgeInsets.all(13),
                    //           hintText: "Nama Hewan",
                    //           labelText: "Nama Hewan",
                    //           fillColor: Colors.white,
                    //           border: OutlineInputBorder(
                    //               borderRadius: BorderRadius.circular(20))),
                    //     )),
                    // Container(
                    //   width: 300,
                    //   padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    //   child: TextFormField(
                    //     controller: dateOfBirthController,
                    //     validator: (String value) {
                    //       if (value.isEmpty) return 'Tanggal lahir masih kosong';
                    //     },
                    //     style: TextStyle(color: Colors.black),
                    //     decoration: InputDecoration(
                    //         suffixIcon: GestureDetector(
                    //           onTap: () => _selectDate(context),
                    //           child: Icon(Icons.calendar_today),
                    //         ),
                    //         contentPadding: EdgeInsets.all(13),
                    //         hintText: "Tanggal Lahir",
                    //         labelText: "Tanggal Lahir",
                    //         fillColor: Colors.white,
                    //         border: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(20))),
                    //   )),
                    // Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: <Widget>[
                    //       Radio(
                    //           value: "M",
                    //           onChanged: _handleGenderChange,
                    //           groupValue: _gender),
                    //       Text("Jantan", style: TextStyle(color: Colors.black)),
                    //       Radio(
                    //           value: "F",
                    //           onChanged: _handleGenderChange,
                    //           groupValue: _gender),
                    //       Text("Betina", style: TextStyle(color: Colors.black))
                    //     ]),
                    // Container(
                    //     width: 300,
                    //     padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    //     child: TextFormField(
                    //       // initialValue: _description,
                    //       controller: descriptionController,
                    //       // focusNode: usernameFocusNode,
                    //       onSaved: (String value) {
                    //         _description = value;
                    //       },
                    //       keyboardType: TextInputType.multiline,
                    //       maxLines: 5,
                    //       onFieldSubmitted: (String value) {
                    //         // if (value.length > 0) {
                    //         //   FocusScope.of(context).requestFocus(passwordFocusNode);
                    //         // }
                    //       },
                    //       validator: (value) {
                    //         if (value.isEmpty) {
                    //           return 'Deskripsi wajib diisi';
                    //         }
                    //       },
                    //       textCapitalization: TextCapitalization.sentences,
                    //       style: TextStyle(color: Colors.black),
                    //       decoration: InputDecoration(
                    //           contentPadding: EdgeInsets.all(13),
                    //           hintText: "Deskripsi",
                    //           labelText: "Deskripsi",
                    //           fillColor: Colors.white,
                    //           border: OutlineInputBorder(
                    //               borderRadius: BorderRadius.circular(20))),
                    //     )),
                    // Container(
                    //   width: 150,
                    //   child: RaisedButton(
                    //     shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(20)),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: <Widget>[
                    //         Text("Foto", style: TextStyle(color: Colors.white)),
                    //         Icon(Icons.add_photo_alternate,
                    //             color: Colors.white),
                    //       ],
                    //     ),
                    //     color: Theme.of(context).primaryColor,
                    //     onPressed: loadAssets,
                    //   ),
                    // ),
                    // images != null && images.length > 0
                    //     ? _buildGridViewImages()
                    //     : Container(),
                    // SizedBox(height: 10),
                    Container(
                      child: globals.myText(text: "Kategori", weight: "B", color: 'dark')
                    ),
                    Container(
                    child: globals.myText(text: "${animal != null ? animal.animalSubCategory.animalCategory.name : ""} - ${animal != null ? animal.animalSubCategory.name : ""}", color: 'dark')
                    ), 
                    SizedBox(height: 10),
                    Container(
                      child: globals.myText(text: "Nama Hewan", weight: "B", color: 'dark')
                    ),
                    Container(
                      child: globals.myText(text: "${animal != null ? animal.name : ""}", color: 'dark')
                    ), 
                    SizedBox(height: 10),
                    Container(
                      child: globals.myText(text: "Deskripsi", weight: "B", color: 'dark')
                    ),
                    Container(
                      child: globals.myText(text: "${animal != null ? animal.description : ""}", color: 'dark', align: TextAlign.center)
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: globals.myText(text: "Jenis Kelamin", weight: "B", color: 'dark')
                    ),
                    Container(
                      child: globals.myText(text: "${animal != null ? animal.gender == 'M' ? 'Jantan' : 'Betina' : ""}", color: 'dark')
                    ), 
                    SizedBox(height: 10),
                    Container(
                      child: globals.myText(text: "Foto", weight: "B", color: 'dark')
                    ),
                    animal != null ? _buildAnimalImages(animal.animalImages) : Container(),

                    Divider(),

                    Column(
                      children: <Widget>[
                        Container(
                            width: 300,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  contentPadding: EdgeInsets.all(13),
                                  hintText: "Tipe Lelang",
                                  labelText: "Tipe Lelang"),
                              value: _auctionExpiryDateType,
                              validator: (value) {
                                if (value == null) {
                                  return 'Silahkan pilih tipe lelang';
                                }
                              },
                              onChanged: (String value) {
                                setState(() {
                                  _auctionExpiryDateType = value;
                                });
                              },
                              items: auctionTypes.map((String type) {
                                return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type,
                                        style: TextStyle(
                                            color: Colors.black)));
                              }).toList(),
                            )),
                        Container(
                            width: 300,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: openBidController,
                              // initialValue: _openBid,
                              // focusNode: usernameFocusNode,
                              onSaved: (String value) {
                                _openBid = value;
                              },
                              onFieldSubmitted: (String value) {
                                // if (value.length > 0) {
                                //   FocusScope.of(context).requestFocus(passwordFocusNode);
                                // }
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Harga awal wajib diisi';
                                }

                                if (binController.text.isNotEmpty) {
                                  if (int.parse(value) >=
                                      int.parse(binController.text)) {
                                    return 'Harga awal tidak boleh lebih atau sama dengan harga beli sekarang';
                                  }
                                }
                              },
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(13),
                                  hintText: "Harga Awal",
                                  labelText: "Harga Awal",
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(20))),
                            )),
                        Container(
                            width: 300,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: binController,
                              // initialValue: _bin,
                              // focusNode: usernameFocusNode,
                              onSaved: (String value) {
                                _bin = value;
                              },
                              onFieldSubmitted: (String value) {
                                // if (value.length > 0) {
                                //   FocusScope.of(context).requestFocus(passwordFocusNode);
                                // }
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Harga Beli Sekarang wajib diisi';
                                }
                                if (openBidController.text.isNotEmpty) {
                                  if (int.parse(value) <=
                                      int.parse(openBidController.text)) {
                                    return 'Harga Beli Sekarang tidak boleh kurang atau sama dengan harga awal';
                                  }
                                }
                              },
                              style: TextStyle(color: Colors.black),
                              // keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(13),
                                  hintText: "Beli Sekarang (BIN)",
                                  labelText: "Beli Sekarang (BIN)",
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(20))),
                            )),
                        Container(
                            width: 300,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: multiplyController,
                              // initialValue: _multiply,
                              // focusNode: usernameFocusNode,
                              onSaved: (String value) {
                                _multiply = value;
                              },
                              onFieldSubmitted: (String value) {
                                // if (value.length > 0) {
                                //   FocusScope.of(context).requestFocus(passwordFocusNode);
                                // }
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Harga kelipatan wajib diisi';
                                }

                                if (binController.text.isNotEmpty) {
                                  if (int.parse(value) >=
                                      int.parse(binController.text)) {
                                    return 'Harga kelipatan tidak boleh melebihi atau sama dengan harga beli sekarang';
                                  }
                                }
                              },
                              style: TextStyle(color: Colors.black),
                              // keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(13),
                                  hintText: "Harga Kelipatan",
                                  labelText: "Harga Kelipatan",
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(20))),
                            )),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                        width: 300,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: FlatButton(
                            onPressed: () => isLoading ? null : _save(),
                            child: Text(
                                !isLoading ? "Mulai Lelang" : "Mohon Tunggu",
                                style: Theme.of(context).textTheme.display4),
                            color: isLoading
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)))),
                    SizedBox(height: 20)
                  ]),
                ),
              ]),
              !isLoading
                ? Container()
                : Center(child: CircularProgressIndicator()),
            ])),
      ),
    );
  }
}
