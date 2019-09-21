import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/animal_image.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';
import 'package:jlf_mobile/models/auction.dart';
import 'package:jlf_mobile/models/product.dart';
import 'package:jlf_mobile/models/select_product.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/auction_services.dart';
import 'package:jlf_mobile/services/product_services.dart' as ProductServices;
import 'package:jlf_mobile/services/product_services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ActivateAuctionPage extends StatefulWidget {
  final int animalId;

  ActivateAuctionPage({@required this.animalId});

  @override
  _ActivateAuctionPageState createState() =>
      _ActivateAuctionPageState(animalId);
}

class _ActivateAuctionPageState extends State<ActivateAuctionPage> {
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

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  var openBidController = MoneyMaskedTextController(
      precision: 0, leftSymbol: "Rp. ", decimalSeparator: "");
  var multiplyController = MoneyMaskedTextController(
      precision: 0, leftSymbol: "Rp. ", decimalSeparator: "");
  var binController = MoneyMaskedTextController(
      precision: 0, leftSymbol: "Rp. ", decimalSeparator: "");
  TextEditingController dateOfBirthController = TextEditingController();
  var priceController = MoneyMaskedTextController(
      precision: 0, leftSymbol: "Rp. ", decimalSeparator: "");
  TextEditingController quantityController = TextEditingController();

  List<AnimalCategory> animalCategories = List<AnimalCategory>();
  AnimalCategory _animalCategory;

  List<AnimalSubCategory> animalSubCategories = List<AnimalSubCategory>();
  // AnimalSubCategory _animalSubCategory;

  var imagesBase64 = List<String>();

  String _name;
  String _description;
  String _bidType;
  int _auctionDuration;
  String _gender = "M";
  bool _innerIslandShippingBool = false;
  int _innerIslandShipping = 0;
  DateTime _dateOfBirth;

  bool _agreeTerms = false;

  List<int> durations = [3, 6, 12, 24, 48];

  List<Asset> images = List<Asset>();
  String _error;

  String _quantity;

  Animal animal;
  int animalId;

  SelectProduct _selectProduct;

  String labelNamaType = "Hewan";

  List<SelectProduct> selectProducts = [
    SelectProduct(id: 1, name: "Lelang"),
    SelectProduct(id: 2, name: "Produk Jual"),
    // SelectProduct(id: 3, name: "Produk Aksesoris"),
  ];

  @override
  void initState() {
    super.initState();

    this.isLoading = true;
  }

