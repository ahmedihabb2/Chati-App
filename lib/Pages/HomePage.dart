import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Chati/Models/user.dart';
import 'package:Chati/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Chati/Pages/ChattingPage.dart';
import 'package:Chati/Pages/AccountSettingsPage.dart';
import 'package:Chati/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';


class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen({Key key , @required this.currentUserId}) : super(key : key);
  @override
  State createState() => HomeScreenState(currentUserId : currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  final String currentUserId;
  HomeScreenState({Key key , @required this.currentUserId});
  bool appear = false;
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  homeAppbar()
  {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(Icons.settings , size: 30.0, color: Colors.white),
          onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>Settings()));},
        ),
        IconButton(
          icon: Icon(Icons.person_add , size: 30.0,color: Colors.white),
          onPressed: (){
            setState(() {
              appear =true;
            });
          },
        )
      ],
      title: appear ? Container(
        margin: new EdgeInsets.only(bottom: 4.0),
        child: TextFormField(
          style: TextStyle(fontSize: 18.0 , color: Colors.white),
          controller: searchTextEditingController,
          decoration: InputDecoration(
            hintText: "Search for user",
            hintStyle: TextStyle(color: Colors.blueGrey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)
            ),
            filled: true,
            prefixIcon: IconButton(
              icon: Icon(Icons.close , color: Colors.white),
              onPressed: (){
                setState(() {
                  appear = false;
                });
              },
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.delete , color: Colors.white,),
              onPressed: emptyTextfield,
            )
          ),
            onFieldSubmitted: controlSearching,
        ),
      ) : Text('Chati',
      style: TextStyle(color: Colors.white,
      fontSize: 30.0,
        fontWeight: FontWeight.bold,
      ),)
    );
  }
  controlSearching(String userName)
  {
    Future<QuerySnapshot> allFoundUsers = Firestore.instance.collection('users')
        .where('nickname' , isGreaterThanOrEqualTo: userName ).getDocuments();

    setState(() {
      futureSearchResults = allFoundUsers;
    });
  }
  emptyTextfield(){
    searchTextEditingController.clear();
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppbar(),
      body: (futureSearchResults == null) ? noSearchResultsFound() : displaySearchResults(),
    );
  }
  displaySearchResults()
  {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context , dataSnapShot){
        if(! dataSnapShot.hasData)
          {
            return circularProgress();
          }
        List<UserResult>  searchUserResults=[];
        dataSnapShot.data.documents.forEach((document){
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          if(currentUserId != document['id'])
            {
              searchUserResults.add(userResult);
            }
        });
        return ListView(children: searchUserResults);
      },
    );
  }
  noSearchResultsFound()
  {
  final Orientation orientation = MediaQuery.of(context).orientation;
  return Container(
    child: Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Text(
            'Welcome To Chati .. \n Search for users and start Chatting' ,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black26 , fontSize: 20.0 , fontWeight: FontWeight.w500),
          )
        ],
      ),
    ),
  );
}
}

class UserResult extends StatelessWidget
{
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            GestureDetector(
              onTap: ()=>sendUsertoChatpage(context),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.nickname ,
                  style: TextStyle(color: Colors.black , fontSize: 16.0 , fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Joined: ' + DateFormat("dd MMMM, yyyy - hh:mm:aa")
                      .format(DateTime.fromMillisecondsSinceEpoch(int.parse(eachUser.createdAt))),
                  style: TextStyle(color: Colors.grey , fontSize: 14.0 , fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  sendUsertoChatpage(BuildContext context)
  {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Chat(receiverId : eachUser.id , receiverPUrl: eachUser.photoUrl , receiverName: eachUser.nickname)));
  }
}