import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  ChatPage({@required this.chatId});

  @override
  _ChatPageState createState() => _ChatPageState(chatId);
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String chatId;

  bool isLoading = false;

  int messagesCount = 0;
  bool hasNewMessage = false;

  FocusNode keyboardNode = FocusNode();
  TextEditingController messageController = TextEditingController();

  ScrollController messagesScrollController = ScrollController();

  File imageFile;
  String imageUrl;

  _ChatPageState(String chatId) {
    this.chatId = chatId;
    imageUrl = '';
  }

  Widget _buildMessages() {
    return Flexible(
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('chat_rooms')
                .document(chatId)
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
                        _chatMessages(snapshot.data.documents[index]),
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

  Widget _chatMessages(DocumentSnapshot document) {
    if (messagesScrollController.hasClients) {
      if (hasNewMessage == true) {
        double scrollTo = messagesScrollController.position.maxScrollExtent * 2;
        messagesScrollController.animateTo(scrollTo,
            duration: Duration(milliseconds: 100), curve: Curves.easeOut);

        hasNewMessage = false;
      }
    }

    // return _rightChatMessages(document['type'], document['content']);

    // String timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp'].toString())).toString();

    DateTime unformattedDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(document['timestamp'].toString()));

    String timestamp =
        "${unformattedDate.month.toString()}/${unformattedDate.day.toString()} ${unformattedDate.hour.toString()}:${unformattedDate.minute.toString()}";

    return Row(
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
                                      placeholder: 'assets/images/loading.gif',
                                      fit: BoxFit.cover)
                                  : Image.asset('assets/images/account.png')))),
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
                        document['type'] == 1 ? FadeInImage.assetNetwork(
                                      image: document['content'],
                                      placeholder: 'assets/images/loading.gif',
                                      fit: BoxFit.cover) : globals.myText(text: document['content']),                        
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
        ]);

    // return document['sender'] == role ? _rightChatMessages(document['type'], document['content']) : _leftChatMessages(document['type'], document['content']);
  }

  void _sendMessage(String content, int type) async {
    // type: "0" = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      messageController.clear();

      var documentReference = Firestore.instance
          .collection('chat_rooms')
          .document(chatId)
          .collection('chats')
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(documentReference, {
          'sender': globals.user.id,
          'sender_token' : globals.user.firebaseToken,
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
        Material(
          child: Container(
            color: Colors.transparent,
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            child: IconButton(
              icon: Icon(Icons.image),
              onPressed: getImage,
              color: Colors.black,
            ),
          ),
          color: Colors.white,
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
