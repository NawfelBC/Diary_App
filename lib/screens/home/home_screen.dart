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
import 'package:my_app/screens/home/profile_screen.dart';
import 'package:my_app/screens/wrapper.dart';
import 'package:my_app/services/auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
  
}

class _HomeScreenState extends State<HomeScreen> {
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
  final AuthService _auth = AuthService();
  String error = '';
  String postId = '';
  String currentUsername = '';
  String currentProfileurl = '';
  
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth authh = FirebaseAuth.instance;
    final User? user = authh.currentUser;
    final idofuser = user!.uid;
    
    
    Future<void> setUsername() async {
      setState(() async {
        currentUsername = await getUsername(idofuser);
      });
    }
    Future<void> setProfileurl() async {
      setState(() async {
        currentProfileurl = await getProfileurl(idofuser);
      });
    }
    setUsername();
    setProfileurl();
    return MaterialApp(
        title: 'Flutter Firebase Demo',
        theme: new ThemeData(scaffoldBackgroundColor: Color.fromRGBO(24,24,24, 2)),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading:
              TextButton.icon(
                // icon: ClipRRect(borderRadius: BorderRadius.circular(12.0), child: Image.network(currentProfileurl, width: 30)),
                icon: Icon(Icons.ac_unit, color: Colors.white),
                label: Text('Profile', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  var route = new MaterialPageRoute(
                    builder: (BuildContext context) => new ProfileScreen(currentUsername:currentUsername,currentProfileurl:currentProfileurl),
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
                  // var route = new MaterialPageRoute(
                  //   builder: (BuildContext context) => new Wrapper(),
                  // );
                  // Navigator.of(context).push(route);
                },
              ),
            ],
           
            title: Align(
              alignment: Alignment(0.1,2),
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
          // floatingActionButton: FloatingActionButton.extended(
          //   backgroundColor: Color.fromRGBO(102, 124, 111, 2),
          //   onPressed: () async => [
          //     if ((textController.text == "") & (finalurl == null || finalurl == '')){
          //      setState(() {
          //             error = 'Nothing to post';
          //           }),
          //     }
          //     else
          //       { 
          //         setState(() {
          //             error = '';
          //             postId = DateTime.now().toString() + idofuser;
          //           }),
          //         FirebaseFirestore.instance.collection(idofuser).doc(postId).set({
          //           'text': textController.text,
          //           'timestamp': Timestamp.fromDate(DateTime.now()),
          //           'imageUrl': finalurl != null ? finalurl : '',
          //           'edited': 'N',
          //           'userId': idofuser,
          //           'username': currentUsername,
          //           'profileurl': currentProfileurl,
          //         }),
          //         FirebaseFirestore.instance.collection('all_posts').doc(postId).set({
                    
          //           'text': textController.text,
          //           'timestamp': Timestamp.fromDate(DateTime.now()),
          //           'imageUrl': finalurl != null ? finalurl : '',
          //           'edited': 'N',
          //           'userId': idofuser,
          //           'username': currentUsername,
          //           'profileurl': currentProfileurl,
          //         }),
          //         textController.clear(),
          //         FocusScope.of(context).requestFocus(FocusNode()),
          //         setState(() {
          //           finalurl = null;
          //         })
          //       }
          //   ],
          //   label: Text(
          //     'Send',
          //     style: TextStyle(fontSize: 22),
          //   ),
          //   shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.all(Radius.circular(12))),
          // ),
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
                              fillColor: Color.fromRGBO(50,50,50, 2),
                              filled: true,
                              
                              suffixIcon: IconButton(
                                icon: Icon(Icons.add_a_photo),
                                color: Colors.white,
                                tooltip: 'Upload Image',
                                onPressed: () {
                                  uploadimage().then((imageUrl) {
                                    setState(() {
                                      finalurl = imageUrl;
                                      error = '';
                                    });
                                  });
                                },
                              ),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1),borderRadius: BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1),borderRadius: BorderRadius.all(Radius.circular(10))),
                              labelText: 'Post something',
                              labelStyle: TextStyle(fontSize: 15,color: Colors.white),
                              hintText: 'What’s up ?',
                              hintStyle: TextStyle(color: Colors.white)
                            ),
                          ),
                         Transform.translate(child : 
                         ElevatedButton(
                           child: Text(
                            'Send',
                            style: TextStyle(fontSize: 22),
                          ),
                          style: ElevatedButton.styleFrom(primary: Color.fromRGBO(102, 124, 111, 2)),
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
                                  'text': textController.text,
                                  'timestamp': Timestamp.fromDate(DateTime.now()),
                                  'imageUrl': finalurl != null ? finalurl : '',
                                  'edited': 'N',
                                  'userId': idofuser,
                                  'username': currentUsername,
                                  'profileurl': currentProfileurl,
                                }),
                                FirebaseFirestore.instance.collection('all_posts').doc(postId).set({
                                  
                                  'text': textController.text,
                                  'timestamp': Timestamp.fromDate(DateTime.now()),
                                  'imageUrl': finalurl != null ? finalurl : '',
                                  'edited': 'N',
                                  'userId': idofuser,
                                  'username': currentUsername,
                                  'profileurl': currentProfileurl,
                                }),
                                textController.clear(),
                                FocusScope.of(context).requestFocus(FocusNode()),
                                setState(() {
                                  finalurl = null;
                                })
                              }
                          ],
                        ),offset: Offset(150,1))
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 200),
                      child : finalurl != '' && finalurl != null ? Transform.translate(child: Stack(alignment: Alignment(1.5,1), children: <Widget> [Text('Image successfully uploaded !', style: GoogleFonts.aleo(color: Colors.white, fontSize: 14)),
                    Image.network(finalurl,width: 30)]),offset:Offset(0,-35)) : Text('')),
                    Text(error,style: TextStyle(color: Colors.red, fontSize: 14.0)),
                    Center(child: Container(
                      color: Color.fromRGBO(24, 24, 24, 2),
                      //padding: EdgeInsets.all(12),
                      child: Text('Explore', style: GoogleFonts.alice(color: Colors.white, fontSize: 26)))),
                    SizedBox(height: 13),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('all_posts')
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
                            final userId = (docData['userId'] as String);
                            final username = (docData['username'] as String);
                            
                            return userId == idofuser ? Dismissible(
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
                                                  FirebaseFirestore.instance
                                                  .collection(idofuser)
                                                  .doc(snapshot.data!.docs[index].id)
                                                  .update({ 
                                                    'text': _textFieldController.text,
                                                    'imageUrl': finalurl,
                                                    'edited': 'Y'
                                                  });
                                                  FirebaseFirestore.instance
                                                  .collection('all_posts')
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
                                                  FirebaseFirestore.instance
                                                  .collection(idofuser)
                                                  .doc(snapshot.data!.docs[index].id)
                                                  .update({ 
                                                    'text': _textFieldController.text,
                                                    'edited': 'Y'
                                                  });
                                                  FirebaseFirestore.instance
                                                  .collection('all_posts')
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
                                        color: Color.fromRGBO(50,50,50, 2),
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 1),borderRadius: BorderRadius.all(Radius.circular(10))),
                                        //Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                        //shadowColor: Colors.white,
                                        elevation: 7,
                                        child: Container(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                  dense: true,
                                                  leading: username == currentUsername ? ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                                    currentProfileurl, width: 40))
                                                                 : docData['profileurl'] != '' ? ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                                    docData['profileurl'], width: 40))
                                                                    : Image.network(
                                                                    'https://rohsco.rqoh.com/wp-content/uploads/sites/9/2019/09/default-profile.png', width: 40),
                                                  title: Text('\n' + username,
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white)),
                                                  subtitle: imageUrl != '' 
                                                          ? Column(
                                                            children: <Widget> [
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          Text('\n' + textContent + '\n',
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white))),   
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                              imageUrl)))
                                                          ])
                                                          : Column(children: <Widget> [
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          Text('\n' + textContent + '\n',
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white))),
                                                      ]),              
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
                                                          fontSize: 11, color: Colors.white)),
                                                  isThreeLine: true,
                                                  
                                              )],
                                          ),
                                        )
                                    )
                                  ),  
                                ),
                                background: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    color: Color.fromRGBO(120, 60, 60, 1),
                                  ),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                )
                              ) : Card(
                                        margin: EdgeInsets.all(10),
                                        color: Color.fromRGBO(50,50,50, 2),
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 1), borderRadius: BorderRadius.all(Radius.circular(10))),
                                        //Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                        //shadowColor: Colors.white,
                                        elevation: 7,
                                        child: Container(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                  dense: true,
                                                  leading: username == currentUsername ? ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                                    currentProfileurl, width: 40))
                                                                 : docData['profileurl'] != '' ? ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                                    docData['profileurl'], width: 40))
                                                                    : Image.network(
                                                                    'https://rohsco.rqoh.com/wp-content/uploads/sites/9/2019/09/default-profile.png', width: 40),
                                                  title: Text('\n' + username,
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white)),
                                                  subtitle: imageUrl != '' 
                                                          ? Column(
                                                            children: <Widget> [
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          Text('\n' + textContent + '\n',
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white))),   
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                              imageUrl)))
                                                          ])
                                                          : Column(children: <Widget> [
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          Text('\n' + textContent + '\n',
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white))),
                                                      ]),              
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
                                                          fontSize: 11, color: Colors.white)),
                                                  isThreeLine: true,
                                                  
                                              )],
                                          ),
                                        )
                                    );
                              },
                            ),
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

// getAllPostsId() async {
//   var doclist = [];
//   var values; 
//   await FirebaseFirestore.instance.collection('all_posts').get().then((querySnapshot) => {
//     values = querySnapshot.docs,
//     values.forEach((doc) => {
//         doclist.add(doc.id),
//     })}
//   );
//   return doclist;
// }