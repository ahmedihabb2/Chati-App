import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhoto extends StatelessWidget {
  String url;
  FullPhoto({Key key , @required this.url}) : super(key : key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text(
          'Image Preview',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: FullPhotoScreen(url: url),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  String url;
  FullPhotoScreen({Key key , @required this.url}) : super(key : key);
  @override
  State createState() => FullPhotoScreenState(url : url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  String url;
  FullPhotoScreenState({Key key , @required this.url}) ;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(imageProvider: NetworkImage(url)),
    );
  }
}
