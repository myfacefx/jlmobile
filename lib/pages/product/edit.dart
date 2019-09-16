import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/animal_image.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';
import 'package:jlf_mobile/models/auction.dart';
import 'package:jlf_mobile/models/product.dart';
import 'package:jlf_mobile/models/select_product.dart';
import 'package:jlf_mobile/pages/video_popup.dart';
import 'package:jlf_mobile/services/animal_category_services.dart';
import 'package:jlf_mobile/services/animal_services.dart' as AnimalServices;
import 'package:jlf_mobile/services/animal_sub_category_services.dart';
import 'package:jlf_mobile/services/product_services.dart' as ProductServices;
import 'package:jlf_mobile/services/product_services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class EditProductPage extends StatefulWidget {
  final Animal animal;

  EditProductPage({Key key, @required this.animal}) : super(key: key);
  @override
  _EditProductPageState createState() => _EditProductPageState(this.animal);
}

class _EditProductPageState extends State<EditProductPage> {
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

  var priceController = MoneyMaskedTextController(
      precision: 0, leftSymbol: "Rp. ", decimalSeparator: "");
  TextEditingController quantityController = TextEditingController();

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  // TextEditingController p = TextEditingController();
  // TextEditingController nameController = TextEditingController();

  List<AnimalCategory> animalCategories = List<AnimalCategory>();
  AnimalCategory _animalCategory;

  List<AnimalSubCategory> animalSubCategories = List<AnimalSubCategory>();
  AnimalSubCategory _animalSubCategory;
  SelectProduct _selectProduct = SelectProduct(id: 2, name: "Produk Jual");
  SelectProduct _test;

  String labelNamaType = "Hewan";

  List<SelectProduct> selectProducts = [
    // SelectProduct(id: 0, name: "Draf"),
    // SelectProduct(id: 1, name: "Lelang"),
    SelectProduct(id: 2, name: "Produk Jual"),
    SelectProduct(id: 3, name: "Produk Aksesoris"),
  ];

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

  // Subscription _subscription;
  final _flutterVideoCompress = FlutterVideoCompress();
  String _convertedVideoPath;
  String _sizeVideo;
  bool _isShowVideo = false;
  MultipartFile videoToSent;

  String _price;
  String _quantity;

  bool _agreeTerms = false;

  List<int> durations = [3, 6, 12, 24, 48];

  List<Asset> images = List<Asset>();

  List<Column> currentImages = List<Column>();
  List<int> currentAnimalImageID = List<int>();

  List<int> animalImageIdToDelete = List<int>();

  List<AnimalImage> arrayAnimalImages = List<AnimalImage>();

  List<Asset> arrayOfAssets = List<Asset>();

  String _error;

  Animal _animal;

  _EditProductPageState(Animal animal) {
    this._animal = animal;
  }

