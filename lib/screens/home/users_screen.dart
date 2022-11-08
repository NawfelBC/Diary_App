import 'package:firebase_auth/firebase_auth.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
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

class UsersScreen extends StatefulWidget {
  final String currentUserId;
  final String currentProfileurl;
  final String currentUsername;
  UsersScreen({Key? key, required this.currentUserId,required this.currentProfileurl, required this.currentUsername}) : super (key:key);
  @override
  _UsersScreenState createState() => _UsersScreenState(currentUserId,currentProfileurl,currentUsername);
  
}

class _UsersScreenState extends State<UsersScreen> {
  String currentUserId;
  String currentProfileurl;
  String currentUsername;
  _UsersScreenState(this.currentUserId,this.currentProfileurl,this.currentUsername);
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
  TextEditingController _ReportController = new TextEditingController();
  bool checker = false;
  var temp;
  final AuthService _auth = AuthService();
  String error = '';
  String postId = '';
  var allPostsId;
  var valueText;
  var reportContent;
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
                                ]),
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
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                      return AlertDialog(
                                      title: Text("Report"),
                                      content: Text('test'),
                                        
                                      actions: <Widget> [
                                        TextButton(
                                          child: Text('Add/Change image'),
                                          onPressed: () {
                                            uploadimage().then((imageUrl) {
                                              setState(() {
                                                profileurl = imageUrl;
                                                currentProfileurl = profileurl;
                                              });
                                              FirebaseFirestore.instance.collection(idofuser).doc('profileurl').set({
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
                                            Navigator.pop(context);
                                          }),
                                        TextButton(
                                        child: Text('Delete Image'),
                                        onPressed: () {
                                           FirebaseFirestore.instance.collection(idofuser).doc('profileurl').set({
                                              'profileurl': '',
                                              });
                                              allPostsId.forEach((element) async {
                                                DocumentReference documentReference = FirebaseFirestore.instance.collection('all_posts').doc(element);
                                                String x = '';
                                                await documentReference.get().then((snapshot) {
                                                  x = snapshot['username'].toString();
                                                });
                                                if (x == currentUsername){
                                                  FirebaseFirestore.instance.collection('all_posts').doc(element).update({
                                                  'profileurl': '',
                                                  });
                                                }
                                              });
                                              Navigator.pop(context);
                                        }) 
                                      ],
                                    );});  
                                },
                                )]),
                              offset:
                                  Offset(-75, -50)
                            ),
                      ]),
                    ),
                    
                    Center(child: Container(
                      color: Color.fromRGBO(24, 24, 24, 2),
                      child: Text('Posts', style: GoogleFonts.alice(color: Colors.white, fontSize: 26)))),
                    SizedBox(height: 13),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(currentUserId)
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
                            final userId = (docData['userId'] as String);
                            return Card(
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
                                                          child: FullScreenWidget(
                                                        child: Image.network(imageUrl))))
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
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                Text('Report', style:TextStyle(color: Colors.white)), 
                                                IconButton(
                                                  //alignment: Alignment.bottomLeft,
                                                  iconSize: 22,
                                                  icon: Icon(Icons.warning_rounded),
                                                  color: Colors.white,
                                                  tooltip: 'Report',
                                                   onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                      return AlertDialog(
                                                      title: Text("Report"),
                                                      content: TextField( 
                                                        onChanged: (value) { 
                                                          setState(() {
                                                            valueText = value;
                                                          });
                                                        }, 
                                                        controller: _ReportController, 
                                                        decoration: InputDecoration(hintText: "What's the problem ?"), 
                                                      ),
                                                      actions: <Widget> [
                                                        TextButton(
                                                          child: Text('Send'),
                                                          onPressed: () {
                                                            setState(() {
                                                              reportContent = valueText;
                                                              FirebaseFirestore.instance.collection('reported_posts').add({'post': snapshot.data!.docs[index].id,'reported_by': idofuser, 'message': reportContent});
                                                              _ReportController.clear();
                                                              Navigator.pop(context);
                                                            });
                                                          }),
                                                        TextButton(
                                                        child: Text('Cancel'),
                                                        onPressed: () {
                                                          setState(() {
                                                            _ReportController.clear();
                                                            Navigator.pop(context);
                                                          });
                                                        }) 
                                                      ],
                                                    );});  
                                                  }
                                                  
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
                                                    FirebaseFirestore.instance.collection(userId).doc(snapshot.data!.docs[index].id).update({'likes': FieldValue.increment(1)});
                                                    FirebaseFirestore.instance.collection(userId).doc(snapshot.data!.docs[index].id).update({'liked_by': FieldValue.arrayUnion([idofuser])})
                                                    ;}
                                                    else{
                                                      
                                                    FirebaseFirestore.instance.collection('all_posts').doc(snapshot.data!.docs[index].id).update({'likes': FieldValue.increment(-1)});
                                                    FirebaseFirestore.instance.collection('all_posts').doc(snapshot.data!.docs[index].id).update({'liked_by': FieldValue.arrayRemove([idofuser])});
                                                    FirebaseFirestore.instance.collection(userId).doc(snapshot.data!.docs[index].id).update({'likes': FieldValue.increment(-1)});
                                                    FirebaseFirestore.instance.collection(userId).doc(snapshot.data!.docs[index].id).update({'liked_by': FieldValue.arrayRemove([idofuser])});
                                                    }
                                                  },
                                                ),
                                              ])
                                              ])
                                      ],
                                    ),
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