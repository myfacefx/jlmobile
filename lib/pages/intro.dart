import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/user/login.dart';
import 'package:jlf_mobile/services/static_services.dart';
import 'package:jlf_mobile/services/user_services.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

List<Map<String, String>> intros = [
  {
    'title': 'Jual Lelang Fauna',
    'description': 'Jual, Beli, dan Lelang Hewan dalam satu aplikasi',
    'image': 'assets/images/intro/1.png'
  },
  {
    'title': 'Lelang Hewan',
    'description':
        'Rasakan kemudahan melelang aneka hewan dengan ratusan pelelang dari seluruh Indonesia',
    'image': 'assets/images/intro/2.png'
  },
  {
    'title': 'Jual Beli Hewan',
    'description':
        'Jual ataupun beli aneka hewan dari ratusan penjual yang berasal dari seluruh nusantara',
    'image': 'assets/images/intro/3.png'
  },
  {
    'title': 'Rekening Bersama',
    'description':
        'Untuk kenyamanan bertransaksi, JLF menyediakan fasilitas rekening bersama yang ditangani langsung oleh tim JLF guna memastikan transaksi lelang maupun jual beli hewan aman dan praktis',
    'image': 'assets/images/intro/4.png'
  },
  {
    'title': 'Hewan Dilindungi',
    'description':
        'JLF mendukung penuh perlindungan hewan yang ditentukan oleh Undang-Undang Republik Indonesia, sehingga kami melarang keras perdagangan hewan terlarang di platform kami',
    'image': 'assets/images/intro/5.png'
  }
];

const x = <String>[
  'assets/images/intro/1.png',
  'assets/images/intro/2.png',
  'assets/images/intro/3.png',
  'assets/images/intro/4.png',
  'assets/images/intro/5.png',
];

class _IntroPageState extends State<IntroPage> {
  int count = 0;

  Widget _image(String assetPath) {
    return Image.asset(
      assetPath,
      // fit: BoxFit.contain,
      // height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    count = 0;
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return;
      },
      child: DefaultTabController(
        length: intros.length,
        child: Scaffold(
          body: Builder(
              builder: (BuildContext context) => Padding(
                    padding: EdgeInsets.all(16),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 26),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: TabBarView(
                              children: intros.map((f) {
                                count++;

                                return Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                      child: _image(f['image']),
                                    ),
                                    // Caption
                                    Positioned(
                                      bottom: count == intros.length
                                          ? 10
                                          : globals.mh(context) * 0.08,
                                      child: Container(
                                        width: globals.mw(context) * 0.9,
                                        child: Column(
                                          children: <Widget>[
                                            globals.myText(
                                                text: f['title'],
                                                weight: "B",
                                                size: 25),
                                            SizedBox(height: 20),
                                            globals.myText(
                                                text: f['description'],
                                                align: TextAlign.center),
                                            count == intros.length
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10, bottom: 0),
                                                    child: RaisedButton(
                                                      child: globals.myText(
                                                          text: "MULAI"),
                                                      color: Colors.white,
                                                      onPressed: () async {
                                                        String text =
                                                            "Hai sobat JLF, Aplikasi ini masih tahap pengembangan (Beta Version) \nMohon masukan demi pengembangan kami ke depannya";
                                                        globals.loadingModel(
                                                            context);
                                                        try {
                                                          final res =
                                                              await getAllStatics(
                                                                  "token");
                                                          Navigator.pop(
                                                              context);

                                                          if (res.length > 0) {
                                                            text = res[0]
                                                                .popUpText;
                                                          }
                                                        } catch (e) {
                                                          Navigator.pop(
                                                              context);
                                                        }

                                                        await globals
                                                            .showDialogs(
                                                                text, context);
                                                        Navigator.pop(context);
                                                        saveLocalData(
                                                            'isNew', "true");
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    LoginPage()));
                                                      },
                                                    ))
                                                : Container()
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 50,
                          right: 50,
                          child: Center(child: TabPageSelector()),
                        )
                      ],
                    ),
                  )),
        ),
      ),
    );
  }
}
