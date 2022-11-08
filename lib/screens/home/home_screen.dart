import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/home/profile_screen.dart';
import 'package:my_app/screens/wrapper.dart';
import 'package:my_app/services/auth.dart';
import 'users_screen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:geolocator/geolocator.dart';

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
  TextEditingController _ReportController = new TextEditingController();
  bool checker = false;
  var temp;
  final AuthService _auth = AuthService();
  String error = '';
  String postId = '';
  String currentUsername = '';
  String currentProfileurl = '';
  var valueText;
  var reportContent;
  var like_button_color = Colors.white;
  var showIcon = true;
  Position? _currentPosition;

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
    Future<bool> _handleLocationPermission() async {
      bool serviceEnabled;
      LocationPermission permission;
      
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location services are disabled. Please enable the services')));
        return false;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {   
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permissions are permanently denied, we cannot request permissions.')));
        return false;
      }
      return true;
    }
    Future<void> _getCurrentPosition() async {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) {
        setState(() => _currentPosition = position);
      }).catchError((e) {
        debugPrint(e);
      });
    }
    setUsername();
    setProfileurl();
    return MaterialApp(
        title: 'Diary',
        theme: new ThemeData(scaffoldBackgroundColor: Color.fromRGBO(24,24,24, 2)),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading:
              TextButton.icon(
                icon: Icon(Icons.person, color: Colors.white),
                label: Text('Profile', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => new ProfileScreen(currentUsername:currentUsername,currentProfileurl:currentProfileurl)),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            leadingWidth: 100,
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.logout, color: Colors.white),
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
                          SizedBox(height:30),
                          TypeAheadField(
                            textFieldConfiguration: TextFieldConfiguration(
                                autofocus: false,
                                style: GoogleFonts.aBeeZee(color: Colors.white),
                                decoration: new InputDecoration(
                                    filled: true,
                                    fillColor: Color.fromRGBO(50,50,50, 2),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white,width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: Icon(Icons.search,color: Colors.white),
                                    hintText: 'Search user',
                                    hintStyle: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 17,
                                        fontStyle: FontStyle.italic))),
                            suggestionsCallback: (pattern) async {
                              return await getSuggestion(pattern.toLowerCase());
                            },
                            itemBuilder: (context, suggestion) {
                              return Column(children: [SizedBox(height: 10),ListTile(
                                leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(12.0),
                                          child: suggestion.toString().split('profileurl: ')[1].contains('http') ? Image.network(suggestion.toString().split('profileurl: ')[1])
                                          : Image.network('https://rohsco.rqoh.com/wp-content/uploads/sites/9/2019/09/default-profile.png')),
                                title: Text(suggestion.toString().split('{username:')[1].split(',')[0])),
                                ],
                              );
                            },
                            noItemsFoundBuilder: (value) {
                              var localizedMessage = "No Users Found !";
                              return Text('\n'+localizedMessage+'\n', style: TextStyle(fontSize: 17, color: Colors.grey));
                            },
                            onSuggestionSelected: (suggestion) {
                              if(suggestion.toString().split('userId:')[1].split(',')[0].split('}')[0].split(' ')[1] != idofuser){
                               Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => new UsersScreen(
                                    currentUserId:suggestion.toString().split('userId:')[1].split(',')[0].split('}')[0].split(' ')[1],
                                    currentProfileurl: suggestion.toString().split('profileurl: ')[1].contains('http') 
                                      ? suggestion.toString().split('profileurl: ')[1]
                                      : 'https://rohsco.rqoh.com/wp-content/uploads/sites/9/2019/09/default-profile.png',
                                    currentUsername: suggestion.toString().split('{username:')[1].split(',')[0])),
                                  (Route<dynamic> route) => false,
                                );}
                              else{
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => new ProfileScreen(
                                    currentProfileurl: suggestion.toString().split('profileurl: ')[1].contains('http') 
                                      ? suggestion.toString().split('profileurl: ')[1]
                                      : 'https://rohsco.rqoh.com/wp-content/uploads/sites/9/2019/09/default-profile.png',
                                    currentUsername: suggestion.toString().split('{username:')[1].split(',')[0])),
                                  (Route<dynamic> route) => false,
                                );
                              }
                            },
                          ),
                          SizedBox(height:40),
                          Focus(child: 
                          TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            style: TextStyle(color: Colors.white),
                            controller: textController,
                            decoration: InputDecoration(
                              fillColor: Color.fromRGBO(50,50,50, 2),
                              filled: true,
                              prefixIcon: showIcon ? Icon(Icons.border_color, color: Colors.white) : null,
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
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 1),borderRadius: BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1),borderRadius: BorderRadius.all(Radius.circular(10))),
                              labelText: 'Post something',
                              labelStyle: TextStyle(fontSize: 15,color: Colors.white),
                              hintText: 'What’s up ?',
                              hintStyle: TextStyle(color: Colors.white)
                            ),
                          ), onFocusChange: (hasFocus) {
                            if(hasFocus)
                              setState(() {
                                showIcon = false;
                              });
                            else{
                              setState(() {
                                showIcon = true;
                              });
                            }
                          }),
                         Transform.translate(child : 
                         ElevatedButton(
                           child: Text(
                            'Send',
                            style: TextStyle(fontSize: 22),
                          ),
                          style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(102, 124, 111, 2)),
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
                                await _getCurrentPosition(),
                                FirebaseFirestore.instance.collection(idofuser).doc(postId).set({
                                  'text': textController.text,
                                  'timestamp': Timestamp.fromDate(DateTime.now()),
                                  'imageUrl': finalurl != null ? finalurl : '',
                                  'edited': 'N',
                                  'userId': idofuser,
                                  'username': currentUsername,
                                  'profileurl': currentProfileurl,
                                  'likes': 0,
                                  'liked_by': [],
                                  'position': _currentPosition.toString()
                                }),
                                FirebaseFirestore.instance.collection('all_posts').doc(postId).set({
                                  
                                  'text': textController.text,
                                  'timestamp': Timestamp.fromDate(DateTime.now()),
                                  'imageUrl': finalurl != null ? finalurl : '',
                                  'edited': 'N',
                                  'userId': idofuser,
                                  'username': currentUsername,
                                  'profileurl': currentProfileurl,
                                  'likes': 0,
                                  'liked_by': [],
                                  'position': _currentPosition.toString()
                                }),
                                textController.clear(),
                                FocusScope.of(context).requestFocus(FocusNode()),
                                setState(() {
                                  finalurl = null;
                                })
                              }
                          ],
                        ),offset: Offset(150,1)),
                        Text(error,style: TextStyle(color: Colors.red, fontSize: 14.0)),
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 200),
                      child : finalurl != '' && finalurl != null ? Transform.translate(child: Stack(alignment: Alignment(1.5,1), children: <Widget> [Text('Image successfully uploaded !', style: GoogleFonts.aleo(color: Colors.white, fontSize: 14)),
                    Image.network(finalurl,width: 30)]),offset:Offset(0,-35)) : Text('')),
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
                            final likes = (docData['likes'] as int);
                            final liked_by = (docData['liked_by'] as List);
                            final urlProfile = (docData['profileurl'] as String);
                            
                            return userId == idofuser ? Dismissible(
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
                                                  leading: username == currentUsername && currentProfileurl != '' ? GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => new ProfileScreen(currentUsername:currentUsername,currentProfileurl:currentProfileurl)),
                                                        (Route<dynamic> route) => false,
                                                      );
                                                    },
                                                    child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                                    currentProfileurl, width: 40)))
                                                                 : docData['profileurl'] != '' ? GestureDetector(
                                                                   onTap: () {
                                                                     Navigator.pushAndRemoveUntil(
                                                                      context,
                                                                      MaterialPageRoute(builder: (context) => new ProfileScreen(currentUsername:currentUsername,currentProfileurl:currentProfileurl)),
                                                                      (Route<dynamic> route) => false,
                                                                    );
                                                                   },
                                                                   child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                                    docData['profileurl'], width: 40)))
                                                                    : Image.network(
                                                                    'https://rohsco.rqoh.com/wp-content/uploads/sites/9/2019/09/default-profile.png', width: 40),
                                                  title: Text('\n' + username,
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white)),
                                                  subtitle: imageUrl != '' 
                                                          ? Column(
                                                            children: <Widget> [
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          Text('\n\n' + textContent + '\n',
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white))),   
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: FullScreenWidget(child:
                                                              Image.network(imageUrl))))
                                                          ])
                                                          : Column(children: <Widget> [
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          Text('\n\n' + textContent + '\n',
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white))),
                                                      ]),              
                                                  trailing: Column(children: <Widget> [
                                                  edition == 'Y'
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
                                                  
                                                  ]),
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
                              ) : Card(
                                        margin: EdgeInsets.all(10),
                                        color: Color.fromRGBO(50,50,50, 2),
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 1), borderRadius: BorderRadius.all(Radius.circular(10))),
                                        elevation: 7,
                                        child: Container(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                  dense: true,
                                                  leading: username == currentUsername ? GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => new UsersScreen(currentUserId:userId,currentProfileurl:urlProfile,currentUsername: username)),
                                                        (Route<dynamic> route) => false,
                                                      );
                                                    },
                                                    child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                                    currentProfileurl, width: 40)))
                                                                 : docData['profileurl'] != '' ? GestureDetector(
                                                                   onTap: () {
                                                                     Navigator.pushAndRemoveUntil(
                                                                      context,
                                                                      MaterialPageRoute(builder: (context) => new UsersScreen(currentUserId:userId,currentProfileurl:urlProfile,currentUsername: username)),
                                                                      (Route<dynamic> route) => false,
                                                                    );
                                                                   },
                                                                   child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: Image.network(
                                                                    docData['profileurl'], width: 40)))
                                                                    : Image.network(
                                                                    'https://rohsco.rqoh.com/wp-content/uploads/sites/9/2019/09/default-profile.png', width: 40),
                                                  title: Text('\n' + username,
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white)),
                                                  subtitle: imageUrl != '' 
                                                          ? Column(
                                                            children: <Widget> [
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          Text('\n\n' + textContent + '\n',
                                                          style: TextStyle(
                                                              fontSize: 16, color: Colors.white))),   
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          ClipRRect(
                                                                borderRadius: BorderRadius.circular(12.0),
                                                                child: FullScreenWidget(child:
                                                              Image.network(imageUrl))))
                                                          ])
                                                          : Column(children: <Widget> [
                                                          Align(alignment: Alignment.centerLeft, child:
                                                          Text('\n\n' + textContent + '\n',
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
                                                  
                                              ),
                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ 
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                Text('Report', style:TextStyle(color: Colors.white)), 
                                                IconButton(
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

List getSplitUsername(String username){
  var search = [];
  var username_split = username.toLowerCase().split('');
  String temp = '';
  for(int i=0; i<username_split.length; i++){
    temp = temp + username_split[i];
    search.add(temp);
  }
  return search;
}

Future<List<dynamic>> getSuggestion(String query) async {
  var documents;
  var suggestions = [];
  await FirebaseFirestore.instance
      .collection('usernames_list')
      .get()
      .then((snapshot) {
        documents = snapshot.docs;
      });
  
  for (var doc in documents){
    if(getSplitUsername(doc['username']).contains(query)){
      suggestions.add({'username':doc['username'], 'profileurl':doc['profileurl'], 'userId':doc['userId']});
    }
  }
  return suggestions;
}