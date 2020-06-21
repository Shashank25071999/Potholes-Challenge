import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:potholesproject/auth.dart';
import 'package:potholesproject/main.dart';
import 'package:potholesproject/Animations/FadeAnimation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';

class LoginUser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginUserState();
  }
}

GlobalKey<FormState> authKey = GlobalKey<FormState>();

class User {
  String email;
  String name;
  String password;
  String id;
  String idToken;
  String phonenumber;
  User({this.email, this.password, this.id, this.idToken});
}

class LoginUserState extends State<LoginUser> {
  void initState() {
    autoLogin();
    super.initState();
  }

  User authenticateUser = User();
  void autoLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString('token');
    if (token != null) {
      authenticateUser.idToken = pref.getString('token');
      authenticateUser.email = pref.getString('email');
      authenticateUser.id = pref.getString('localId');
      authenticateUser.name = pref.getString('name');
      authenticateUser.phonenumber = pref.getString('number');

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => MyApp(authenticateUser)));

      // User authenticateUser =
      //     User(email: email, id: id, password: password, idToken: token);
      //  Navigator.pushReplacement(context,
      //       MaterialPageRoute(builder: (context) => MyApp(authenticateUser,logout)));

    }
  }

  void loginfunction(String email, String password) async {
    Map<String, dynamic> successInformation;
    successInformation = await login(email, password);
    if (successInformation['success']) {
      print('Login Sucessfull');

      http
          .get(
              'https://hackathon-360db.firebaseio.com/Users.json?auth=${authenticateUser.idToken}')
          .then((http.Response response) {
        // print(response.body);
        Map<String, dynamic> responsebody = json.decode(response.body);
        responsebody.forEach((String id, dynamic data) async {
          if (authenticateUser.email == data["email"]) {
            authenticateUser.name = data['Name'];
            authenticateUser.phonenumber = data['number'];
            // print(authenticateUser.name);
            // print(authenticateUser.phonenumber);
            // print(authenticateUser.email);
            // print(authenticateUser.idToken);
            // print(authenticateUser.id);
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.setString('token', authenticateUser.idToken);
            pref.setString('email', authenticateUser.email);
            pref.setString('localId', authenticateUser.id);
            pref.setString('number', authenticateUser.phonenumber);
            pref.setString('name', authenticateUser.name);

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MyApp(authenticateUser)));
          }
        });
      });
    }
    // print('authenticate');
    else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('An error occured'),
              content: Text(successInformation['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final Map<String, dynamic> autodata = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyAPY2f696Dn8xwCGimDnXZUEO9tMU3Mrdg',
        body: jsonEncode(autodata),
        headers: {"Content-Type": "application/json"});
    Map<String, dynamic> responsedata = json.decode(response.body);
    bool haserror = false;
    String message = 'Somethimg went wrong.';
    if (responsedata.containsKey('idToken')) {
      print("Shashankanshul");
      haserror = true;
      message = 'Authentication successeded';
      authenticateUser = User(
          email: email,
          id: responsedata['localId'],
          password: password,
          idToken: responsedata['idToken']);
      // SharedPreferences pref=await SharedPreferences.getInstance();
      // pref.setString('token', responsedata['idToken']);
      // pref.setString('email', email);
      // pref.setString('localId', responsedata['localId']);
      // pref.setString('password', password);

    } else if (responsedata['error']['message'] == 'EMAIL_NOT_FOUND') {
      haserror = false;
      message = 'Email not exists';
    } else if (responsedata['error']['message'] == 'INVALID_PASSWORD') {
      haserror = false;
      message = 'Invalid Password';
    }

    print(response.body);
    return {'success': haserror, 'message': message};
  }

  String email;
  String password;
  String phonenumber;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color.fromRGBO(3, 9, 23, 1),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FadeAnimation(
                1.2,
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 4,
                    ),
                    Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height / 15,
            ),
            FadeAnimation(
                1.5,
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Form(
                    key: authKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey[300]))),
                          child: TextFormField(
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    color: Colors.grey.withOpacity(.8)),
                                labelText: "Email"),
                            validator: (value) =>
                                value.isEmpty ? 'Email cannot be empty' : null,
                            onSaved: (value) {
                              email = value;
                            },
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(),
                          child: TextFormField(
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    color: Colors.grey.withOpacity(.8)),
                                labelText: "Password"),
                            validator: (value) => value.isEmpty
                                ? 'Password cannot be empty'
                                : null,
                            onSaved: (value) {
                              password = value;
                            },
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            SizedBox(
              height: 40,
            ),
            FadeAnimation(
                1.8,
                Center(
                    child: Container(
                  padding: EdgeInsets.all(15),
                  width: 120,
                  child: RaisedButton(
                    color: Colors.blue[800],
                    onPressed: () {
                      authKey.currentState.save();
                      print(email);
                      loginfunction(email, password);
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    splashColor: Colors.black,
                  ),
                ))),
            SizedBox(
              height: 5,
            ),
            FadeAnimation(
                1.8,
                Center(
                    child: RaisedButton(
                        color: Colors.black,
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: Auth()));
                        },
                        child: Text(
                          "Not have an account? SignUp",
                          style: TextStyle(
                            color: Colors.white38,
                          ),
                        ))))
          ],
        ),
      ),
    );
  }
}
