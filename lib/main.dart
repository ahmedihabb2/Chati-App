import 'package:Chati/Pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/LoginPage.dart';

void main()
async{
  WidgetsFlutterBinding.ensureInitialized();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool isLoggedIn = await googleSignIn.isSignedIn();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  runApp(MyApp(isLogged: isLoggedIn,id: preferences.getString('id'),));
}

class MyApp extends StatelessWidget {
  String id;
  bool isLogged;
  MyApp({this.isLogged,this.id});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chati',
      theme: ThemeData(
        primaryColor: Colors.indigo,
      ),
      home: isLogged? HomeScreen(currentUserId: id) : LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
