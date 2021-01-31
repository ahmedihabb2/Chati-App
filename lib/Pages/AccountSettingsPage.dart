import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Chati/Widgets/ProgressWidget.dart';
import 'package:Chati/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';



class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text("Account Settings" ,
        style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white)),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}


class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}



class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController nicknameTextEditingController ;
  TextEditingController aboutMeTextEditingController ;
  SharedPreferences preferences;
  String id = '';
  String nickname='';
  String aboutMe='';
  String photoUrl='';
  File imageFileAvatar;
  bool isLoading=false;
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode aboutFocusNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromLocal();
  }

  void readDataFromLocal() async
  {

    preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    nickname = preferences.getString('nickname');
    aboutMe = preferences.getString('aboutMe');
    photoUrl = preferences.getString('photoUrl');
    nicknameTextEditingController = TextEditingController(text: nickname);
    aboutMeTextEditingController = TextEditingController(text: aboutMe);
    setState(() {

    });
  }
  Future getImage() async{
    File newFileImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(newFileImage != null)
      {
        setState(() {
          this.imageFileAvatar = newFileImage;
          isLoading = true;
        });
      }
    uploadImagetoFirestoreAndStorage();
  }
  Future uploadImagetoFirestoreAndStorage() async {
    String mFileName = id;
    StorageReference storageReference = FirebaseStorage.instance.ref().child(mFileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(imageFileAvatar);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value) {
      if (value.error == null)
        {
          storageTaskSnapshot = value;
          storageTaskSnapshot.ref.getDownloadURL().then((newImageurl){
            photoUrl = newImageurl;
            Firestore.instance.collection('users').document(id).updateData({
              "photoUrl" :photoUrl,
              "aboutMe" : aboutMe ,
              "nickname" : nickname
            }).then((data) async {
              await preferences.setString('photoUrl', photoUrl);
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(msg: 'Updated Successfully');
            });
          }, onError: (errMsg){
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Failed To Update Image");
          });
        }
    } , onError: (errorMsg){
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }
  void updateData()
  {
    nameFocusNode.unfocus();
    aboutFocusNode.unfocus();
    setState(() {
      isLoading = false;
    });
    Firestore.instance.collection('users').document(id).updateData({
      "photoUrl" :photoUrl,
      "aboutMe" : aboutMe ,
      "nickname" : nickname
    }).then((data) async {
      await preferences.setString('photoUrl', photoUrl);
      await preferences.setString('nickname', nickname);
      await preferences.setString('aboutMe', aboutMe);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Updated Successfully');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (imageFileAvatar == null)
                      ? (photoUrl != "")
                          ? Material(
                        //Displaying Already Existing Photo
                        child: CachedNetworkImage(
                          placeholder: (context , url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                            ),
                            height: 200.0,
                            width: 200.0,
                            padding: EdgeInsets.all(20),
                          ),
                          imageUrl: photoUrl,
                          height: 200.0,
                          width: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(125.0)),
                        clipBehavior: Clip.hardEdge,
                      )
                          : Icon(Icons.account_circle , size: 190.0 ,color: Colors.grey)
                          : Material(
                        //Display The New Or Updated Image Here
                        child: Image.file(
                          imageFileAvatar,
                          height: 200.0,
                          width: 200.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(125.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      IconButton(
                        icon: Icon(Icons.camera_alt , size: 100.0,color: Colors.white54.withOpacity(0.3)),
                        onPressed: getImage,
                        padding: EdgeInsets.all(0.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.grey,
                        iconSize: 200.0,
                      )
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),
              Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(1.0), child: isLoading ? circularProgress() : Container()),

                  //UserName
                  Container(
                    child: Text(
                      "Profile Name",
                      style: TextStyle(fontStyle: FontStyle.italic , fontWeight: FontWeight.bold , color: Colors.indigo),
                    ),
                    margin: EdgeInsets.only(left: 10.0 , bottom: 5.0 , top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Enter Your Username",
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: nicknameTextEditingController,
                        onChanged: (value){
                          nickname = value;
                        },
                        focusNode: nameFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0 , right: 30.0),
                  ),

                  //Bio Area
                  Container(
                    child: Text(
                      "About Me",
                      style: TextStyle(fontStyle: FontStyle.italic , fontWeight: FontWeight.bold , color: Colors.indigo),
                    ),
                    margin: EdgeInsets.only(left: 10.0 , bottom: 5.0 , top: 30.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Bio...",
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: aboutMeTextEditingController,
                        onChanged: (value){
                          aboutMe = value;
                        },
                        focusNode: aboutFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0 , right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              //Update Button
              Container(
                child: FlatButton(
                  child: Text("Update" , style: TextStyle(fontSize: 16.0)),
                  color: Colors.indigo,
                  highlightColor: Colors.grey,
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                  onPressed: updateData,
                ),
                margin: EdgeInsets.only(top: 50.0 , bottom: 1.0),
              ),
              //LogOut Button
              Padding(
                padding: EdgeInsets.only(left: 50.0 , right: 50.0),
                child: RaisedButton(
                  child: Text("Logout" , style: TextStyle(fontSize: 14.0, color: Colors.white)),
                  color: Colors.red,
                  onPressed: userLogout,
                ),
              )
            ],
          ),
          padding: EdgeInsets.only(left: 15.0 , right: 15.0),
        )
      ],
    );
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> userLogout() async
  {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    this.setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(context) => MyApp()),(Route<dynamic> route)=>false);
  }
}