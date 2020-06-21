import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geocoder/geocoder.dart';
import 'package:potholesproject/login.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as Math;
import 'package:image/image.dart' as Im;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class Camera extends StatefulWidget {
  User authenticateUser;
  Camera(this.authenticateUser);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CameraState(authenticateUser);
  }
}

final GlobalKey<ScaffoldState> _scafoldkey = GlobalKey<ScaffoldState>();
final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
class _CompressObject {
  File imageFile;
  String path;
  int rand;

  _CompressObject(this.imageFile, this.path, this.rand);
}
class CameraState extends State<Camera> {
  User authenticateUser;
  bool isloading = false;

  CameraState(this.authenticateUser);
  File _image;
  String description;
  String url;
  var first;
  Position position;

  //image getting function
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  //snackbar message
  showsnack(String message) {
    print(message);
    final snackBar = SnackBar(content: Text(message));
    _scafoldkey.currentState.showSnackBar(snackBar);
  }

//upload image to the firebase
  uploadImage(File image) async {
    
    StorageReference reference =
        FirebaseStorage.instance.ref().child(image.path.toString());
    StorageUploadTask uploadTask = reference.putFile(image);

    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

    url = (await downloadUrl.ref.getDownloadURL());
    print(url);
    complain();
  }
  uplo()async{
    isloading=true;
    setState(() {
      
    });
    String url="http://192.168.43.110:5000/upload";
  String filename = _image.path.split('/').last;
  print(filename);
  Response response;
  Dio dio=new Dio();
  FormData formdata =FormData.fromMap({"image":await MultipartFile.fromString("shahsak"),
  });
  response =await dio.post(url,data:formdata);
  print(response);
    if(response.data=="True"){
      showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Not a pothole photo"),
                title: Text("Failure"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Okay"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // authkey.currentState.reset();
                    },
                  )
                ],
              );
            });
            isloading=false;
            setState(() {
              
            });
    }
    
  }

//location fetch function
  _getLocation() async {
    print(description);
    isloading = true;
    setState(() {});
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // debugPrint('location: ${position.latitude}');
    print("'location: ${position.latitude}'");
    print("'location: ${position.longitude}'");
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    first = addresses.first;
    var second = addresses.last;
    // print(first.adminArea);
    // print(first.countryCode);
    // print(first.coordinates);
    // print(first.locality);//manikpur
    // print(first.subAdminArea);//chitrkoot
    // print(first.subLocality);//sastri nagar ....if it is null then try again
    if (first.locality == null) {
      showsnack("unable to fetch location try again");
    } else {
      print("we can naviagate and store the data into the database");
      uploadImage(_image);
    }

    // print("${second.featureName} : ${second.addressLine}");
    print("${first.featureName} : ${first.addressLine}");
  }
  Future<String> _compressImage(_CompressObject object) async {
  return compute(_decodeImage, object);
}

String _decodeImage(_CompressObject object) {
  Im.Image image = Im.decodeImage(object.imageFile.readAsBytesSync());
  Im.Image smallerImage = Im.copyResize(
      image, width:1024); // choose the size here, it will maintain aspect ratio
  var decodedImageFile = File(object.path + '/img_${object.rand}.jpg');
  decodedImageFile.writeAsBytesSync(Im.encodeJpg(smallerImage, quality: 85));
  return decodedImageFile.path;
}

  uploadFiletoml() async {
    // print("requestsend");
    // final postUri = Uri.parse("http://192.168.43.110:5000/upload");
    // http.MultipartRequest request = http.MultipartRequest('POST', postUri);

    // http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
    //     'image_file', _image.path); //returns a Future<MultipartFile>

    // request.files.add(multipartFile);

    // http.StreamedResponse response = await request.send();
    // print(response);
    // print("requestssssend");
    
  final tempDir = await getTemporaryDirectory();
  final rand = Math.Random().nextInt(10000);
  _CompressObject compressObject =
      _CompressObject(_image, tempDir.path, rand);
  String filePath = await _compressImage(compressObject);
  print('new path: ' + filePath);
  File file = File(filePath);

  // Pop loading

  return file;
    
    Directory dir = await getExternalStorageDirectory();
    print(_image.path);
     var result = await FlutterImageCompress.compressAndGetFile(
        file.path, dir.path,
        quality: 88,
        rotate: 180,
      );
  
    String url="http://192.168.43.110:5000/upload";
  String filename = _image.path.split('/').last;
  print(filename);
  Response response;
  Dio dio=new Dio();
  FormData formdata =FormData.fromMap({"image":await MultipartFile.fromFile(result.path,filename:filename),
  });
  response =await dio.post(url,data:formdata);
  print(response);

  }

  //create complain
  complain() async {
    Map<String, dynamic> complaindata = {
      "name": authenticateUser.name,
      "email": authenticateUser.email,
      "number": authenticateUser.phonenumber,
      "downloadurl": url,
      "address": first.featureName + first.addressLine,
      "description": description,
      "altitude": position.latitude,
      "longitude": position.longitude,
      "respond": "false"
    };
    http
        .post(
            "https://hackathon-360db.firebaseio.com/Complain.json?auth=${authenticateUser.idToken}",
            body: json.encode(complaindata))
        .then((http.Response response) {
      print(response.body);
      Map<String, dynamic> responsedata = json.decode(response.body);
      isloading = false;
      if (responsedata.containsKey('name')) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Your Complain Entered"),
                title: Text("Success"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Okay"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // authkey.currentState.reset();
                    },
                  )
                ],
              );
            });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Your Complain Not Entered Login Again"),
                title: Text("Failure"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Okay"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // authkey.currentState.reset();
                    },
                  )
                ],
              );
            });
      }
      setState(() {});
      isloading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return isloading
        ? Scaffold(
            backgroundColor: Color.fromRGBO(3, 9, 23, 1),
            body: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Color.fromRGBO(3, 9, 23, 1),
            key: _scafoldkey,
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(3, 9, 23, 1),
              title: Text('Take an image'),
            ),
            body: ListView(
              children: <Widget>[
                Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height / 1.5,
                        child: Center(
                          child: _image == null
                              ? Text(
                                  'Take A Photo',
                                  style: TextStyle(color: Colors.white),
                                )
                              : Image.file(_image),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Add description ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 65,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        onSaved: (value) {
                          description = value;
                        },
                        maxLines: 8,
                        decoration: InputDecoration(
                            hintStyle:
                                TextStyle(color: Colors.white, fontSize: 12),
                            hintText: "Enter your description here",
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 0.0),
                            ),
                            border: OutlineInputBorder(
                              gapPadding: 6,
                            )),
                      ),
                    ],
                  ),
                )
              ],
            ),
            floatingActionButton: _image == null
                ? FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: getImage,
                    tooltip: 'Pick Image',
                    child: Icon(
                      Icons.add_a_photo,
                      color: Color.fromRGBO(3, 9, 23, 1),
                    ),
                  )
                : FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: () {
                      print("Shahshank");
                      // uploadImage(_image);
                      _formkey.currentState.save();
                      print(description);
                     description.isEmpty?uplo(): _getLocation();
                      // uploadFiletoml();
                    },
                    tooltip: "Send data",
                    child: Icon(
                      Icons.send,
                      color: Color.fromRGBO(3, 9, 23, 1),
                    )),
          );
  }
}
