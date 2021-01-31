import 'dart:async';
import 'package:Chati/Pages/Listtile%20model.dart';
import 'package:Chati/Pages/SearchPage.dart';
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
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen({Key key , @required this.currentUserId}) : super(key : key);
  @override
  State createState() => HomeScreenState(currentUserId : currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  SharedPreferences preferences;
  List ChattingWith = [];
  final String currentUserId;
  HomeScreenState({Key key , @required this.currentUserId});
  bool appear = false;
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  homeAppbar()
  {
    return AppBar(
      backgroundColor: Colors.indigo,
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
             Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchScreen(currentUserId: currentUserId,)));
            });
          },
        )
      ],
      title:  Text('Chati',
      style: TextStyle(color: Colors.white,
      fontSize: 25.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2
      ),)
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocal();
  }
  getLocal() async{
   preferences= await SharedPreferences.getInstance();
   ChattingWith = preferences.getStringList('CHattingWith');
   print(ChattingWith);
   if(ChattingWith == null)
     {
       ChattingWith = [];
     }
   setState(() {

   });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppbar(),
      body: ListView.builder(
        itemBuilder: ((context,index){
          return Padding(
            padding: const EdgeInsets.only(left:8.0 , bottom: 8.0 , right: 8.0),
            child: TileModel(id: ChattingWith[index],),
          );
        }),
        itemCount:  ChattingWith.length,
      ),
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

