import 'package:flutter/material.dart';
import 'Pages/LoginPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chati',
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