  _ActivateAuctionPageState(int animalId) {
    this.animalId = animalId;
    _selectProduct = selectProducts[0];

    isLoading = true;
    getAnimalById(globals.user.tokenRedis, animalId).then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      animal = onValue;
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      globals.debugPrint(onError.toString());
    }).then((_) {
      this._name = animal.name;
      this._animalCategory = animal.animalSubCategory.animalCategory;
      this._animalCategory = animal.animalSubCategory.animalCategory;
      this._description = animal.description;
      this._gender = animal.gender;
      this._dateOfBirth = animal.dateOfBirth;

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
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
    imagesBase64 = List<String>();

    for (int i = 0; i < images.length; i++) {
      ByteData byteData = await images[i].requestOriginal(quality: 75);

      List<int> imageData = byteData.buffer.asUint8List();
      // byteData.buffer.asByteData();

      imagesBase64.add(base64Encode(imageData));
    }
  }

  _deleteAnimal() async {
    globals.loadingModel(context);
    try {
      final result = await deleteAnimalById("", animalId);
      Navigator.pop(context);
      if (result == 1) {
        await globals.showDialogs("Berhasil menghapus data", context,
            route: "/profile");
      } else if (result == 3) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      } else {
        globals.showDialogs("Gagal menghapus data", context);
      }
    } catch (e) {
      Navigator.pop(context);
      globals.debugPrint(e.toString());
      globals.showDialogs("Gagal menghapus data", context);
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

    // if (_gender == null) {
    //   globals.showDialogs("Gender belum dipilih", context);
    //   return;
    // }

    // if (imagesBase64.length == 0) {
    //   globals.showDialogs("Wajib upload foto hewan 1-3 foto", context);
    //   return;
    // }

    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      _formKey.currentState.save();

      Map<String, dynamic> formData = Map<String, dynamic>();
      String message;

      if (_selectProduct.id == 1) {
        message = 'Berhasil memulai lelang hewan';
        // If user want to start the auction of the animal
        Auction auction = Auction();

        auction.openBid = openBidController.numberValue.toInt();
        auction.multiply = multiplyController.numberValue.toInt();
        auction.buyItNow = binController.numberValue.toInt();
        auction.duration = _auctionDuration;
        auction.ownerUserId = globals.user.id;
        auction.active = 1;
        auction.innerIslandShipping = _innerIslandShipping;
        auction.slug =
            "${globals.user.id}-" + 'hewan-jlf-' + DateTime.now().toString();

        formData['auction'] = auction;

        try {
          int response =
              await createAuction(formData, animal.id, globals.user.tokenRedis);
          if (response == 1) {
            await globals.showDialogs(message, context);
          } else if (response == 3) {
            await globals.showDialogs(
                "Session anda telah berakhir, Silakan melakukan login ulang",
                context,
                isLogout: true);
            return;
          } else {
            await globals.showDialogs(
                "Gagal membuat lelang, silahkan ulangi kembali", context);
          }

          Navigator.pop(context);
          Navigator.pushNamed(context, "/profile");
        } catch (e) {
          globals.showDialogs(e.toString(), context);
          globals.debugPrint(e);
          setState(() {
            isLoading = false;
          });
        }
      } else if (_selectProduct.id == 2) {
        message = 'Berhasil memasang hewan sebagai produk jual';
        // If user want to start the auction of the animal
        Product product = Product();

        product.price = priceController.numberValue.toInt();
        product.type = "animal";
        product.quantity = 1;
        product.ownerUserId = globals.user.id;
        product.status = 'active';
        product.innerIslandShipping = _innerIslandShipping;
        product.slug = 'produk-jlf-' +
            DateTime.now().year.toString() +
            DateTime.now().month.toString() +
            DateTime.now().day.toString();

        formData['product'] = product;

        try {
          int response =
              await createProduct(formData, animal.id, globals.user.tokenRedis);
          globals.debugPrint(response);
          if (response == 1) {
            await globals.showDialogs(message, context);
          } else if (response == 3) {
            await globals.showDialogs(
                "Session anda telah berakhir, Silakan melakukan login ulang",
                context,
                isLogout: true);
          } else {
            await globals.showDialogs(
                "Gagal membuat produk jual, silahkan ulangi kembali", context);
          }

          Navigator.pop(context);
          Navigator.pushNamed(context, "/profile");
        } catch (e) {
          globals.showDialogs(e.toString(), context);
          globals.debugPrint(e);
          setState(() {
            isLoading = false;
          });
        }
      } else if (_selectProduct.id == 3) {
        message = 'Berhasil memasang aksesoris sebagai produk aksesoris';
        // If user want to start the auction of the animal
        Product product = Product();

        product.price = priceController.numberValue.toInt();
        product.type = "accessory";
        product.quantity = 1;
        product.ownerUserId = globals.user.id;
        product.status = 'active';
        product.innerIslandShipping = _innerIslandShipping;
        product.slug = 'produk-accessory-jlf-' +
            DateTime.now().year.toString() +
            DateTime.now().month.toString() +
            DateTime.now().day.toString();

        formData['product'] = product;

        try {
          int response =
              await createProduct(formData, animal.id, globals.user.tokenRedis);
          globals.debugPrint(response);
          if (response == 1) {
            await globals.showDialogs(message, context);
          } else if (response == 3) {
            await globals.showDialogs(
                "Session anda telah berakhir, Silakan melakukan login ulang",
                context,
                isLogout: true);
          } else {
            await globals.showDialogs(
                "Gagal membuat accessory, silahkan ulangi kembali", context);
          }

          Navigator.pop(context);
          Navigator.pushNamed(context, "/profile");
        } catch (e) {
          globals.showDialogs(e.toString(), context);
          globals.debugPrint(e);
          setState(() {
            isLoading = false;
          });
        }
      }

      // Auction auction = Auction();

      // auction.openBid = int.parse(_openBid);
      // auction.multiply = int.parse(_multiply);
      // auction.buyItNow = int.parse(_bin);
      // auction.duration = _auctionDuration;
      // auction.ownerUserId = globals.user.id;
      // auction.active = 1;
      // auction.innerIslandShipping = _innerIslandShipping;
      // auction.slug = 'test' + "-" + DateTime.now().toString();

      // formData['auction'] = auction;
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }

  // void _handlePostToAuctionChange(int value) {
  //   setState(() {
  //     _postToAuction = value;
  //   });
  // }

  // void _handleGenderChange(String value) {
  //   setState(() {
  //     _gender = value;
  //   });
  // }

  Widget _buildAnimalImages(List<AnimalImage> animalImages) {
    return Container(
      padding: EdgeInsets.all(5),
      child: GridView.count(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        crossAxisCount: 3,
        children: List.generate(animalImages.length, (index) {
          // Asset asset = images[index];

          return Container(
              padding: EdgeInsets.all(5),
              child: Image.network(animalImages[index].image)
              // child: AssetThumb(
              //   asset: asset,
              //   width: globals.mw(context) * 0.95,
              //   height: 300,
              // ),
              );
        }),
      ),
    );
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
                    child: Text("1x$type Jam Last Bidder",
                        style: TextStyle(color: Colors.black)));
              }).toList(),
            )),
        Container(
            padding: EdgeInsets.only(bottom: 15),
            child: globals.myText(
                text: "Waktu closed dihitung dari bid terakhir",
                color: "danger")),
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: openBidController,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
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
                  if (openBidController.numberValue.toInt() >=
                      binController.numberValue.toInt()) {
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
              focusNode: binFocusNode,
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
                  if (binController.numberValue.toInt() <=
                      openBidController.numberValue.toInt()) {
                    return 'Harga Beli Sekarang tidak boleh kurang atau sama dengan harga awal';
                  }

                  if (multiplyController.text.isNotEmpty) {
                    if (multiplyController.numberValue.toInt() == 0) {
                      return 'Kelipatan tidak valid';
                    }

                    if ((binController.numberValue.toInt() -
                                openBidController.numberValue.toInt()) %
                            multiplyController.numberValue.toInt() !=
                        0) {
                      return 'BIN harus sesuai kelipatan';
                    }
                  }
                }
              },
              style: TextStyle(color: Colors.black),
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
              focusNode: multiplyFocusNode,
              onFieldSubmitted: (String value) {
                if (value.length > 0) {
                  _save();
                }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Harga kelipatan wajib diisi';
                }

                if (multiplyController.numberValue.toInt() == 0) {
                  return 'Kelipatan tidak valid';
                }

                if (binController.text.isNotEmpty) {
                  if (multiplyController.numberValue.toInt() >=
                      binController.numberValue.toInt()) {
                    return 'Harga kelipatan tidak boleh melebihi atau sama dengan harga beli sekarang';
                  }

                  if (openBidController.text.isNotEmpty) {
                    if ((binController.numberValue.toInt() -
                                openBidController.numberValue.toInt()) %
                            multiplyController.numberValue.toInt() !=
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
              onFieldSubmitted: (String value) {
                if (value.length > 0) {
                  // FocusScope.of(context).requestFocus(quantityFocusNode);
                }
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Harga awal wajib diisi';
                }

                if (priceController.numberValue.toInt() < 1) {
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
            key: _scaffoldKey,
            body: Stack(children: <Widget>[
              ListView(physics: ScrollPhysics(), children: <Widget>[
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
                            "Lelang / Jual Hewan",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        )),

                    Container(
                        child: globals.myText(
                            text: "Kategori", weight: "B", color: 'dark')),
                    Container(
                        child: globals.myText(
                            text:
                                "${animal != null ? animal.animalSubCategory.animalCategory.name : ""} - ${animal != null ? animal.animalSubCategory.name : ""}",
                            color: 'dark')),
                    SizedBox(height: 10),
                    Container(
                        child: globals.myText(
                            text: "Nama $labelNamaType",
                            weight: "B",
                            color: 'dark')),
                    Container(
                        child: globals.myText(
                            text: "${animal != null ? animal.name : ""}",
                            color: 'dark')),
                    SizedBox(height: 10),
                    Container(
                        child: globals.myText(
                            text: "Deskripsi", weight: "B", color: 'dark')),
                    Container(
                        child: globals.myText(
                            text: "${animal != null ? animal.description : ""}",
                            color: 'dark',
                            align: TextAlign.center)),
                    SizedBox(height: 10),
                    // Container(
                    //   child: globals.myText(text: "Jenis Kelamin", weight: "B", color: 'dark')
                    // ),
                    // Container(
                    //   child: globals.myText(text: "${animal != null ? animal.gender == 'M' ? 'Jantan' : 'Betina' : ""}", color: 'dark')
                    // ),
                    // SizedBox(height: 10),
                    Container(
                        child: globals.myText(
                            text: "Foto", weight: "B", color: 'dark')),
                    animal != null
                        ? _buildAnimalImages(animal.animalImages)
                        : Container(),

                    Divider(),
                    // Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: <Widget>[
                    //       Radio(
                    //           value: 1,
                    //           onChanged: _handleSaveAs,
                    //           groupValue: _saveAs),
                    //       Text("Lelang", style: TextStyle(color: Colors.black)),
                    //       Radio(
                    //           value: 2,
                    //           onChanged: _handleSaveAs,
                    //           groupValue: _saveAs),
                    //       Text("Produk Jual",
                    //           style: TextStyle(color: Colors.black))
                    //     ]),

                    Container(
                        width: globals.mw(context) * 0.95,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: DropdownButtonFormField<SelectProduct>(
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              contentPadding: EdgeInsets.all(13),
                              hintText: "Simpan Sebagai",
                              labelText: "Simpan Sebagai"),
                          value: _selectProduct,
                          validator: (animalCategory) {
                            if (_animalCategory == null) {
                              return 'Silahkan pilih simpan sebagai';
                            }
                          },
                          onChanged: (SelectProduct selectProd) {
                            setState(() {
                              if (_selectProduct.id != selectProd.id) {
                                _selectProduct = selectProd;

                                if (_selectProduct.id == 3) {
                                  labelNamaType = "Aksesoris";
                                } else {
                                  labelNamaType = "Hewan";
                                }
                              }
                            });
                          },
                          items:
                              selectProducts.map((SelectProduct selectProduct) {
                            return DropdownMenuItem<SelectProduct>(
                                value: selectProduct,
                                child: Text(selectProduct.name,
                                    style: TextStyle(color: Colors.black)));
                          }).toList(),
                        )),
                    _selectProduct.id == 1
                        ? _buildAuction()
                        : _buildSellProduct(),
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
                            child: Text(
                                !isLoading
                                    ? _selectProduct.id == 1
                                        ? "Mulai Lelang"
                                        : "Mulai Jual"
                                    : "Mohon Tunggu",
                                style: Theme.of(context).textTheme.display4),
                            color: isLoading
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)))),
                    Container(
                        width: globals.mw(context) * 0.95,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: FlatButton(
                            onPressed: () => isLoading ? null : _deleteAnimal(),
                            child: Text("Hapus Draf",
                                style: Theme.of(context).textTheme.display4),
                            color: globals.myColor("danger"),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)))),
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
