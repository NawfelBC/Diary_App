import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/wrapper.dart';
import 'package:my_app/services/auth.dart';
import 'home_screen.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';

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
  var allPostsId;
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth authh = FirebaseAuth.instance;
    final User? user = authh.currentUser;
    final idofuser = user!.uid;

    getAllPostsId().then((x) => {
      allPostsId = x
    });
    return MaterialApp(
        title: 'Diary',
        theme: new ThemeData(scaffoldBackgroundColor: Color.fromRGBO(24,24,24, 2)),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading:
              TextButton.icon(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.white), 
                label: Text('Back', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => new HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            leadingWidth: 100,
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.person, color: Colors.white),
                label: Text('Logout', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => new Wrapper()),
                    (Route<dynamic> route) => false,
                  );
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
          body: ListView(
            children: [ Container(
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(children: <Widget>[
                        Column(children: [
                          Container(height: 80, child:
                                                     
                        Column(children: <Widget>[
                          new Transform.translate(child : Text(currentUsername, style: GoogleFonts.alegreya(color: Colors.white, fontSize: 30)), offset:Offset(100,20)),
                          new Transform.translate(child : Text('Joined Diary : ' + DateFormat('yyyy-MM-dd').format(user.metadata.creationTime!), //user.metadata.creationTime.toString().split(' ')[0],
                                                  style: GoogleFonts.alegreya(color: Colors.white, fontSize: 15)), offset:Offset(100,40)),
                          ]),
                          
                          )],
                        ), 
                          currentProfileurl != '' ? Transform.translate(
                              child: Column(children: [ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.network(
                                  currentProfileurl, width: 150)),
                                  
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(102, 124, 111, 2)),
                                    child: Text(
                                      'Update image',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    onPressed: (){
                                      uploadimage().then((imageUrl) {
                                        setState(() {
                                          profileurl = imageUrl;
                                          currentProfileurl = profileurl;
                                        });
                                        FirebaseFirestore.instance.collection(idofuser).doc('profileurl').set({
                                        'profileurl': profileurl,
                                        });
                                        FirebaseFirestore.instance.collection('usernames_list').doc(idofuser).update({
                                        'profileurl': profileurl,
                                        });
                                        allPostsId.forEach((element) async {
                                          DocumentReference documentReference = FirebaseFirestore.instance.collection('all_posts').doc(element);
                                          String x = '';
                                          await documentReference.get().then((snapshot) {
                                            x = snapshot['username'].toString();
                                          });
                                          if (x == currentUsername){
                                            FirebaseFirestore.instance.collection('all_posts').doc(element).update({
                                            'profileurl': profileurl,
                                            });
                                          }
                                        });
                                      });
                                    }          
                              )]),
                              offset:
                                  Offset(-75, -50)
                            )
                          : Transform.translate(
                              child: Column(children: [Image.network(
                                  'https://rohsco.rqoh.com/wp-content/uploads/sites/9/2019/09/default-profile.png', width: 150),

                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(102, 124, 111, 2)),
                                    child: Text(
                                      'Update image',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    onPressed: (){
                                      uploadimage().then((imageUrl) {
                                        setState(() {
                                          profileurl = imageUrl;
                                          currentProfileurl = profileurl;
                                        });
                                        FirebaseFirestore.instance.collection(idofuser).doc('profileurl').set({
                                        'profileurl': profileurl,
                                        });
                                        FirebaseFirestore.instance.collection('usernames_list').doc(idofuser).update({
                                        'profileurl': profileurl,
                                        });
                                        allPostsId.forEach((element) async {
                                          DocumentReference documentReference = FirebaseFirestore.instance.collection('all_posts').doc(element);
                                          String x = '';
                                          await documentReference.get().then((snapshot) {
                                            x = snapshot['username'].toString();
                                          });
                                          if (x == currentUsername){
                                            FirebaseFirestore.instance.collection('all_posts').doc(element).update({
                                            'profileurl': profileurl,
                                            });
                                          }
                                        });
                                      });
                                    }          
                              )]),
                              offset:
                                  Offset(-75, -50)
                            ),
                      ]),
                    ),
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
                            final likes = (docData['likes'] as int);
                            final liked_by = (docData['liked_by'] as List);
                            return Dismissible(
                                key: UniqueKey(),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  showDialog(
                                    context :context,
                                    builder: (context){
                                      return AlertDialog(
                                        title: Text("Delete confirmation"),
                                        content: Text('Are you sure ?'),
                                        actions: <Widget> [
                                          TextButton(
                                            child: Text('Delete'),
                                            onPressed: () {
                                              setState(() {
                                                snapshot.data!.docs.remove(index);
                                                FirebaseFirestore.instance
                                                    .collection(idofuser)
                                                    .doc(snapshot.data!.docs[index].id)
                                                    .delete();
                                                FirebaseFirestore.instance
                                                    .collection('all_posts')
                                                    .doc(snapshot.data!.docs[index].id)
                                                    .delete();
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                  content: Text('Post deleted !'),
                                                  backgroundColor: Colors.red,
                                                  duration: Duration(seconds: 2)));
                                              });
                                            }),
                                          TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            setState(() {
                                              Navigator.pop(context);
                                            });
                                          }) 
                                        ],
                                      );
                                    }); 
                                },
                                child: Container(
                                    child: Card(
                                        margin: EdgeInsets.all(10),
                                        color: Color.fromRGBO(50,50,50, 2),
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 1),borderRadius: BorderRadius.all(Radius.circular(10))),
                                        elevation: 7,
                                        child: Container(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                  dense: true,
                                                  leading: currentProfileurl != '' ? ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                                    currentProfileurl, width: 40))
                                                                 : ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                                    'https://rohsco.rqoh.com/wp-content/uploads/sites/9/2019/09/default-profile.png', width: 40)),
                                                  title: Text('\n' + username,
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white)),
                                                  subtitle: imageUrl != '' 
                                                          ? Column(
                                                            children: <Widget> [
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          Text('\n\n' + textContent + '\n',
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white)
                                                            )
                                                          ),   
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: FullScreenWidget(child:
                                                              Image.network(imageUrl))))
                                                          ]
                                                          )
                                                          : Column(children: <Widget> [
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          Text('\n\n' + textContent + '\n',
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white))),
                                                      ]
                                                      ),              
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
                                                  
                                              ),
                                               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                Column(children: [ 
                                                Text('Edit', style:TextStyle(color: Colors.white)), 
                                                IconButton(
                                                  icon: Icon(Icons.edit),
                                                  color: liked_by.contains(idofuser) ? Colors.white : Colors.white,
                                                  tooltip: 'Edit',
                                                  onPressed: () {
                                                    showDialog(
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
                                                              child: const Text("Add/Change Image"),
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
                                                              onPressed: () {
                                                                setState(() {
                                                                  finalurl = null;
                                                                  Navigator.of(context)
                                                                      .pop(false);
                                                                });
                                                                  },
                                                              child: const Text("Cancel"),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                    );
                                                  },
                                                )]),  
                                                
                                                Column(children: [
                                                Text(likes.toString(), style:TextStyle(color: Colors.white)), 
                                                IconButton(
                                                  icon: Icon(Icons.favorite),
                                                  color: liked_by.contains(idofuser) ? Colors.red : Colors.white,
                                                  tooltip: 'Like',
                                                   onPressed: () {
                                                    if(liked_by.contains(idofuser) == false){
                                                    
                                                    FirebaseFirestore.instance.collection('all_posts').doc(snapshot.data!.docs[index].id).update({'likes': FieldValue.increment(1)});
                                                    FirebaseFirestore.instance.collection('all_posts').doc(snapshot.data!.docs[index].id).update({'liked_by': FieldValue.arrayUnion([idofuser])});
                                                    FirebaseFirestore.instance.collection(idofuser).doc(snapshot.data!.docs[index].id).update({'likes': FieldValue.increment(1)});
                                                    FirebaseFirestore.instance.collection(idofuser).doc(snapshot.data!.docs[index].id).update({'liked_by': FieldValue.arrayUnion([idofuser])})
                                                    ;}
                                                    else{
                                                      
                                                    FirebaseFirestore.instance.collection('all_posts').doc(snapshot.data!.docs[index].id).update({'likes': FieldValue.increment(-1)});
                                                    FirebaseFirestore.instance.collection('all_posts').doc(snapshot.data!.docs[index].id).update({'liked_by': FieldValue.arrayRemove([idofuser])});
                                                    FirebaseFirestore.instance.collection(idofuser).doc(snapshot.data!.docs[index].id).update({'likes': FieldValue.increment(-1)});
                                                    FirebaseFirestore.instance.collection(idofuser).doc(snapshot.data!.docs[index].id).update({'liked_by': FieldValue.arrayRemove([idofuser])});
                                                    }
                                                  },
                                                ),
                                              ])
                                              ])
                                            ],
                                          ),
                                        )
                                      )
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

getAllPostsId() async {
  var doclist = [];
  var values; 
  await FirebaseFirestore.instance.collection('all_posts').get().then((querySnapshot) => {
    values = querySnapshot.docs,
    values.forEach((doc) => {
        doclist.add(doc.id),
    })}
  );
  return doclist;
}