  @override
  void initState() {
    super.initState();

    // _subscription =
    //     _flutterVideoCompress.compressProgress$.subscribe((progress) {
    //   debugPrint('progress: $progress');
    // });

    setState(() {
      // print(_animal.product.type);
      // _name = _animal.name;

      nameController.text = _animal.name;
      descriptionController.text = _animal.description;
      priceController.text = _animal.product.price.toString();

      _innerIslandShipping = _animal.product.innerIslandShipping;

      _animal.product.innerIslandShipping == 1
          ? _innerIslandShippingBool = true
          : _innerIslandShippingBool = false;

      // Current Images Initialization
      for (var image in _animal.animalImages) {
        arrayAnimalImages.add(image);
      }

      for (var i = 0; i < _animal.animalImages.length; i++) {
        currentAnimalImageID.add(_animal.animalImages[i].id);
        // currentImages.add(Column(
        //   children: <Widget>[
        //     Container(
        //         height: 40,
        //         padding: EdgeInsets.all(5),
        //         child: FadeInImage.assetNetwork(
        //           fit: BoxFit.fitHeight,
        //           placeholder: 'assets/images/loading.gif',
        //           image: _animal.animalImages[i].thumbnail,
        //         )),
        //     Container(
        //       height: 20,
        //       child: FlatButton(
        //           onPressed: () {
        //             setState(() {
        //               currentAnimalImageID.removeAt(i);
        //               currentImages.removeAt(i);
        //               animalImageIdToDelete.add(_animal.animalImages[i].id);
        //               refreshCurrentImages();
        //             });
        //           },
        //           color: globals.myColor("danger"),
        //           child: Container(
        //               child:
        //                   Icon(Icons.delete, size: 16, color: Colors.white))),
        //     ),
        //     // Container(height: 20, child: Icon(Icons.delete, size: 16, color: Colors.white))
        //   ],
        // ));
      }

      if (_animal.product.type == "accessory") {
        labelNamaType = "Aksesoris";
        _test = SelectProduct(id: 3, name: "Produk Aksesoris");
      } else {
        _test = SelectProduct(id: 2, name: "Produk Jual");
        labelNamaType = "Hewan";
      }
    });

    getAnimalCategoryWithoutCount(globals.user.tokenRedis, _animal.product.type)
        .then((onValue) {
      setState(() {
        this.animalCategories = onValue;
      });

      for (var animalCategory in animalCategories) {
        if (animalCategory.id == _animal.animalSubCategory.animalCategoryId) {
          _animalCategory = animalCategory;
          break;
        }
      }
      // _animal
      // if (_product.animalId != null) {
      //   for (var animalCategory in animalCategories) {
      //     if (animalCategory.id == widget.categoryId) {
      //       _animalCategory = animalCategory;
      //       break;
      //     }
      //   }
      // }
      _getAnimalSubCategories();
      showVideoByCategory();

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

  void refreshCurrentImages() {
    // Current Images Initialization
    for (var i = 0; i < currentImages.length; i++) {
      currentAnimalImageID.add(_animal.animalImages[i].id);
      currentImages.add(Column(
        children: <Widget>[
          Container(
              height: 80,
              padding: EdgeInsets.all(5),
              child: FadeInImage.assetNetwork(
                fit: BoxFit.fitHeight,
                placeholder: 'assets/images/loading.gif',
                image: _animal.animalImages[i].thumbnail,
              )),
          Container(
            height: 20,
            child: FlatButton(
                onPressed: () {
                  setState(() {
                    currentImages.removeAt(i);
                    animalImageIdToDelete.add(_animal.animalImages[i].id);
                  });
                },
                color: globals.myColor("danger"),
                child: Container(
                    child: Icon(Icons.delete, size: 16, color: Colors.white))),
          ),
        ],
      ));
    }
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

        for (var animalSubCategory in animalSubCategories) {
          if (animalSubCategory.id == _animal.animalSubCategoryId) {
            _animalSubCategory = animalSubCategory;
            break;
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

  Widget _buildVideo() {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        margin: EdgeInsets.fromLTRB(2, 2, 2, 0),
        // height: 40,
        // color: Colors.white,
        child: InkWell(
            child: Text(
              "Klik Untuk Melihat Video",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => VideoPopupPage(
                          videoPath: _animal.videoPath,
                          animalName: _animal.name)));
            }));
  }

  Widget _buildGridViewImages() {
    return Column(
      children: <Widget>[
        arrayAnimalImages.length > 0
            ? GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                physics: ScrollPhysics(),
                children: List.generate(arrayAnimalImages.length, (index) {
                  return Column(
                    children: <Widget>[
                      Container(
                          // width: 40,
                          height: 100,
                          padding: EdgeInsets.all(5),
                          child: Container(
                            child: FadeInImage.assetNetwork(
                              fit: BoxFit.fitWidth,
                              placeholder: 'assets/images/loading.gif',
                              image: arrayAnimalImages[index].thumbnail,
                            ),
                          )),
                      Container(
                          height: 20,
                          child: FlatButton(
                              onPressed: () async {
                                if (isLoading) return;
                                animalImageIdToDelete
                                    .add(arrayAnimalImages[index].id);
                                arrayAnimalImages.removeAt(index);
                                setState(() {});
                              },
                              color: globals.myColor("danger"),
                              child: Container(
                                  child: Icon(Icons.delete,
                                      size: 16, color: Colors.white)))),
                    ],
                  );
                }))
            : Container(),
        arrayOfAssets.length > 0
            ? GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                physics: ScrollPhysics(),
                children: List.generate(arrayOfAssets.length, (index) {
                  return Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5),
                        child: AssetThumb(
                          asset: arrayOfAssets[index],
                          width: 80,
                          height: 80,
                        ),
                      ),
                      Container(
                          height: 20,
                          child: FlatButton(
                              onPressed: () async {
                                if (isLoading) return;
                                arrayOfAssets.removeAt(index);
                                setState(() {});
                              },
                              color: globals.myColor("danger"),
                              child: Container(
                                  child: Icon(Icons.delete,
                                      size: 16, color: Colors.white)))),
                    ],
                  );
                }))
            : Container(),
      ],
    );

    return currentImages.length > 0
        ? GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            physics: ScrollPhysics(),
            children: List.generate(currentImages.length, (index) {
              return currentImages[index];

              // return currentImages[index];
              return Container(
                  height: 180,
                  child: Column(
                    children: <Widget>[
                      // Container(height: 80, child: currentImages[index]),
                      currentImages[index] is AnimalImage
                          ? Container(
                              height: 80,
                              padding: EdgeInsets.all(5),
                              child: FadeInImage.assetNetwork(
                                fit: BoxFit.fitHeight,
                                placeholder: 'assets/images/loading.gif',
                                // image: currentImages[index],
                              ))
                          : Container(),
                      Container(
                        height: 20,
                        child: FlatButton(
                            onPressed: () async {
                              if (isLoading) return;

                              animalImageIdToDelete
                                  .add(currentAnimalImageID[index]);
                              currentImages.removeAt(index);
                              setState(() {});
                            },
                            color: globals.myColor("danger"),
                            child: Container(
                                child: Icon(Icons.delete,
                                    size: 16, color: Colors.white))),
                      ),
                    ],
                  ));
            }),
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child:
                Center(child: globals.myText(text: "Tidak ada foto terpilih")));

    // return currentImages == null
    //     ? images != null && images.length > 0
    //         ? Container(
    //             padding: EdgeInsets.all(5),
    //             child: GridView.count(
    //               shrinkWrap: true,
    //               crossAxisCount: 3,
    //               physics: ScrollPhysics(),
    //               children: List.generate(images.length, (index) {
    //                 Asset asset = images[index];
    //                 return Container(
    //                   padding: EdgeInsets.all(5),
    //                   child: AssetThumb(
    //                     asset: asset,
    //                     width: 300,
    //                     height: 300,
    //                   ),
    //                 );
    //               }),
    //             ),
    //           )
    //         : Container(
    //             padding: EdgeInsets.symmetric(vertical: 30),
    //             child: globals.myText(
    //                 text: "Belum ada foto terpilih", color: "dark"))
    //     : Container(
    //         padding: EdgeInsets.all(5),
    //         child: GridView.count(
    //           shrinkWrap: true,
    //           crossAxisCount: 3,
    //           physics: ScrollPhysics(),
    //           children: List.generate(currentImages.length, (index) {
    //             return Container(
    //                 height: 180,
    //                 child: Column(
    //                   children: <Widget>[
    //                     // Container(height: 80, child: currentImages[index]),
    //                     Container(
    //                         height: 80,
    //                         padding: EdgeInsets.all(5),
    //                         child: FadeInImage.assetNetwork(
    //                           fit: BoxFit.fitHeight,
    //                           placeholder: 'assets/images/loading.gif',
    //                           image: currentImages[index].thumbnail,
    //                         )),
    //                     Container(
    //                       height: 20,
    //                       child: FlatButton(
    //                           onPressed: () async {
    //                             if (isLoading) return;

    //                             final result = await globals.confirmDialog(
    //                                 "Apakah Anda yakin untuk menghapus foto produk ini? Foto akan terhapus selamanya",
    //                                 context);
    //                             if (result) {
    //                               setState(() {
    //                                 isLoading = true;
    //                               });

    //                               try {
    //                                 bool response =
    //                                     await AnimalServices.deleteImage(
    //                                         "Test", currentImages[index].id);

    //                                 String message = "Berhasil menghapus foto";

    //                                 currentImages.removeAt(index);
    //                                 setState(() {
    //                                   isLoading = false;
    //                                 });
    //                                 if (!response) {
    //                                   message =
    //                                       "Gagal menghapus foto, silahkan coba kembali";
    //                                 }

    //                                 await globals.showDialogs(message, context);
    //                                 Navigator.pop(context);
    //                               } catch (e) {
    //                                 globals.showDialogs(
    //                                     "Gagal menghapus foto, Coba kembali",
    //                                     context);
    //                                 globals.mailError(
    //                                     "Delete image on edit product",
    //                                     e.toString());
    //                               }
    //                             }
    //                           },
    //                           color: globals.myColor("danger"),
    //                           child: Container(
    //                               child: Icon(Icons.delete,
    //                                   size: 16, color: Colors.white))),
    //                     ),
    //                   ],
    //                 ));
    //           }),
    //         ),
    //       );
  }

  Future<void> getVideo() async {
    var video = await ImagePicker.pickVideo(source: ImageSource.gallery);

    var videoLength = video.lengthSync();
    _sizeVideo = (videoLength / 1048576).toStringAsFixed(2);

    // limit max 35 mb
    if (video.lengthSync() > 36700160) { // in binary
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
      // debugPrint(_convertedVideo.toJson().toString());
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
    int maxImage = 5 - arrayAnimalImages.length - arrayOfAssets.length;

    if (maxImage <= 0) {
      globals.showDialogs(
          "Foto produk sudah mencapai jumlah maksimal (5)", context);
      return;
    }

    try {
      resultList = await MultiImagePicker.pickImages(maxImages: maxImage);
    } on PlatformException catch (e) {
      error = e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // final result = await globals.confirmDialog(
    //     "Apakah Anda menggunggah ${resultList.length} foto ini?", context);
    // if (result) {

    // // }
    // if (resultList.length > 0) {
    // final result = await globals.confirmDialog(
    //     "Yakin mengunggah ${resultList.length} foto ini?", context);
    // if (result) {

//         currentImages = null;
// setState(() {
//         // if (error == null) _error = 'No Error Detected';
//       });

    if (resultList.length > 0) {
      setState(() {
        images = resultList;
        arrayOfAssets.addAll(resultList);
      });
      // Current Images - Newly Added
      // for (var i = 0; i < resultList.length; i++) {
      //   currentImages.add(Column(
      //     children: <Widget>[
      //       Container(
      //         padding: EdgeInsets.all(5),
      //         child: AssetThumb(
      //           asset: resultList[i],
      //           width: 80,
      //           height: 80,
      //         ),
      //       ),
      //       Container(
      //         height: 20,
      //         child: FlatButton(
      //             onPressed: () async {
      //               currentImages.removeAt(currentImages.length + 1);
      //               setState(() {});
      //             },
      //             color: globals.myColor("danger"),
      //             child: Container(
      //                 child:
      //                     Icon(Icons.delete, size: 16, color: Colors.white))),
      //       ),
      //     ],
      //   ));
      // }
      _generateImageBase64();
    }
  }

  // _uploadImageAndReset() async {
  //   if (imagesBase64.length > 0) {
  //     Map<String, dynamic> formData = Map<String, dynamic>();
  //     formData['images'] = imagesBase64;

  //     AnimalServices.createImage("", formData, _animal.id)
  //         .then((onValue) async {
  //       Navigator.pop(context);
  //       if (onValue) {
  //         await globals.showDialogs("Berhasil mengunggah foto produk", context,
  //             isDouble: true);
  //       } else {
  //         globals.showDialogs(
  //             "Gagal menunggah foto produk, Coba lagi.", context);
  //       }
  //     }).catchError((onError) {
  //       Navigator.pop(context);
  //       print(onError.toString());
  //       globals.showDialogs("Gagal menunggah foto produk, Coba lagi.", context);
  //       globals.mailError("_uploadImageAndReset", onError.toString());
  //     });
  //   }
  // }

  _generateImageBase64() async {
    imagesBase64 = List<String>();

    for (int i = 0; i < images.length; i++) {
      ByteData byteData = await images[i].requestOriginal(quality: 50);

      List<int> imageData = byteData.buffer.asUint8List();
      // byteData.buffer.asByteData();

      imagesBase64.add(base64Encode(imageData));
    }

    // _uploadImageAndReset();
  }

  _delete() async {
    if (isLoading) return;

    final result = await globals.confirmDialog(
        "Apakah Anda yakin untuk menghapus produk ini? Barang akan terhapus selamanya",
        context);
    if (result) {
      deleteProduct(globals.user.tokenRedis, _animal.product.id)
          .then((onValue) async {
        Navigator.pop(context);
        if (onValue == 1) {
          await globals.showDialogs("Berhasil menghapus produk", context,
              isDouble: true);
        } else if (onValue == 3) {
          await globals.showDialogs(
              "Session anda telah berakhir, Silakan melakukan login ulang",
              context,
              isLogout: true);
        } else {
          globals.showDialogs("Gagal menutup produk, Coba lagi.", context);
        }
      }).catchError((onError) {
        Navigator.pop(context);
        print(onError.toString());
        globals.showDialogs("Gagal menutup produk, Coba lagi.", context);
        globals.mailError("Hapus Product", onError.toString());
      });
    }
  }

  _update() async {
    print("To Delete = $animalImageIdToDelete");
    print("To Record = ${imagesBase64.toString()}");
    if (isLoading) return;

    if (arrayAnimalImages.length == 0 && imagesBase64.length == 0) {
      globals.showDialogs("Tidak ada foto terpilih, minimal 1 foto", context);
      return;
    }

    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      if (!_agreeTerms) {
        globals.showDialogs(
            "Anda harus menyetujui konsekuensi yang akan Anda terima apabila menjual binatang langka/tidak sesuai Undang-Undang",
            context);
        return;
      }

      setState(() {
        isLoading = true;
      });

      Animal animal = Animal();
      animal.animalSubCategoryId = _animalSubCategory.id;
      animal.name = _name;
      animal.description = _description;

      Product product = Product();
      product.price = priceController.numberValue.toInt();
      product.innerIslandShipping = _innerIslandShipping;

      Map<String, dynamic> formDataAnimal = animal.toJson();
      formDataAnimal['add_images'] = imagesBase64;
      formDataAnimal['delete_images'] = animalImageIdToDelete;

      print(formDataAnimal);

      try {
        int responseProduct = await updateProduct(
            globals.user.tokenRedis, product.toJson(), _animal.product.id);
        int responseAnimal = await AnimalServices.updateAnimal(
            globals.user.tokenRedis, formDataAnimal, _animal.id, videoToSent);
        String message = "Berhasil mengupdate produk";

        if (responseAnimal == 2 || responseProduct == 2) {
          await globals.showDialogs(
              "Session anda telah berakhir, Silakan melakukan login ulang",
              context,
              isLogout: true);
          return;
        }

        Navigator.pop(context);
        await globals.showDialogs(message, context);
        Navigator.pop(context);
        Navigator.pushNamed(context, "/profile");
      } catch (e) {
        globals.showDialogs(
            "Gagal mengupdate produk, silahkan coba kembali! ${e.toString()}",
            context);
        globals.mailError("_update product", e.toString());
      }
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

        auction.openBid = int.parse(_openBid);
        auction.multiply = int.parse(_multiply);
        auction.buyItNow = int.parse(_bin);
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
        // bool response = await create(formData);
        // print(response);

        Navigator.pop(context);
        await globals.showDialogs(message, context);
        Navigator.pop(context);
        Navigator.pushNamed(context, "/profile");
      } catch (e) {
        Navigator.pop(context);
        globals.showDialogs(e.toString(), context);
        print(e);
      }
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }

  // void _handleSaveAs(int value) {
  //   setState(() {
  //     _selectProduct.id = value;
  //   });
  // }

  // void _handleGenderChange(String value) {
  //   setState(() {
  //     _gender = value;
  //   });
  // }

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
                        "Edit Produk $labelNamaType",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )),
                // Container(
                //     width: globals.mw(context) * 0.95,
                //     padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                //     child: DropdownButtonFormField<SelectProduct>(
                //       decoration: InputDecoration(
                //           fillColor: Colors.white,
                //           border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(5)),
                //           contentPadding: EdgeInsets.all(13),
                //           hintText: "Simpan Sebagai",
                //           labelText: "Simpan Sebagai"),
                //       value: _test,
                //       validator: (animalCategory) {
                //         if (_animalCategory == null) {
                //           return 'Silahkan pilih simpan sebagai';
                //         }
                //       },
                //       onChanged: (SelectProduct selectProd) {
                //         setState(() {
                //           if (_selectProduct.id != selectProd.id) {
                //             _selectProduct = selectProd;

                //             if (labelNamaType == "Hewan" &&
                //                 selectProd.id == 3) {
                //               _refreshCategory();
                //             } else if (labelNamaType == "Aksesoris" &&
                //                 selectProd.id != 3) {
                //               _refreshCategory();
                //             }

                //             if (_selectProduct.id == 3) {
                //               labelNamaType = "Aksesoris";
                //             } else {
                //               labelNamaType = "Hewan";
                //             }
                //           }
                //         });
                //       },
                //       items: selectProducts.map((SelectProduct selectProduct) {
                //         return DropdownMenuItem<SelectProduct>(
                //             value: selectProduct,
                //             child: Text(selectProduct.name,
                //                 style: TextStyle(color: Colors.black)));
                //       }).toList(),
                //     )),
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
                      controller: nameController,
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
                      controller: descriptionController,
                      // initialValue: _description,
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
                    onPressed: () {
                      // globals.showDialogs(
                      //     "Fitur sedang dikembangkan.. Nantikan segera.",
                      //     context);
                      loadAssets();
                    },
                  ),
                ),
                _buildGridViewImages(),
                SizedBox(height: 10),

                _animal.videoPath != null ? _buildVideo() : Container(),

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
                        onPressed: () => isLoading ? null : _update(),
                        child: Text(!isLoading ? "Simpan Data" : "Mohon Tunggu",
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
                        onPressed: () => isLoading ? null : _delete(),
                        child: Text(
                            !isLoading ? "Hapus Produk" : "Mohon Tunggu",
                            style: Theme.of(context).textTheme.display4),
                        color:
                            isLoading ? Colors.grey : globals.myColor("danger"),
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
