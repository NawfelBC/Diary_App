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
  var finalurl;
  TextEditingController textController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Firebase Demo',
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
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async => [
              if ((textController.text == "") & (finalurl == ""))
                {Navigator.of(context).pop()}
              else
                {
                  FirebaseFirestore.instance.collection('posts').add({
                    //'creator id': ,
                    'text': textController.text,
                    'timestamp': Timestamp.fromDate(DateTime.now()),
                    'imageUrl': finalurl != null ? finalurl : '',
                  }),
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
          //floatingActionButtonLocation: ,
          body: new SingleChildScrollView(
            child: Container(
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: TextField(
                            controller: textController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Post',
                              hintText: 'Write your thoughts',
                            ),
                          ),
                        ),
                      ]),
                    ),
                    ElevatedButton(
                      child: Text("Upload Image",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22)),
                      onPressed: () {
                        uploadimage().then((imageUrl) {
                          setState(() {
                            finalurl = imageUrl;
                          });
                        });
                      },
                    ),
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
                                child: SizedBox(
                                    width: 1000,
                                    height: 250,
                                    child: Card(
                                        margin: EdgeInsets.all(10),
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        shadowColor: Colors.blueGrey,
                                        elevation: 10,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                  title: Transform.translate(
                                                      child: Text(textContent,
                                                          style: TextStyle(
                                                              fontSize: 18)),
                                                      offset: Offset(1, 10)),
                                                  trailing: Text(
                                                      DateFormat.yMMMd()
                                                          .add_jm()
                                                          .format(dateTime),
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                  subtitle: imageUrl != ""
                                                      ? Transform.translate(
                                                          child: Image.network(
                                                              imageUrl),
                                                          offset:
                                                              Offset(10, 40))
                                                      : null),
                                            ],
                                          ),
                                        ))),
                                background: Container(
                                    color: Colors.red,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    )));
                          },
                        ));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

Future<String> uploadimage() async {
  XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
      imageQuality: 80);

  Reference ref =
      FirebaseStorage.instance.ref().child(pickedImage!.path.split('/').last);
  await ref.putFile(File(pickedImage.path));
  String imageUrl = await ref.getDownloadURL();
  return imageUrl;
}
