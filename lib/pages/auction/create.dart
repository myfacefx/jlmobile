import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
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
    SelectProduct(id: 0, name: "Draft"),
    SelectProduct(id: 1, name: "Lelang"),
    SelectProduct(id: 2, name: "Produk Jual"),
    // SelectProduct(id: 3, name: "Produk Aksesoris"),
  ];

  var imagesBase64 = List<String>();

  String _name;
  String _descriptionAnimal;
  String _descriptionDelivery;
  String _descriptionWarranty;
  String _description;

  int _auctionDuration;
  String _expiryDate;
  String _gender = "M";
  bool _innerIslandShippingBool = false;
  int _innerIslandShipping = 0;
  DateTime _dateOfBirth;

  bool _agreeTerms = false;

  List<int> durations = [3, 6, 12, 24, 48];

  List<Asset> images = List<Asset>();
  String _error;

  bool _isShowVideo = false;
  MultipartFile videoToSent;

  // Subscription _subscription;
  final _flutterVideoCompress = FlutterVideoCompress();
  String _convertedVideoPath;
  String _sizeVideo;

  List<String> _closingTypeList = ['durasi', 'custom-time'];
  String _closingType = 'durasi';
  int _injuryTimeCounter = 0;
  String selectedDate = "";
  String selectedTime = "";

  @override
  void initState() {
    super.initState();

    // _subscription =
    //     _flutterVideoCompress.compressProgress$.subscribe((progress) {
    //   debugglobals.debugPrint('progress: $progress');
    // });

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

    getAnimalCategoryWithoutCount(globals.user.tokenRedis,
            _selectProduct.id == 3 ? "accessory" : "animal")
        .then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      animalCategories = onValue;
      if (widget.categoryId != null) {
        for (var animalCategory in animalCategories) {
          if (animalCategory.id == widget.categoryId) {
            _animalCategory = animalCategory;
            showVideoByCategory();

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

    getAnimalCategoryWithoutCount(globals.user.tokenRedis,
            _selectProduct.id == 3 ? "accessory" : "animal")
        .then((onValue) {
      animalCategories = onValue;
      setState(() {
        isLoading = false;

        // Remove Anjing + Kucing if LELANG
        if (_selectProduct.id == 1) {
          animalCategories
              .removeWhere((item) => item.name.toUpperCase() == 'ANJING');
          animalCategories
              .removeWhere((item) => item.name.toUpperCase() == 'KUCING');
        }
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

  _getAnimalSubCategories() {
    setState(() {
      isLoading = true;
    });
    if (_animalCategory != null) {
      getAnimalSubCategoryByCategoryId(
              globals.user.tokenRedis, _animalCategory.id)
          .then((onValue) async {
        if (onValue == null) {
          await globals.showDialogs(
              "Session anda telah berakhir, Silakan melakukan login ulang",
              context,
              isLogout: true);
          return;
        }
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

    var videoLength = video.lengthSync();
    _sizeVideo = (videoLength / 1048576).toStringAsFixed(2);

    // limit max 35 mb
    if (video.lengthSync() > 36700160) {
      // byte in binary
      globals.showDialogs("Ukuran Video Terlalu Besar", context);
    } else {
      setState(() {
        isLoading = true;
      });

      final _convertedVideo = await _flutterVideoCompress.compressVideo(
        video.path,
        quality:
            VideoQuality.MediumQuality, // default(VideoQuality.DefaultQuality)
        deleteOrigin: false, // default(false)
      );
      // debugglobals.debugPrint(_convertedVideo.toJson().toString());
      _convertedVideoPath = _convertedVideo.path;

      setState(() {
        isLoading = false;
      });

      videoToSent = await MultipartFile.fromPath('video', _convertedVideoPath,
          contentType: MediaType('video', 'mp4'));
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

      animal.descriptionAnimal = _descriptionAnimal;
      animal.descriptionDelivery = _descriptionDelivery;
      animal.descriptionWarranty = _descriptionWarranty;
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
        auction.expiryDate = _expiryDate;
        auction.closingType = _closingType;
        auction.injuryTimeCounter = _injuryTimeCounter;
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
        var result =
            await create(formData, globals.user.tokenRedis, videoToSent);

        Navigator.pop(context);

        if (result == 1) {
          await globals.showDialogs(message, context);
          Navigator.pop(context);
          Navigator.pushNamed(context, "/profile");
        } else if (result == 2) {
          await globals.showDialogs(
              "Gagal menambah produk, terjadi kesalahan pada server", context);
        } else if (result == 3) {
          await globals.showDialogs(
              "Gagal menambah produk, Anda masuk dalam blacklist user",
              context);
        } else if (result == 4) {
          await globals.showDialogs(
              "Gagal menambah produk, data diri Anda belum terverifikasi",
              context,
              needVerify: true);
        } else if (result == 4) {
          await globals.showDialogs(
              "Session anda telah berakhir, Silakan melakukan login ulang",
              context,
              isLogout: true);
        } else {
          await globals.showDialogs("Error", context);
        }
      } catch (e) {
        Navigator.pop(context);
        globals.showDialogs(e.toString(), context);
        globals.mailError("Create product / auction", e.toString());
        globals.debugPrint(e);
      }
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }

  Widget _buildSelectedClosingType() {
    if (_closingType == "durasi") {
      return Container(
          width: globals.mw(context) * 0.95,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
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
          ));
    } else {
      return Container(
        color: Color.fromRGBO(244, 244, 244, 1),
        width: globals.mw(context) * 0.95,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              // elevation: 4.0,
              onPressed: () {
                DatePicker.showDatePicker(context,
                    theme: DatePickerTheme(
                      containerHeight: 210.0,
                    ),
                    showTitleActions: true,
                    minTime: DateTime(2019, 1, 1),
                    maxTime: DateTime(2022, 12, 31), onConfirm: (date) {
                  selectedDate = '${date.year}-${date.month}-${date.day}';
                  setState(() {
                    _expiryDate = "";
                    _expiryDate = selectedDate;
                  });
                }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              child: Container(
                alignment: Alignment.center,
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.date_range,
                                size: 14.0,
                                color: Colors.black,
                              ),
                              Text(
                                " $selectedDate",
                                style: TextStyle(
                                    color: Colors.black,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14.0),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Text(
                      "  Change",
                      style: TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                          fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              color: Color.fromRGBO(244, 244, 244, 1),
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              // elevation: 4.0,
              onPressed: () {
                DatePicker.showTimePicker(context,
                    theme: DatePickerTheme(
                      containerHeight: 210.0,
                    ),
                    showTitleActions: true, onConfirm: (time) {
                  selectedTime = ' ${time.hour}:${time.minute}:${time.second}';
                  setState(() {
                    _expiryDate += selectedTime;
                  });
                }, currentTime: DateTime.now(), locale: LocaleType.en);
                setState(() {});
              },
              child: Container(
                alignment: Alignment.center,
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.access_time,
                                size: 14.0,
                                color: Colors.black,
                              ),
                              Text(
                                " $selectedTime",
                                style: TextStyle(
                                    color: Colors.black,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14.0),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Text(
                      "  Change",
                      style: TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                          fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              color: Color.fromRGBO(244, 244, 244, 1),
            )
          ],
        )),
      );
    }
  }

  Widget _buildAuction() {
    return Column(
      children: <Widget>[
        Container(
            width: globals.mw(context) * 0.95,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  contentPadding: EdgeInsets.all(13),
                  hintText: "Tipe Closing Lelang",
                  labelText: "Tipe Closing Lelang"),
              value: _closingType,
              validator: (value) {
                if (value == null) {
                  return 'Silahkan pilih tipe closing lelang';
                }
              },
              onChanged: (String value) {
                setState(() {
                  _closingType = value;
                });
              },
              items: _closingTypeList.map((String type) {
                return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                        type == "durasi" ? "Bid Terakhir" : "Waktu Ditentukan",
                        style: TextStyle(color: Colors.black)));
              }).toList(),
            )),
        _buildSelectedClosingType(),
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
    if (_animalCategory.isVideoAllowed == 1) {
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

                            // if (labelNamaType == "Hewan" &&
                            //     selectProd.id == 3) {
                            //   _refreshCategory();
                            // } else if (labelNamaType == "Aksesoris" &&
                            //     selectProd.id != 3) {
                            //   _refreshCategory();
                            // }
                            _refreshCategory();

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
                      onSaved: (String value) {
                        _descriptionAnimal = value;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      onFieldSubmitted: (String value) {},
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Deskripsi Hewan wajib diisi';
                        }
                      },
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Tuliskan deskripsi $labelNamaType",
                          labelText: "Deskripsi Hewan",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    )),
                Container(
                    width: globals.mw(context) * 0.95,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: TextFormField(
                      onSaved: (String value) {
                        _descriptionDelivery = value;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      onFieldSubmitted: (String value) {},
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Deskripsi Pengiriman wajib diisi';
                        }
                      },
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Tuliskan deskripsi pengiriman",
                          labelText: "Deskripsi Pengiriman",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    )),
                Container(
                    width: globals.mw(context) * 0.95,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: TextFormField(
                      onSaved: (String value) {
                        _descriptionWarranty = value;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      onFieldSubmitted: (String value) {},
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Deskripsi Garansi wajib diisi';
                        }
                      },
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Tuliskan deskripsi garansi",
                          labelText: "Deskripsi Garansi",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    )),
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
                          return 'Jika Tidak Ada isi dengan -';
                        }
                      },
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Catatan wajib diisi",
                          labelText: "Catatan Lain",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    )),
                _isShowVideo == true
                    ? Container(
                        width: 250,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Upload Video (Max 35 MB)",
                                  style: TextStyle(color: Colors.white)),
                              Icon(Icons.video_call, color: Colors.white),
                            ],
                          ),
                          color: Theme.of(context).primaryColor,
                          onPressed: getVideo,
                        ),
                      )
                    : Container(),

                Container(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _sizeVideo != null
                            ? "Size Video : " + _sizeVideo + " MB"
                            : "",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Divider(),
                      Text(
                        _convertedVideoPath ?? "",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
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
                // Builder(
                //   builder: (context) => FlatButton(
                //     onPressed: () => inputTimeSelect(),
                //     child: Text("Show Time Picker"),
                //   ),
                // ),
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
