import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:developer';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    KeyboardVisibilityController().onChange.listen((isVisible) {
      final message = isVisible ? 'Keyboard Opened' : 'Keyboard Hidden';
      if (message == 'Keyboard Hidden') {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
  }
  var finalurl;
  
  TextEditingController textController = new TextEditingController();
  bool checker = false;
  var temp;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Firebase Demo',
        theme: new ThemeData(scaffoldBackgroundColor: Color.fromRGBO(24,24,24, 2)),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // leading: Icon(
            //   Icons.ac_unit,
            //   color: Colors.black,
            // ),
            title: Align(
              alignment: Alignment.center,
              child: Text(
                'diary'.toUpperCase(),
                style: GoogleFonts.gruppo(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Color.fromRGBO(124, 144, 153, 2),
            onPressed: () async => [
              if ((textController.text == "") & (finalurl == "")){
                {Navigator.of(context).pop()}
              }
              else
                { 
                  FirebaseFirestore.instance.collection('posts').add({
                    //'creator id': ,
                    'text': textController.text,
                    'timestamp': Timestamp.fromDate(DateTime.now()),
                    'imageUrl': finalurl != null ? finalurl : '',
                    'edited': 'N'
                  }),
                  textController.clear(),
                  FocusScope.of(context).requestFocus(FocusNode()),
                  setState(() {
                    finalurl = '';
                  })
                }
            ],
            label: Text(
              'Send',
              style: TextStyle(fontSize: 22),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          body: ListView(
            children: [ Container(
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(children: <Widget>[
                          TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            style: TextStyle(color: Colors.white),
                            controller: textController,
                            decoration: InputDecoration(
                              // isDense: true,
                              // contentPadding: EdgeInsets.all(40),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.add_a_photo),
                                color: Colors.white,
                                tooltip: 'Upload Image',
                                onPressed: () {
                                  uploadimage().then((imageUrl) {
                                    setState(() {
                                      finalurl = imageUrl;
                                    });
                                  });
                                },
                              ),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1)),
                              labelText: 'Post something',
                              labelStyle: TextStyle(fontSize: 15,color: Colors.white),
                              hintText: 'What’s up ?',
                              hintStyle: TextStyle(color: Colors.white)
                            ),
                          ),
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 200),
                      child : Text((finalurl != '' && finalurl != null) ? 'Image successfully uploaded !' : '', style: GoogleFonts.aleo(color: Colors.white, fontSize: 14))),
                    SizedBox(height: 13),
                    Center(child: Container(
                      color: Color.fromRGBO(24, 24, 24, 2),
                      padding: EdgeInsets.all(12),
                      child: Text('Your posts', style: GoogleFonts.alegreya(color: Colors.white, fontSize: 26)))),
                    SizedBox(height: 13),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot,
                      ) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        return Container(
                            child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                            final docData = snapshot.data!.docs[index];
                            final dateTime = (docData['timestamp'] as Timestamp)
                                .toDate()
                                .toLocal();
                            final textContent = (docData['text'] as String);
                            final imageUrl = (docData['imageUrl'] as String);
                            final edition = (docData['edited'] as String);
                            return Dismissible(
                                key: UniqueKey(),
                                direction: DismissDirection.endToStart,
                                confirmDismiss:
                                    (DismissDirection direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            const Text("Delete Confirmation"),
                                        content: const Text(
                                            "Are you sure you want to delete this post?"),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text("Delete")),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                onDismissed: (direction) {
                                  snapshot.data!.docs.remove(index);
                                  FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(snapshot.data!.docs[index].id)
                                      .delete();
                                },
                                child: Container(
                                    child : GestureDetector(
                                    onTap: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      TextEditingController _textFieldController = TextEditingController();
                                      if (checker)
                                        _textFieldController.text = temp;
                                      else
                                        _textFieldController.text = textContent;
                                      return AlertDialog(
                                        title:
                                            const Text("Edit Post"),
                                        content: TextField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 6,
                                            onChanged: (value) { },
                                            controller: _textFieldController,
                                            decoration: InputDecoration(hintText: 'Text'),
                                          ),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () {
                                                if (finalurl != null){
                                                  FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .doc(snapshot.data!.docs[index].id)
                                                  .update({ 
                                                    'text': _textFieldController.text,
                                                    'imageUrl': finalurl,
                                                    'edited': 'Y'
                                                  });
                                                  setState(() {
                                                    finalurl = '';
                                                  });
                                                  _textFieldController.clear();
                                                  Navigator.of(context)
                                                    .pop(false);
                                                } else if (finalurl == null){
                                                  FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .doc(snapshot.data!.docs[index].id)
                                                  .update({ 
                                                    'text': _textFieldController.text,
                                                    'edited': 'Y'
                                                  });
                                                  setState(() {
                                                    finalurl = '';
                                                  });
                                                  _textFieldController.clear();
                                                  Navigator.of(context)
                                                    .pop(false);
                                                }
                                                else{
                                                  setState(() {
                                                    finalurl = '';
                                                  });
                                                  Navigator.of(context)
                                                    .pop(false);
                                                }
                                                FocusScope.of(context).requestFocus(FocusNode());  
                                              },
                                              child: const Text("Done")),
                                          TextButton(
                                            child: const Text("Change Image"),
                                            onPressed: () async {
                                              await uploadimage().then((imageUrl) {
                                                setState(() {
                                                  checker = true;
                                                  finalurl = imageUrl;
                                                  temp = _textFieldController.text;
                                                });
                                              });
                                            },
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                    );}),
                                    child: Card(
                                        margin: EdgeInsets.all(10),
                                        color: Color.fromRGBO(128, 104, 104, 2),
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 1)),
                                        //Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                        //shadowColor: Colors.white,
                                        elevation: 7,
                                        child: Container(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                  title: Padding(padding: EdgeInsets.only(top:15), child : Transform.translate(
                                                      child: Text(textContent,
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white)),
                                                      offset: Offset(1, 1))),
                                                  trailing: edition == 'Y'
                                                  ? Text(
                                                      '               Edited\n' + DateFormat.yMMMd()
                                                          .add_jm()
                                                          .format(dateTime),
                                                      style: TextStyle(
                                                          fontSize: 12, color: Colors.white))
                                                  : Text(
                                                      DateFormat.yMMMd()
                                                          .add_jm()
                                                          .format(dateTime),
                                                      style: TextStyle(
                                                          fontSize: 12, color: Colors.white)),
                                                  subtitle: imageUrl != ""
                                                      ? Padding(padding: EdgeInsets.only(top:25), child : Transform.translate(
                                                          child: Image.network(
                                                              imageUrl),
                                                          offset:
                                                              Offset(1, 1)))
                                                      : null),
                                            ],
                                          ),
                                        )
                                      )
                                    )
                                  ),
                                  background: Container(
                                      color: Colors.red,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      )
                                  )
                                );
                              },
                            )
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}

Future<String> uploadimage() async {
  XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1980,
      maxHeight: 1080,
      imageQuality: 80);

  Reference ref =
      FirebaseStorage.instance.ref().child(pickedImage!.path.split('/').last);
  await ref.putFile(File(pickedImage.path));
  String imageUrl = await ref.getDownloadURL();
  return imageUrl;
}