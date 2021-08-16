import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  TextEditingController textController = new TextEditingController();
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Diary'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async =>
              FirebaseFirestore.instance.collection('posts').add({
            //'creator': ,
            //'image': ,
            'text': textController.text,
            'timestamp': Timestamp.fromDate(DateTime.now()),
            'imageUrl': await uploadimage(),
          }),
          child: Text('Send'),
        ),
        body: new Container(
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
                          fontSize: 20)),
                  onPressed: () async {
                    await uploadimage();
                  },
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .snapshots(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot,
                  ) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        final docData = snapshot.data!.docs[index];
                        final dateTime = (docData['timestamp'] as Timestamp)
                            .toDate()
                            .toLocal();
                        final textContent = (docData['text'] as String);
                        final imageUrl = (docData['imageUrl'] as String);
                        return SingleChildScrollView(
                          child: ListTile(
                              title: Text(textContent),
                              trailing: Text(dateTime.toString()),
                              subtitle: Image.network(imageUrl)),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<String> uploadimage() async {
  var pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1200,
      imageQuality: 80);

  Reference ref = FirebaseStorage.instance.ref().child("unique_name2.jpg");
  await ref.putFile(File(pickedImage!.path));
  String imageUrl = await ref.getDownloadURL();
  return imageUrl;
}
