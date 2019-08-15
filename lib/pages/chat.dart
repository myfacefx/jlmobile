import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jlf_mobile/models/auction.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final Auction auction;

  ChatPage({@required this.auction});

  @override
  _ChatPageState createState() => _ChatPageState(auction);
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Auction auction;

  bool isLoading = false;

  int messagesCount = 0;
  bool hasNewMessage = false;

  FocusNode keyboardNode = FocusNode();
  TextEditingController messageController = TextEditingController();

  ScrollController messagesScrollController = ScrollController();

  File imageFile;
  String imageUrl;

  _ChatPageState(Auction auction) {
    this.auction = auction;
    imageUrl = '';
  }

  Widget _buildMessages() {
    return Flexible(
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('chat_rooms')
                .document(auction.firebaseChatId)
                .collection('chats')
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            globals.myColor("primary"))));
              } else {
                if (messagesScrollController.hasClients) {
                  if (messagesCount > 0 &&
                      messagesCount != snapshot.data.documents.length) {
                    hasNewMessage = true;
                  }
                }

                messagesCount = snapshot.data.documents.length;
                return ListView.builder(
                    shrinkWrap: false,
                    itemBuilder: (context, index) =>
                        _chatMessages(snapshot.data.documents[index], index),
                    itemCount: snapshot.data.documents.length,
                    // reverse: true,
                    controller: messagesScrollController);
              }
            }));
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      // setState(() {
      //   // isLoading = true;
      // });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        _sendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      globals.showDialogs("Hanya dapat mengunggah gambar", context);
    });
  }

  _sendWhatsApp(phone, message) async {
    if (phone.isNotEmpty && message.isNotEmpty) {
      String url = 'https://api.whatsapp.com/send?phone=$phone&text=$message';
      print(url);
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Widget _chatMessages(DocumentSnapshot document, int index) {
    if (messagesScrollController.hasClients) {
      if (hasNewMessage == true) {
        double scrollTo = messagesScrollController.position.maxScrollExtent * 2;
        messagesScrollController.animateTo(scrollTo,
            duration: Duration(milliseconds: 100), curve: Curves.easeOut);

        hasNewMessage = false;
      }
    }

    DateTime unformattedDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(document['timestamp'].toString()));

    String timestamp =
        "${unformattedDate.month.toString()}/${unformattedDate.day.toString()} ${unformattedDate.hour.toString()}:${unformattedDate.minute.toString()}";

    return Column(
      children: <Widget>[
        index > 0
            ? Container()
            : Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(3),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                                child: globals.myText(
                                    text: "JLF Rekber V.01 - Forum Model",
                                    weight: "B",
                                    size: 15,
                                    align: TextAlign.center)),
                            Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Center(
                                    child: globals.myText(
                                        text:
                                            "Selamat datang di JLF Rekber, berikut adalah forum rekber untuk membantu proses transaksi anda. Silahkan menunggu untuk admin bergabung di dalam chat, apabila dalam waktu 5 menit tidak ada response anda dapat menghubungi admin."))),
                            SizedBox(height: 5),
                            Center(
                              child: GestureDetector(
                                  onTap: () {
                                    String phone = "6282223304275";
                                    String invoice =
                                        globals.generateInvoice(auction);
                                    String message =
                                        "Min,%20tolong%20bantu%20forum%20rekber%20kami%20(No Invoice: $invoice)";
                                    _sendWhatsApp(phone, message);
                                    // https://api.whatsapp.com/send?phone=&text=Min,%20tolong%20bantu%20forum%20rekber%20kami
                                    // t   erus di belakangnya dikasih kode unik / invoice nya
                                  },
                                  child: globals.myText(
                                      text: "Klik disini untuk WA Admin",
                                      weight: "B",
                                      color: "primary",
                                      align: TextAlign.center)),
                            ),
                            SizedBox(height: 10),
                            Center(
                                child: globals.myText(
                                    text: "LEMBAR FORM SELLER",
                                    weight: "B",
                                    size: 15)),
                            globals.myText(
                                text:
                                    "Silahkan bagi seller untuk mengisi data berikut"),
                            SizedBox(height: 8),
                            globals.myText(
                                text: "Nama Penjual:", align: TextAlign.left),
                            globals.myText(
                                text: "Nama Pembeli:", align: TextAlign.left),
                            globals.myText(
                                text: "Kode Unik (5 Digit):",
                                align: TextAlign.left),
                            globals.myText(
                                text: "Jenis Hewan/Barang:",
                                align: TextAlign.left),
                            globals.myText(
                                text: "Garansi Hewan/Barang:",
                                align: TextAlign.left),
                            globals.myText(
                                text: "Batas waktu pengambilan paket:",
                                align: TextAlign.left),
                            globals.myText(
                                text: "Nominal Transaksi:",
                                align: TextAlign.left),
                            globals.myText(
                                text: "Nomor Rekening Penjual: ..... Bank: ....",
                                align: TextAlign.left),
                            globals.myText(
                                text: "Nomor Rekening Pembeli: ..... Bank: ....",
                                align: TextAlign.left),
                            SizedBox(height: 8),
                            globals.myText(
                                text:
                                    "(Note: Kolom garansi yang tidak diisi akan dianggap TIDAK BERGARANSI)",
                                weight: "B",
                                align: TextAlign.center),
                            Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Center(
                                  child: FlatButton(
                                    color: globals.myColor("primary"),
                                    child: globals.myText(
                                        text: "Salin Form Diatas", color: "light"),
                                    onPressed: () {
                                      Clipboard.setData(new ClipboardData(
                                          text:
                                              'LEMBAR FORM SELLER\n\nNama Penjual:\nNama Pembeli:\nKode Unik (5 Digit):\nJenis Hewan/Barang:\nGaransi Hewan/Barang:\nBatas waktu pengambilan paket:\nNominal transaksi:\nRekening Penjual: ..... Bank: ......\nRekening Pembeli : ..... Bank ..... \n\n(Nb: kolom garansi yg tidak diisi akan dianggap TIDAK BERGARANSI)'));
                                    },
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
        Row(
            mainAxisAlignment:
                globals.user.id == int.parse(document['sender'].toString())
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.fromLTRB(3, 3, 10, 3),
                  width: globals.mw(context) * 0.65,
                  decoration: BoxDecoration(
                      color: globals.user.id ==
                              int.parse(document['sender'].toString())
                          ? globals.myColor("light")
                          : Colors.blue[100],
                      borderRadius: BorderRadius.circular(8)),
                  margin: EdgeInsets.fromLTRB(0, 5, 10, 0),
                  child: Row(
                    children: <Widget>[
                      Container(
                          height: 35,
                          child: CircleAvatar(
                              radius: 25,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: document['photo'] != null &&
                                          document['photo'].isNotEmpty
                                      ? FadeInImage.assetNetwork(
                                          image: document['photo'],
                                          placeholder:
                                              'assets/images/loading.gif',
                                          fit: BoxFit.cover)
                                      : Image.asset(
                                          'assets/images/account.png')))),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            globals.myText(
                                text: document['username'] != null
                                    ? document['username']
                                    : 'JLF User',
                                weight: "B",
                                decoration: TextDecoration.underline,
                                size: 11),
                            document['type'] == 1
                                ? FadeInImage.assetNetwork(
                                    image: document['content'],
                                    placeholder: 'assets/images/loading.gif',
                                    fit: BoxFit.cover)
                                : globals.myText(text: document['content']),
                            Container(
                                alignment: Alignment.centerRight,
                                child: globals.myText(
                                    text: timestamp,
                                    size: 8,
                                    align: TextAlign.right,
                                    color: "dark")),
                          ],
                        ),
                      ),
                    ],
                  )),
            ]),
      ],
    );
  }

  void _sendMessage(String content, int type) async {
    // type: "0" = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      messageController.clear();

      var documentReference = Firestore.instance
          .collection('chat_rooms')
          .document(auction.firebaseChatId)
          .collection('chats')
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(documentReference, {
          'sender': globals.user.id,
          'sender_token': globals.user.firebaseToken,
          'username': globals.user.username,
          'photo': globals.user.photo,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
          'type': type
        });

        print("Message sent");
      });
    }
  }

  Widget _buildKeyboardInput() {
    // Input
    return Container(
        child: Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.image),
          onPressed: getImage,
          color: Colors.black,
        ),
        Flexible(
          child: Container(
              child: TextField(
            focusNode: keyboardNode,
            controller: messageController,
            style: TextStyle(color: globals.myColor("black")),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: "Message",
                hintStyle: TextStyle(color: globals.myColor("dark")),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
            maxLines: null,
            maxLength: null,
          )),
        ),
        Container(
            child: IconButton(
                icon: Icon(Icons.send),
                color: messageController.text.length > 0
                    ? globals.myColor("primary")
                    : globals.myColor("drk"),
                onPressed: () {
                  if (messageController.text.length > 0) {
                    _sendMessage(messageController.text, 0);
                  }
                  return;
                }))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context,
            showNotification: false, isSubMenu: true),
        body: Scaffold(
            key: _scaffoldKey,
            // drawer: drawer(context),sx
            body: SafeArea(
                child: Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: <Widget>[
                        _buildMessages(),
                        _buildKeyboardInput()
                      ],
                    )))));
  }
}
