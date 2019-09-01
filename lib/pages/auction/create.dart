import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:http/http.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';
import 'package:jlf_mobile/models/auction.dart';
import 'package:jlf_mobile/models/product.dart';
import 'package:jlf_mobile/models/select_product.dart';
import 'package:jlf_mobile/services/animal_category_services.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/animal_sub_category_services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class CreateAuctionPage extends StatefulWidget {
  final int categoryId;
  final int subCategoryId;
  final int type;
  CreateAuctionPage({Key key, this.categoryId, this.subCategoryId, this.type})
      : super(key: key);
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
  AnimalSubCategory _animalSubCategory;
  SelectProduct _selectProduct;

  String labelNamaType = "Hewan";

  List<SelectProduct> selectProducts = [
    SelectProduct(id: 0, name: "Draf"),
    SelectProduct(id: 1, name: "Lelang"),
    SelectProduct(id: 2, name: "Produk Jual"),
    SelectProduct(id: 3, name: "Produk Aksesoris"),
  ];

  var imagesBase64 = List<String>();

  String _name;
  String _description;

  int _auctionDuration;
  String _gender = "M";
  bool _innerIslandShippingBool = false;
  int _innerIslandShipping = 0;
  DateTime _dateOfBirth;

  bool _agreeTerms = false;

  List<int> durations = [3, 6, 12, 24, 48];

  List<Asset> images = List<Asset>();
  String _error;

  File _video;
  String _videoPath;
  bool _isShowVideo = false;
  MultipartFile videoToSent;

  @override
  void initState() {
    super.initState();

    this.isLoading = true;

    _selectProduct = selectProducts[0];

    if (widget.type != null) {
      _selectProduct = selectProducts[widget.type];
    }

    if (_selectProduct.id == 3) {
      labelNamaType = "Aksesoris";
    } else {
      labelNamaType = "Hewan";
    }

    getAnimalCategoryWithoutCount(
            "token", _selectProduct.id == 3 ? "accessory" : "animal")
        .then((onValue) {
      animalCategories = onValue;
      if (widget.categoryId != null) {
        for (var animalCategory in animalCategories) {
          if (animalCategory.id == widget.categoryId) {
            _animalCategory = animalCategory;
            break;
          }
        }
        _getAnimalSubCategories();
      }

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

  void _refreshCategory() {
    _animalCategory = null;
    _animalSubCategory = null;

    getAnimalCategoryWithoutCount(
            "token", _selectProduct.id == 3 ? "accessory" : "animal")
        .then((onValue) {
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
        if (widget.subCategoryId != null) {
          for (var animalSubCategory in animalSubCategories) {
            if (animalSubCategory.id == widget.subCategoryId) {
              _animalSubCategory = animalSubCategory;
              break;
            }
          }
        }
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
              physics: ScrollPhysics(),
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

  Future<void> getVideo() async {
    var video = await ImagePicker.pickVideo(source: ImageSource.gallery);

    // limit max 5 mb
    if (video.lengthSync() > 6000000) {
      globals.showDialogs("Ukuran Video Terlalu Besar", context);
    } else {
      setState(() {
        _video = video;
      });


      if (_video != null) {
        _videoPath = _video.path;
        videoToSent = await MultipartFile.fromPath('video', _videoPath,
            contentType: MediaType('video', 'mp4'));

      } else {
        videoToSent = null;
      }
    }
  }

  Future<void> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
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
      ByteData byteData = await images[i].requestOriginal(quality: 50);

      List<int> imageData = byteData.buffer.asUint8List();
      // byteData.buffer.asByteData();

      imagesBase64.add(base64Encode(imageData));
    }
  }

  _save() async {
    if (isLoading) return;

    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
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

      if (imagesBase64.length == 0) {
        globals.showDialogs(
            "Wajib upload foto $labelNamaType max 5 foto", context);
        return;
      }

      globals.loadingModel(context);

      Map<String, dynamic> formData = Map<String, dynamic>();

      String message = 'Berhasil menambah data $labelNamaType';

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
      animal.slug =
          "${globals.user.id}-" + 'hewan-jlf-' + DateTime.now().toString();

      formData['animal'] = animal;

      if (_selectProduct.id == 1) {
        message = 'Berhasil menambah data hewan, dan memulai lelang';
        // If user want to start the auction of the animal
        Auction auction = Auction();

        auction.openBid = openBidController.numberValue.toInt();
        auction.multiply = multiplyController.numberValue.toInt();
        auction.buyItNow = binController.numberValue.toInt();
        auction.duration = _auctionDuration;
        auction.ownerUserId = globals.user.id;
        auction.active = 1;
        auction.innerIslandShipping = _innerIslandShipping;
        auction.slug = 'lelang-jlf-' +
            DateTime.now().year.toString() +
            DateTime.now().month.toString() +
            DateTime.now().day.toString();

        formData['auction'] = auction;
      } else if (_selectProduct.id == 2) {
        message =
            'Berhasil menambah data $labelNamaType, dan memasang sebagai produk jual';
        // If user want to start the auction of the animal
        Product product = Product();
        product.type = "animal";
        product.price = priceController.numberValue.toInt();
        product.quantity = 1;
        product.ownerUserId = globals.user.id;
        product.status = 'active';
        product.innerIslandShipping = _innerIslandShipping;
        product.slug = 'produk-jlf-' +
            DateTime.now().year.toString() +
            DateTime.now().month.toString() +
            DateTime.now().day.toString();

        formData['product'] = product;
      } else if (_selectProduct.id == 3) {
        message =
            'Berhasil menambah data $labelNamaType, dan memasang sebagai produk aksesoris';
        // If user want to start the auction of the animal
        Product product = Product();
        product.type = "accessory";
        product.price = priceController.numberValue.toInt();
        product.quantity = 1;
        product.ownerUserId = globals.user.id;
        product.status = 'active';
        product.innerIslandShipping = _innerIslandShipping;
        product.slug = 'produk-aksesoris-jlf-' +
            DateTime.now().year.toString() +
            DateTime.now().month.toString() +
            DateTime.now().day.toString();

        formData['product'] = product;
      }

      formData['images'] = imagesBase64;

      try {
        var response = await create(formData);

        Navigator.pop(context);
        if (response == "") {
          await globals.showDialogs(message, context);
          Navigator.pop(context);
          Navigator.pushNamed(context, "/profile");
        } else {
          await globals.showDialogs(response, context, needVerify: true);
        }
      } catch (e) {
        Navigator.pop(context);
        globals.showDialogs(e.toString(), context);
        globals.mailError("Create product / auction", e.toString());
        print(e);
      }
    } else {
      setState(() {
        autoValidate = true;
      });
    }
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

                if (binController.numberValue.toInt() < 1000) {
                  return 'Nominal terlalu kecil';
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
        // Container(
        //     width: globals.mw(context) * 0.95,
        //     padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        //     child: TextFormField(
        //       keyboardType: TextInputType.number,
        //       inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        //       controller: quantityController,
        //       focusNode: quantityFocusNode,
        //       onSaved: (String value) {
        //         _quantity = value;
        //       },
        //       onFieldSubmitted: (String value) {
        //         // if (value.length > 0) {
        //         //   FocusScope.of(context).requestFocus(multiplyFocusNode);
        //         // }
        //       },
        //       validator: (value) {
        //         if (value.isEmpty) {
        //           return 'Harga Beli Sekarang wajib diisi';
        //         }

        //         if (int.parse(value) < 1) {
        //           return 'Stok tidak sesuai';
        //         }
        //       },
        //       style: TextStyle(color: Colors.black),
        //       // keyboardType: TextInputType.number,
        //       decoration: InputDecoration(
        //           contentPadding: EdgeInsets.all(13),
        //           hintText: "Stok",
        //           labelText: "Stok",
        //           fillColor: Colors.white,
        //           border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(5))),
        //     )),
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

  void showVideoByCategory() {
    if (_animalCategory.name.toLowerCase() == "unggas") {
      _isShowVideo = true;
    } else {
      _isShowVideo = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
        body: Scaffold(
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
                        "Tambah Produk",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )),
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

                            if (labelNamaType == "Hewan" &&
                                selectProd.id == 3) {
                              _refreshCategory();
                            } else if (labelNamaType == "Aksesoris" &&
                                selectProd.id != 3) {
                              _refreshCategory();
                            }

                            if (_selectProduct.id == 3) {
                              labelNamaType = "Aksesoris";
                            } else {
                              labelNamaType = "Hewan";
                            }
                          }
                        });
                      },
                      items: selectProducts.map((SelectProduct selectProduct) {
                        return DropdownMenuItem<SelectProduct>(
                            value: selectProduct,
                            child: Text(selectProduct.name,
                                style: TextStyle(color: Colors.black)));
                      }).toList(),
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
                          hintText: "Kategori $labelNamaType",
                          labelText: "Kategori $labelNamaType"),
                      value: _animalCategory,
                      validator: (animalCategory) {
                        if (_animalCategory == null) {
                          return 'Silahkan pilih kategori $labelNamaType';
                        }
                      },
                      onChanged: (AnimalCategory category) {
                        setState(() {
                          _animalSubCategory = null;
                          _animalCategory = category;
                        });
                        _getAnimalSubCategories();
                        showVideoByCategory();
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
                          hintText: "Sub Kategori $labelNamaType",
                          labelText: "Sub Kategori $labelNamaType"),
                      value: _animalSubCategory,
                      validator: (animalSubCategory) {
                        if (_animalSubCategory == null) {
                          return 'Silahkan pilih sub kategori $labelNamaType';
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
                          return 'Nama $labelNamaType wajib diisi';
                        }
                      },
                      style: TextStyle(color: Colors.black),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Nama $labelNamaType",
                          labelText: "Nama $labelNamaType",
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
                      focusNode: descriptionFocusNode,
                      onSaved: (String value) {
                        _description = value;
                      },
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
                              "Tuliskan deskripsi $labelNamaType, jenis pengiriman dan catatan penting lainnya",
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
                        Text("Foto (Max 5)",
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

                // Container(
                //   width: 250,
                //   child: RaisedButton(
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(5)),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: <Widget>[
                //         Text("Upload Video (Max 5 MB)",
                //             style: TextStyle(color: Colors.white)),
                //         Icon(Icons.video_call, color: Colors.white),
                //       ],
                //     ),
                //     color: Theme.of(context).primaryColor,
                //     onPressed: getVideo,
                //   ),
                // ),

                Container(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _videoPath ?? "",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                Divider(),

                SizedBox(height: 8),
                _selectProduct.id == 1 ? _buildAuction() : Container(),
                _selectProduct.id == 2 || _selectProduct.id == 3
                    ? _buildSellProduct()
                    : Container(),
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
              ]),
            ),
          ]),
          !isLoading
              ? Container()
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                ),
          !isLoading ? Container() : Center(child: CircularProgressIndicator()),
        ])),
      ),
    );
  }
}
