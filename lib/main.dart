import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:potholesproject/auth.dart';
import 'package:potholesproject/camera.dart';
import 'package:potholesproject/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(accentColor: Color.fromRGBO(3, 9, 23, 1)),
      home: LoginUser(),
      debugShowCheckedModeBanner: false,
    ));

class MyApp extends StatefulWidget {
  User authenticateUser;

  MyApp(this.authenticateUser);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState(authenticateUser);
  }
}

class Complainclass {
  String address;
  double altitude;
  double longitude;
  String downloadurl;
  String phonenumber;
  String description;
  String email;
  String name;
  String respond;
}

class MyAppState extends State<MyApp> {
  void initState() {
    isloading = true;
    complaints();
    super.initState();
  }

  map(double alt, double long) async {
    final availableMaps = await MapLauncher.installedMaps;
    await availableMaps.first.showMarker(
      coords: Coords(alt, long),
      title: "Shanghai Tower",
      description: "Asia's tallest building",
    );
  }

  void _launchMapsUrl(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';

    await launch(url);
  }

  bool isloading = true;
  List<Complainclass> totalcomplain = [];
  complaints() async {
    isloading = true;
    setState(() {});
    http
        .get(
            'https://hackathon-360db.firebaseio.com/Complain.json?auth=${authenticateUser.idToken}')
        .then((http.Response response) {
      print(response.body);
      Map<String, dynamic> responsedata = json.decode(response.body);
      responsedata.forEach((String id, dynamic data) async {
        Complainclass comp = Complainclass();
        comp.address = data['address'];
        comp.altitude = data['altitude'];
        comp.description = data['description'];
        comp.downloadurl = data['downloadurl'];
        comp.email = data['email'];
        comp.longitude = data['longitude'];
        comp.name = data['name'];
        comp.phonenumber = data['number'];
        comp.respond = data['respond'];
        totalcomplain.add(comp);
      });

      isloading = false;
      setState(() {});
    });
  }

  User authenticateUser;
  MyAppState(this.authenticateUser);
  void logout() async {
    print(authenticateUser.name);
    authenticateUser = null;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('token');
    pref.remove('email');
    pref.remove('localId');
    pref.remove('name');
    pref.remove('number');
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return isloading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            drawer: new Drawer(
              child: ListView(
                children: <Widget>[
                  new UserAccountsDrawerHeader(
                    decoration:
                        BoxDecoration(color: Color.fromRGBO(3, 9, 23, 1)),
                    accountName: new Text(
                      authenticateUser.name,
                      style: TextStyle(color: Colors.white),
                    ),
                    accountEmail: new Text(
                      authenticateUser.email,
                      style: TextStyle(color: Colors.white),
                    ),
                    currentAccountPicture: new CircleAvatar(
                      backgroundColor: Colors.white,
                      child: new Text(
                        authenticateUser.name[0].toUpperCase(),
                        style: TextStyle(
                            color: Color.fromRGBO(3, 9, 23, 1), fontSize: 25),
                      ),
                    ),
                  ),
                  new Divider(),
                  new ListTile(
                    title: Text(
                      'Logout',
                      style: TextStyle(
                          color: Color.fromRGBO(3, 9, 23, 1), fontSize: 16),
                    ),
                    trailing: new Icon(Icons.lock),
                    onTap: () {
                      logout();
                    },
                  ),
                  new Divider(),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.camera,
                color: Color.fromRGBO(3, 9, 23, 1),
              ),
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Camera(authenticateUser)))
                    .then((val) => complaints);
              },
            ),
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(3, 9, 23, 1),
              title: Text("All Complaints"),
            ),
            body: ListView.separated(
              separatorBuilder: (context, int index) {
                return Divider(
                  color: Colors.black,
                );
              },
              itemBuilder: (context, int index) {
                return Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      color: Color.fromRGBO(3, 9, 23, 1),
                      child: InkWell(
                        onTap: () {
                          map(totalcomplain[index].altitude,
                              totalcomplain[index].longitude);
                          // _launchMapsUrl(totalcomplain[index].altitude,totalcomplain[index].longitude);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              // child: Image.network(
                              //   totalcomplain[index].downloadurl,
                              //   height: MediaQuery.of(context).size.height / 4,
                              //   fit: BoxFit.fill,
                              // ),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/ajax-loader.gif',
                                image: totalcomplain[index].downloadurl,
                                height: MediaQuery.of(context).size.height / 4,
                                fit: BoxFit.fill,
                              ),
                            ),
                            // Container(height: MediaQuery.of(context).size.height/4,width: MediaQuery.of(context).size.width,child: Image.network(totalcomplain[index].downloadurl)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.location_city,
                                      color: Colors.white),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Text(
                                      totalcomplain[index].address,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.description, color: Colors.white),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Text(
                                      totalcomplain[index].description,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )),
                );
              },
              itemCount: totalcomplain.length,
            ));
  }
}
