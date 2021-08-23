import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_app/screens/authenticate/authenticate.dart';
import 'package:my_app/services/auth.dart';

import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUsername;
  final String currentProfileurl;
  ProfileScreen({Key? key, required this.currentUsername,required this.currentProfileurl}) : super (key:key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState(currentUsername,currentProfileurl);
  
}

class _ProfileScreenState extends State<ProfileScreen> {
  String currentUsername;
  String currentProfileurl;
  _ProfileScreenState(this.currentUsername,this.currentProfileurl);
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
  var profileurl;
  TextEditingController textController = new TextEditingController();
  bool checker = false;
  var temp;
  final AuthService _auth = AuthService();
  String error = '';
  String postId = '';
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth authh = FirebaseAuth.instance;
    final User? user = authh.currentUser;
    final idofuser = user!.uid;

    // //Solution where delete/edit works but not pictures
    // Future<void> setUsername() async {
    //   setState(() async {
    //     currentUsername = await getUsername(idofuser);
    //   });
    // }
    // Future<void> setProfileurl() async {
    //   setState(() async {
    //     currentProfileurl = await getProfileurl(idofuser);
    //   });
    // }
    // setUsername();
    // setProfileurl();

    // //Solution where pictures works but not delete/edit
    // getUsername(idofuser).then((result) {   
    //   getProfileurl(idofuser).then((result2) { 
    //     setState(() {
    //       currentUsername = result;
    //       currentProfileurl = result2;
    //     }); 
    //   });  
    // });
    // print('currentProfileurl: ' + currentProfileurl);
    return MaterialApp(
        title: 'Flutter Firebase Demo',
        theme: new ThemeData(scaffoldBackgroundColor: Color.fromRGBO(24,24,24, 2)),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading:
              TextButton.icon(
                icon: Icon(Icons.ac_unit, color: Colors.white), 
                label: Text('Feed', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  var route = new MaterialPageRoute(
                    builder: (BuildContext context) => new HomeScreen(),
                  );
                  Navigator.of(context).push(route);
                },
              ),
            leadingWidth: 100,
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.person, color: Colors.white),
                label: Text('Logout', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  await _auth.signOut();
                },
              ),
            ],
            title: Align(
              alignment: Alignment(0.7,2),
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
              if ((textController.text == "") & (finalurl == null || finalurl == '')){
               setState(() {
                      error = 'Nothing to post';
                    }),
              }
              else
                { 
                  setState(() {
                      error = '';
                      postId = DateTime.now().toString() + idofuser;
                    }),
                  FirebaseFirestore.instance.collection(idofuser).doc(postId).set({
                    //'creator id': ,
                    'text': textController.text,
                    'timestamp': Timestamp.fromDate(DateTime.now()),
                    'imageUrl': finalurl != null ? finalurl : '',
                    'edited': 'N',
                    'userId': idofuser,
                    'username': currentUsername,
                  }),
                  FirebaseFirestore.instance.collection('all_posts').doc(postId).set({
                    //'creator id': ,
                    'text': textController.text,
                    'timestamp': Timestamp.fromDate(DateTime.now()),
                    'imageUrl': finalurl != null ? finalurl : '',
                    'edited': 'N',
                    'userId': idofuser,
                    'username': currentUsername,
                  }),
                  textController.clear(),
                  FocusScope.of(context).requestFocus(FocusNode()),
                  setState(() {
                    finalurl = null;
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
                        Column(children: [
                        IconButton(icon : Icon(Icons.add_a_photo),
                                color: Colors.white,
                                onPressed: () {
                                  print('pressed');
                                  uploadimage().then((imageUrl) {
                                    setState(() {
                                      profileurl = imageUrl;
                                      currentProfileurl = profileurl;
                                    });
                                    FirebaseFirestore.instance.collection(idofuser).doc('profileurl').set({
                                    'profileurl': profileurl,
                                  });
                                  });
                                },
                                ),                             
                        Transform.translate(child:
                          Text(currentUsername, style: GoogleFonts.alegreya(color: Colors.white, fontSize: 26)),
                          offset:Offset(100,20)
                        ),
                          ],
                        ), 
                          currentProfileurl != '' ? Transform.translate(
                              child: Image.network(
                                  currentProfileurl, width: 150),
                              offset:
                                  Offset(-75, -50)
                            )
                          : Transform.translate(
                              child: Image.network(
                                  'https://rohsco.rqoh.com/wp-content/uploads/sites/9/2019/09/default-profile.png', width: 150),
                              offset:
                                  Offset(-75, -50)
                            ),
                      ]),
                    ),
                    
                    Center(child: Container(
                      color: Color.fromRGBO(24, 24, 24, 2),
                      padding: EdgeInsets.all(12),
                      child: Text('Your posts', style: GoogleFonts.alegreya(color: Colors.white, fontSize: 26)))),
                    SizedBox(height: 13),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(idofuser)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot,
                      ) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        return Container(
                            child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
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
                            final username = (docData['username'] as String);
                            return Dismissible(
                                key: UniqueKey(),
                                direction: DismissDirection.endToStart,
                                // confirmDismiss:
                                //     (DismissDirection direction) async {
                                //   return await showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return AlertDialog(
                                //         title:
                                //             const Text("Delete Confirmation"),
                                //         content: const Text(
                                //             "Are you sure you want to delete this post?"),
                                //         actions: <Widget>[
                                //           TextButton(
                                //               onPressed: () =>
                                //                   Navigator.of(context).pop(true),
                                //               child: const Text("Delete")),
                                //           TextButton(
                                //             onPressed: () =>
                                //                 Navigator.of(context)
                                //                     .pop(false),
                                //             child: const Text("Cancel"),
                                //           ),
                                //         ],
                                //       );
                                //     },
                                //   );
                                // },
                                onDismissed: (direction) {
                                  snapshot.data!.docs.remove(index);
                                  FirebaseFirestore.instance
                                      .collection(idofuser)
                                      .doc(snapshot.data!.docs[index].id)
                                      .delete();
                                  FirebaseFirestore.instance
                                      .collection('all_posts')
                                      .doc(snapshot.data!.docs[index].id)
                                      .delete();
                                  // setState(() {
                                  //   error = '';
                                  // });
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
                                                  print('1');
                                                  FirebaseFirestore.instance
                                                  .collection(idofuser)
                                                  .doc(snapshot.data!.docs[index].id)
                                                  .update({ 
                                                    'text': _textFieldController.text,
                                                    'imageUrl': finalurl,
                                                    'edited': 'Y'
                                                  });
                                                  setState(() {
                                                    finalurl = null;
                                                  });
                                                  _textFieldController.clear();
                                                  Navigator.of(context)
                                                    .pop(false);
                                                } else if (finalurl == null){
                                                  print('2');
                                                  FirebaseFirestore.instance
                                                  .collection(idofuser)
                                                  .doc(snapshot.data!.docs[index].id)
                                                  .update({ 
                                                    'text': _textFieldController.text,
                                                    'edited': 'Y'
                                                  });
                                                  setState(() {
                                                    finalurl = null;
                                                  });
                                                  _textFieldController.clear();
                                                  Navigator.of(context)
                                                    .pop(false);
                                                }
                                                else{
                                                  print('3');
                                                  setState(() {
                                                    finalurl = null;
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
                                                      child: Column(children: [ Text(username + '\n\n' + textContent,
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white)),
                                                              Transform.translate(
                                                                child: currentProfileurl != '' ? Image.network(
                                                                    currentProfileurl, width: 40)
                                                                    : Image.network(
                                                                    'https://rohsco.rqoh.com/wp-content/uploads/sites/9/2019/09/default-profile.png', width: 40),
                                                                offset:
                                                                    Offset(-100, -60)
                                                              ),]),
                                                      offset: Offset(1, -4))),
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

Future<String> getUsername(String id) async{
  var username;
  DocumentSnapshot ds = await FirebaseFirestore.instance.collection('usernames_list').doc(id).get();
  username = ds['username'];
  return username;
}

Future<String> getProfileurl(String id) async{
  var profileurl;
  DocumentSnapshot ds = await FirebaseFirestore.instance.collection(id).doc('profileurl').get();
  profileurl = ds['profileurl'];
  return profileurl;
}