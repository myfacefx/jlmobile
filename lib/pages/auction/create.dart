import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';
import 'package:jlf_mobile/models/product.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/animal_category_services.dart';
import 'package:jlf_mobile/models/auction.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/animal_sub_category_services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class CreateAuctionPage extends StatefulWidget {
  @override
  _CreateAuctionPageState createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool autoValidate = false;
  bool passwordVisibility = true;
  bool confirmPasswordVisibility = true;

  bool isLoading = true;

  FocusNode descriptionFocusNode = FocusNode();
  FocusNode binFocusNode = FocusNode();
  FocusNode multiplyFocusNode = FocusNode();
  FocusNode quantityFocusNode = FocusNode();

  TextEditingController openBidController = TextEditingController();
  TextEditingController multiplyController = TextEditingController();
  TextEditingController binController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();

  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  List<AnimalCategory> animalCategories = List<AnimalCategory>();
  AnimalCategory _animalCategory;

  List<AnimalSubCategory> animalSubCategories = List<AnimalSubCategory>();
  AnimalSubCategory _animalSubCategory;

  var imagesBase64 = List<String>();

  String _name;
  String _description;
  String _openBid;
  String _bin;
  String _multiply;
  String _bidType;
  int _auctionDuration;
  String _gender = "M";
  bool _innerIslandShippingBool = false;
  int _innerIslandShipping = 0;
  DateTime _dateOfBirth;

  String _price;
  String _quantity;

  bool _agreeTerms = false;

  List<int> durations = [3, 6, 12, 24, 48];

  List<Asset> images = List<Asset>();
  String _error;

  int _saveAs = 1;

  @override
  void initState() {
    super.initState();

    this.isLoading = true;

    getAnimalCategory("token").then((onValue) {
      animalCategories = onValue;
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      // failedDataCategories = true;
    }).then((_) {
      // isLoadingCategories = false;

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });

    globals.getNotificationCount();
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
  //       dateOfBirthController.text = _dateOfBirth.day.toString() +
  //           "-" +
  //           _dateOfBirth.month.toString() +
  //           "-" +
  //           _dateOfBirth.year.toString();
  //     });
  //   }
  // }

  _getAnimalSubCategories() {
    setState(() {
      isLoading = true;
    });
    if (_animalCategory != null) {
      getAnimalSubCategoryByCategoryId("token", _animalCategory.id)
          .then((onValue) {
        animalSubCategories = onValue;
        setState(() {
          isLoading = false;
        });
      }).catchError((onError) {
        // failedDataCategories = true;
      }).then((_) {
        // isLoadingCategories = false;

        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildGridViewImages() {
    return images != null && images.length > 0
        ? Container(
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
          )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 30),
            child:
                globals.myText(text: "Belum ada foto terpilih", color: "dark"));
  }

  Future<void> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 2,
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
    imagesBase64 = List<String>();

    for (int i = 0; i < images.length; i++) {
      ByteData byteData = await images[i].requestOriginal(quality: 75);

      List<int> imageData = byteData.buffer.asUint8List();
      // byteData.buffer.asByteData();

      imagesBase64.add(base64Encode(imageData));
    }
  }

  _save() async {
    if (isLoading) return;

    if (!_agreeTerms) {
      globals.showDialogs(
          "Anda harus menyetujui konsekuensi yang akan Anda terima apabila menjual binatang langka/tidak sesuai Undang-Undang",
          context);
      return;
    }

    if (_gender == null) {
      globals.showDialogs("Gender belum dipilih", context);
      return;
    }

    if (imagesBase64.length == 0) {
      globals.showDialogs("Wajib upload foto hewan max 2 foto", context);
      return;
    }

    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      _formKey.currentState.save();

      Map<String, dynamic> formData = Map<String, dynamic>();

      String message = 'Berhasil menambah data hewan';

      Animal animal = Animal();
      animal.animalSubCategoryId = _animalSubCategory.id;
      animal.name = _name;

      // animal.gender = _gender;
      animal.gender = "M";
      // animal.dateOfBirth = _dateOfBirth;
      animal.dateOfBirth = DateTime.now();

      animal.description = _description;
      animal.ownerUserId = globals.user.id;
      animal.regencyId = globals.user.regencyId;
      animal.slug = "${globals.user.id}-" + 'hewan-jlf-' + DateTime.now().toString();

      formData['animal'] = animal;

      if (_saveAs == 1) {
        message = 'Berhasil menambah data hewan, dan memulai lelang';
        // If user want to start the auction of the animal
        Auction auction = Auction();

        auction.openBid = int.parse(_openBid);
        auction.multiply = int.parse(_multiply);
        auction.buyItNow = int.parse(_bin);
        auction.duration = _auctionDuration;
        auction.ownerUserId = globals.user.id;
        auction.active = 1;
        auction.innerIslandShipping = _innerIslandShipping;
        auction.slug = 'lelang-jlf-' + DateTime.now().year.toString() + DateTime.now().month.toString() + DateTime.now().day.toString();

        formData['auction'] = auction;
      } else if (_saveAs == 2) {
        message =
            'Berhasil menambah data hewan, dan memasang sebagai produk jual';
        // If user want to start the auction of the animal
        Product product = Product();

        product.price = int.parse(_price);
        product.quantity = int.parse(_quantity);
        product.ownerUserId = globals.user.id;
        product.status = 'active';
        product.innerIslandShipping = _innerIslandShipping;
        product.slug = 'produk-jlf-' + DateTime.now().year.toString() + DateTime.now().month.toString() + DateTime.now().day.toString();

        formData['product'] = product;
      }

      formData['images'] = imagesBase64;

      try {
        bool response = await create(formData);
        print(response);

        // Map<String, dynamic> finalResponse = jsonDecode(response);

        setState(() {
          isLoading = false;
        });

        await globals.showDialogs(message, context);
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

  void _handleSaveAs(int value) {
    setState(() {
      _saveAs = value;
    });
  }

  void _handleGenderChange(String value) {
    setState(() {
      _gender = value;
    });
  }

  Widget _buildAuction() {
    return Column(
      children: <Widget>[
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Durasi Lelang",
                  labelText: "Durasi Lelang"),
              value: _auctionDuration,
              validator: (value) {
                if (value == null) {
                  return 'Silahkan pilih durasi lelang';
                }
              },
              onChanged: (int value) {
                setState(() {
                  _auctionDuration = value;
                });
              },
              items: durations.map((int type) {
                return DropdownMenuItem<int>(
                    value: type,
                    child: Text("$type Jam",
                        style: TextStyle(color: Colors.black)));
              }).toList(),
            )),
        Container(
            padding: EdgeInsets.only(bottom: 15),
            child: globals.myText(
                text: "Waktu dimulai setelah Anda melakukan posting",
                color: "danger")),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: openBidController,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              // initialValue: _openBid,
              // focusNode: usernameFocusNode,
              onSaved: (String value) {
                _openBid = value;
              },
              onFieldSubmitted: (String value) {
                if (value.length > 0) {
                  FocusScope.of(context).requestFocus(binFocusNode);
                }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Harga awal wajib diisi';
                }

                if (binController.text.isNotEmpty) {
                  if (int.parse(value) >= int.parse(binController.text)) {
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
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              controller: binController,
              // initialValue: _bin,
              focusNode: binFocusNode,
              onSaved: (String value) {
                _bin = value;
              },
              onFieldSubmitted: (String value) {
                if (value.length > 0) {
                  FocusScope.of(context).requestFocus(multiplyFocusNode);
                }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Harga Beli Sekarang wajib diisi';
                }

                if (openBidController.text.isNotEmpty) {
                  if (int.parse(value) <= int.parse(openBidController.text)) {
                    return 'Harga Beli Sekarang tidak boleh kurang atau sama dengan harga awal';
                  }

                  if (multiplyController.text.isNotEmpty) {
                    if (int.parse(multiplyController.text) == 0) {
                      return 'Kelipatan tidak valid';
                    }

                    if ((int.parse(value) - int.parse(openBidController.text)) %
                            int.parse(multiplyController.text) !=
                        0) {
                      return 'BIN harus sesuai kelipatan';
                    }
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
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: multiplyController,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              // initialValue: _multiply,
              focusNode: multiplyFocusNode,
              onSaved: (String value) {
                _multiply = value;
              },
              onFieldSubmitted: (String value) {
                if (value.length > 0) {
                  _save();
                }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Harga kelipatan wajib diisi';
                }

                if (int.parse(value) == 0) {
                  return 'Kelipatan tidak valid';
                }

                if (binController.text.isNotEmpty) {
                  if (int.parse(value) >= int.parse(binController.text)) {
                    return 'Harga kelipatan tidak boleh melebihi atau sama dengan harga beli sekarang';
                  }

                  if (openBidController.text.isNotEmpty) {
                    if ((int.parse(binController.text) -
                                int.parse(openBidController.text)) %
                            int.parse(value) !=
                        0) {
                      return 'Nilai kelipatan tidak sesuai';
                    }
                  }
                }
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Harga Kelipatan",
                  labelText: "Harga Kelipatan",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context),
            child: CheckboxListTile(
                value: _innerIslandShippingBool,
                title: globals.myText(
                    text: "Hanya melayani pengiriman dalam pulau",
                    color: "dark",
                    size: 13),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool value) {
                  setState(() {
                    this._innerIslandShippingBool = value;
                    switch (value) {
                      case true:
                        this._innerIslandShipping = 1;
                        break;
                      case false:
                        this._innerIslandShipping = 0;
                        break;
                    }
                  });
                }))
      ],
    );
  }

  Widget _buildSellProduct() {
    return Column(
      children: <Widget>[
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: priceController,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              onSaved: (String value) {
                _price = value;
              },
              onFieldSubmitted: (String value) {
                if (value.length > 0) {
                  FocusScope.of(context).requestFocus(quantityFocusNode);
                }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Harga awal wajib diisi';
                }

                if (int.parse(value) < 1) {
                  return 'Harga tidak sesuai';
                }
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Harga",
                  labelText: "Harga",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              controller: quantityController,
              focusNode: quantityFocusNode,
              onSaved: (String value) {
                _quantity = value;
              },
              onFieldSubmitted: (String value) {
                // if (value.length > 0) {
                //   FocusScope.of(context).requestFocus(multiplyFocusNode);
                // }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Harga Beli Sekarang wajib diisi';
                }

                if (int.parse(value) < 1) {
                  return 'Stok tidak sesuai';
                }
              },
              style: TextStyle(color: Colors.black),
              // keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Stok",
                  labelText: "Stok",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            )),
        Container(
            width: globals.mw(context),
            child: CheckboxListTile(
                value: _innerIslandShippingBool,
                title: globals.myText(
                    text: "Hanya melayani pengiriman dalam pulau",
                    color: "dark",
                    size: 13),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool value) {
                  setState(() {
                    this._innerIslandShippingBool = value;
                    switch (value) {
                      case true:
                        this._innerIslandShipping = 1;
                        break;
                      case false:
                        this._innerIslandShipping = 0;
                        break;
                    }
                  });
                })),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
        body: Scaffold(
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
                        "Tambah Produk",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )),
                Container(
                    width: globals.mw(context) * 0.95,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: DropdownButtonFormField<AnimalCategory>(
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Kategori Hewan",
                          labelText: "Kategori Hewan"),
                      value: _animalCategory,
                      validator: (animalCategory) {
                        if (animalCategory == null) {
                          return 'Silahkan pilih kategori hewan';
                        }
                      },
                      onChanged: (AnimalCategory category) {
                        setState(() {
                          _animalCategory = category;
                        });
                        _getAnimalSubCategories();
                      },
                      items: animalCategories.map((AnimalCategory category) {
                        return DropdownMenuItem<AnimalCategory>(
                            value: category,
                            child: Text(category.name,
                                style: TextStyle(color: Colors.black)));
                      }).toList(),
                    )),
                Container(
                    width: globals.mw(context) * 0.95,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: DropdownButtonFormField<AnimalSubCategory>(
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Sub Kategori Hewan",
                          labelText: "Sub Kategori Hewan"),
                      value: _animalSubCategory,
                      validator: (animalSubCategory) {
                        if (animalSubCategory == null) {
                          return 'Silahkan pilih sub kategori hewan';
                        }
                      },
                      onChanged: (AnimalSubCategory category) {
                        setState(() {
                          _animalSubCategory = category;
                        });
                      },
                      items:
                          animalSubCategories.map((AnimalSubCategory category) {
                        return DropdownMenuItem<AnimalSubCategory>(
                            value: category,
                            child: Text(category.name,
                                style: TextStyle(color: Colors.black)));
                      }).toList(),
                    )),

                Container(
                    width: globals.mw(context) * 0.95,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: TextFormField(
                      onSaved: (String value) {
                        _name = value;
                      },
                      onFieldSubmitted: (String value) {
                        if (value.length > 0) {
                          FocusScope.of(context)
                              .requestFocus(descriptionFocusNode);
                        }
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Nama hewan wajib diisi';
                        }
                      },
                      style: TextStyle(color: Colors.black),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Nama Hewan",
                          labelText: "Nama Hewan",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    )),
                // Container(
                //   width: globals.mw(context) * 0.95,
                //   child: Row(children: <Widget>[
                //     GestureDetector(
                //         onTap: () => _selectDate(context),
                //         child: Icon(Icons.calendar_today)),
                //     Center(
                //       child: Text(
                //           _dateOfBirth == null
                //               ? "-"
                //               : _dateOfBirth.day.toString() +
                //                   "-" +
                //                   _dateOfBirth.month.toString() +
                //                   "-" +
                //                   _dateOfBirth.year.toString(),
                //           style: TextStyle(color: Colors.black)),
                //     ),
                //   ]),
                // ),
                // Container(
                //     width: globals.mw(context) * 0.95,
                //     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                //     child: TextFormField(
                //       controller: dateOfBirthController,
                //       validator: (String value) {
                //         if (value.isEmpty)
                //           return 'Tanggal lahir masih kosong';
                //       },
                //       style: TextStyle(color: Colors.black),
                //       decoration: InputDecoration(
                //           suffixIcon: GestureDetector(
                //             onTap: () => _selectDate(context),
                //             child: Icon(Icons.calendar_today),
                //           ),
                //           contentPadding: EdgeInsets.all(13),
                //           hintText: "Tanggal Lahir",
                //           labelText: "Tanggal Lahir",
                //           fillColor: Colors.white,
                //           border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(5))),
                //     )),
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
                Container(
                    width: globals.mw(context) * 0.95,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: TextFormField(
                      // initialValue: _description,
                      focusNode: descriptionFocusNode,
                      onSaved: (String value) {
                        _description = value;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      onFieldSubmitted: (String value) {
                        // if (value.length > 0) {
                        //   FocusScope.of(context).requestFocus(passwordFocusNode);
                        // }
                      },
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
                              "Tuliskan deskripsi hewan, jenis pengiriman dan catatan penting lainnya",
                          labelText: "Deskripsi",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    )),
                Container(
                  width: 150,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Foto (Max 2)",
                            style: TextStyle(color: Colors.white)),
                        Icon(Icons.add_photo_alternate, color: Colors.white),
                      ],
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: loadAssets,
                  ),
                ),
                _buildGridViewImages(),
                SizedBox(height: 10),

                Divider(),

                globals.myText(text: "Simpan Hewan Sebagai", color: "grey"),
                // Text("Lelangkan Hewan ini?", style: TextStyle(color: Colors.black)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Radio(
                          value: 0,
                          onChanged: _handleSaveAs,
                          groupValue: _saveAs),
                      Text("Draf", style: TextStyle(color: Colors.black)),
                      Radio(
                          value: 1,
                          onChanged: _handleSaveAs,
                          groupValue: _saveAs),
                      Text("Lelang", style: TextStyle(color: Colors.black)),
                      Radio(
                          value: 2,
                          onChanged: _handleSaveAs,
                          groupValue: _saveAs),
                      Text("Produk Jual", style: TextStyle(color: Colors.black))
                    ]),
                SizedBox(height: 8),
                _saveAs == 1 ? _buildAuction() : Container(),
                _saveAs == 2 ? _buildSellProduct() : Container(),
                Container(
                  width: globals.mw(context),
                  child: CheckboxListTile(
                      value: _agreeTerms,
                      title: globals.myText(
                          text:
                              "Saya siap menerima konsekuensi apabila menjual binatang langka / tidak sesuai Undang-Undang Republik Indonesia",
                          color: "dark",
                          size: 13),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool value) {
                        setState(() {
                          this._agreeTerms = value;
                        });
                      })),
                SizedBox(height: 20),
                Container(
                    width: globals.mw(context) * 0.95,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: FlatButton(
                        onPressed: () => isLoading ? null : _save(),
                        child: Text(!isLoading ? "Simpan Data" : "Mohon Tunggu",
                            style: Theme.of(context).textTheme.display4),
                        color: isLoading
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)))),
                SizedBox(height: 20),
                // FlatButton(
                //   child: Text("Restart Request"),
                //   onPressed: () {
                //     setState(() {
                //       isLoading = false;
                //     });
                //   },
                // ),
              ]),
            ),
          ]),
          !isLoading ? Container() : Center(child: CircularProgressIndicator()),
        ])),
      ),
    );
  }
}
