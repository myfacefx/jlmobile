import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';
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

  bool isLoading = false;

  FocusNode usernameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  
  List<AnimalCategory> animalCategories = List<AnimalCategory>();
  AnimalCategory _animalCategory;

  List<AnimalSubCategory> animalSubCategories = List<AnimalSubCategory>();
  AnimalSubCategory _animalSubCategory;

  String _name;
  String _description;
  String _openBid;
  String _bin;
  String _multiply;
  String _bidType;

  List<Asset> images = List<Asset>();
  String _error;

  // int _id;
  // String _name;
  // String _email;
  // String _username;
  // String _password;

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
  }

  _getAnimalSubCategories() {
    setState(() {
      isLoading = true;
    });
    if (_animalCategory != null) {
      getAnimalSubCategoryByCategoryId("token", _animalCategory.id).then((onValue) {
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
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
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
        maxImages: 300,
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
      if (error == null) _error = 'No Error Dectected';
    });
  }

  _save() async {
    if (isLoading) return;

    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      _formKey.currentState.save();

      Animal animal = Animal();
      animal.animalSubCategoryId = _animalSubCategory.id;
      animal.name = _name;
      animal.gender = 'F';
      animal.dateOfBirth = DateTime.now();
      animal.description = _description;
      animal.ownerUserId = globals.user.id;
      animal.regencyId = 2;
      animal.slug = _name + "-" + DateTime.now().toString();

      Animal animalResult = await create(animal.toJson());

      print(animalResult.toJson().toString());

      Auction auction = Auction();
      auction.animalId = 1;
      auction.openBid = 1;
      auction.multiply = 2;
      auction.buyItNow = 99;
      auction.expiryDate = '2019-11-01';
      auction.ownerUserId = globals.user.id;
      auction.active = 1;
      auction.slug = 'test' + "-" + DateTime.now().toString();

      Animal auctionResult = await create(auction.toJson());

      print(auctionResult.toJson().toString());

      // $table->unsignedBigInteger('animal_id');
      // $table->foreign('animal_id')->references('id')->on('animals');
      // $table->unsignedBigInteger('open_bid');
      // $table->unsignedBigInteger('multiply');
      // $table->unsignedBigInteger('buy_it_now');
      // $table->timestamp('expiry_date');
      // $table->unsignedBigInteger('owner_user_id');
      // $table->foreign('owner_user_id')->references('id')->on('users');
      // $table->boolean('active');
      // $table->string('slug');

      // print(animal.toJson());


      if (animalResult != null && auctionResult != null) {
        globals.showDialogs("Berhasil menambah data hewan lelang", context);
      } else {
        globals.showDialogs("Gagal menambah data hewan lelang", context);
      }
      
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        autoValidate = true;
      });
    }
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
          !isLoading
              ? Container()
              : Center(child: CircularProgressIndicator()),
          
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
                      "ADD NEW AUCTION PRODUCT",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  )),
                Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: DropdownButtonFormField<AnimalCategory>(
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
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
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: DropdownButtonFormField<AnimalSubCategory>(
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
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
                    items: animalSubCategories.map((AnimalSubCategory category) {
                      return DropdownMenuItem<AnimalSubCategory>(
                          value: category,
                          child: Text(category.name,
                              style: TextStyle(color: Colors.black)));
                    }).toList(),
                  )),
                
                Container(
                    width: 300,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: TextFormField(
                      onSaved: (String value) {
                        _name = value;
                      },
                      onFieldSubmitted: (String value) {
                        // if (value.length > 0) {
                          // FocusScope.of(context).requestFocus(usernameFocusNode);
                        // }
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Nama Hewan",
                          labelText: "Nama Hewan",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    )),
                Container(
                    width: 300,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: TextFormField(
                      initialValue: _description,
                      // focusNode: usernameFocusNode,
                      onSaved: (String value) {
                        _description = value;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
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
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Deskripsi",
                          labelText: "Deskripsi",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    )),
                Container(
                    width: 300,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: TextFormField(
                      initialValue: _openBid,
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
                          return 'Open bid wajib diisi';
                        }
                      },
                      style: TextStyle(color: Colors.black),
                      // keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Open Bid",
                          labelText: "Open Bid",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    )),
                Container(
                    width: 300,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: TextFormField(
                      initialValue: _bin,
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
                          return 'Harga Buy It Now (BIN) wajib diisi';
                        }
                      },
                      style: TextStyle(color: Colors.black),
                      // keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Buy It Now (BIN)",
                          labelText: "Buy It Now (BIN)",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    )),
                Container(
                    width: 300,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: TextFormField(
                      initialValue: _multiply,
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
                          return 'Harga multiply wajib diisi';
                        }
                      },
                      style: TextStyle(color: Colors.black),
                      // keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(13),
                          hintText: "Multiply (Kelipatan Bid)",
                          labelText: "Multiply (Kelipatan Bid)",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    )),
                // Container(
                //   width: 300,
                //   padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                //   child: DropdownButtonFormField<String>(
                //     decoration: InputDecoration(
                //         fillColor: Colors.white,
                //         border: OutlineInputBorder(
                //             borderRadius: BorderRadius.circular(20)),
                //         contentPadding: EdgeInsets.all(13),
                //         hintText: "Bid Type",
                //         labelText: "Bid Type"),
                //     value: _bidType,
                //     validator: (value) {
                //       if (value == null) {
                //         return 'Silahkan pilih tipe bid';
                //       }
                //     },
                //     onChanged: (String bidType) {
                //       setState(() {
                //         _bidType = bidType;
                //       });
                //     },
                //     // items: [
                //     //   DropdownMenuItem<String>(value:'24 Hours', child: Text('24 Hours'), 
                //     //   DropdownMenuItem<String>(value:'24 Hours', child: Text('48 Hours')
                //     // ]
                //     // items: animalSubCategories.map((AnimalSubCategory category) {
                //     //   return DropdownMenuItem<AnimalSubCategory>(
                //     //       value: category,
                //     //       child: Text(category.name,
                //     //           style: TextStyle(color: Colors.black)));
                //     // }).toList(),
                //   )),
                RaisedButton(
                  child: Text("Pick images"),
                  onPressed: loadAssets,
                ),
                _buildGridViewImages(),
                SizedBox(
                  height: 20
                ),
                Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: FlatButton(
                      onPressed: () => isLoading ? null : _save(),
                      child: Text(!isLoading ? "Buat Lelang" : "Mohon Tunggu",
                          style: Theme.of(context).textTheme.display4),
                      color: isLoading
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)))),
                // Flexible(
                //   child: _buildGridViewImages(),
                // )
                
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
                //             value.length < 5 ||
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
                //         // _register();
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
                // Container(
                //     width: 300,
                //     padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                //     child: FlatButton(
                //         onPressed: () => loading,
                //         child: Text(!loading ? "Simpan Perubahan" : "Mohon Tunggu",
                //             style: Theme.of(context).textTheme.display4),
                //         color: loading
                //             ? Colors.grey
                //             : Theme.of(context).primaryColor,
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(20)))),
              ]),
            ),
          ])
        ])),
      ),
    );
  }
}