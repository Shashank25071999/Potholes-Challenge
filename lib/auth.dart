import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:potholesproject/login.dart';
import 'package:potholesproject/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:potholesproject/Animations/FadeAnimation.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Auth extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AuthState();
  }
}
GlobalKey<FormState> authKey = GlobalKey<FormState>();

class AuthState extends State<Auth> {
  String email;
  String password;
  String confirmpassword;
  String phonenumber;
  String name;
  User authenticateUser = User();

  void signUpfunction(String email, String password) async {
    Map<String, dynamic> successInformation;
    successInformation = await signup(email, password);
    if (successInformation['success']) {
      print('SignUp sucessfully');
      Map<String, dynamic> userdata = {
    'Name': name,
    'email': email,
    'number': phonenumber,
  };

  
     http.post(
        'https://hackathon-360db.firebaseio.com/Users.json?auth=${authenticateUser.idToken}',
        body: json.encode(userdata)).then((http.Response response)async{
           var responsedata=json.decode(response.body);
           print(responsedata);

           SharedPreferences pref=await SharedPreferences.getInstance();
            pref.setString('token', authenticateUser.idToken);
            pref.setString('email', email);
            pref.setString('localId', authenticateUser.id);
            pref.setString('name', name);
            pref.setString('number', phonenumber);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyApp(authenticateUser)));
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

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final Map<String, dynamic> autodata = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyAPY2f696Dn8xwCGimDnXZUEO9tMU3Mrdg',
        body: json.encode(autodata),
        headers: {'Content-Type': 'application/json'});
    Map<String, dynamic> responsedata = json.decode(response.body);
    bool haserror = false;
    String message = 'Somethimg went wrong.';
    if (responsedata.containsKey('idToken')) {
      haserror = true;
      authenticateUser.name=name;
      authenticateUser.email = email;
      authenticateUser.idToken = responsedata['idToken'];
      authenticateUser.id = responsedata['localId'];
      print("shashanksahai");
      print(authenticateUser.id);
      authenticateUser.password = password;

      message = 'Login Successful successeded';
    } else if (responsedata['error']['message'] == 'EMAIL_EXISTS') {
      haserror = false;
      message = 'Email already exists';
    }

    print(response.body);
    return {'success': haserror, 'message': message};
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
                      backgroundColor: Color.fromRGBO(3, 9, 23, 1),
                      body: SingleChildScrollView(
                        padding: EdgeInsets.all(30),
                         child:Form(key: authKey,
                          
                                child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FadeAnimation(1.2, Column(
                              children: <Widget>[
                                SizedBox(height: MediaQuery.of(context).size.height/10,),
                                Text("Register", 
                                style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),),
                              ],
                            )),
                            SizedBox(height: MediaQuery.of(context).size.height/14,),
                            FadeAnimation(1.5, Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey[300]))
                                    ),
                                    child: TextFormField(
                                      
                                      validator: (text){
                                        if(text.isEmpty)
                                        return "Required field";
                                        return null;
                                      },
                                      onSaved: (value){
                                        name=value;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(color: Colors.grey.withOpacity(.8)),
                                        labelText: "Name"
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                    ),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                       validator: (text){
                                        if(text.isEmpty)
                                        return "Required field";
                                        return null;
                                      },
                                      onSaved: (value){
                                        phonenumber=value;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(color: Colors.grey.withOpacity(.8)),
                                        labelText: "Phone number"
                                      ),
                                    ),
                                  ),
                                     Container(
                                    decoration: BoxDecoration(
                                    ),
                                    child: TextFormField(
                                      
                                       validator: (text){
                                        if(text.isEmpty)
                                        return "Required field";
                                        return null;
                                      },
                                       onSaved: (value){
                                        email=value;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(color: Colors.grey.withOpacity(.8)),
                                        labelText: "Email"
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                    ),
                                    child: TextFormField(
                                      
                                      obscureText: true,
                                      
                                       validator: (password){
                                        var result= password.length < 4 ? "Password should have at least 4 characters" : null;
                                            return result;
                                      },
                                       onSaved: (value){
                                        password=value;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(color: Colors.grey.withOpacity(.8)),
                                        labelText: "Password"
                                      
                                      ),
                                    
                                    ),
                                  ),
                                      
                                       Container(
                                     decoration: BoxDecoration(
                                    ),
                                    child: TextFormField(
                                      obscureText: true,
                                       onSaved: (value){
                                        confirmpassword=value;
                                      },
                                        
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(color: Colors.grey.withOpacity(.8)),
                                        labelText: "Confirm Password"
                                      ),
                                      
                                        ),
                                  ),

                                   ],
                                       
                                   ),
                            )),
                             SizedBox(height: 40,),
                             FadeAnimation(1.8, Center(
                                 child: Container(
                                  padding: EdgeInsets.all(15),
                            
                                   width: 120,
                                         child: RaisedButton(
                                         color: Colors.blue[800],
                                 onPressed: (){
                                     authKey.currentState.save();
                                     signUpfunction(email,password);                                     
                                   },
                                     child: Text("Signup", style: TextStyle(
                                     color: Colors.white,
                                     fontWeight: FontWeight.bold,
                                   ),),
                                   splashColor: Colors.black,
                              ),
                                 )
                                    
                            )),



                             
                            SizedBox(height: 5,),
                             FadeAnimation(1.8, Center(
                               child: RaisedButton(
                                 color: Colors.black,
                                 onPressed: (){
                                   Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child:LoginUser()));
                                 },
                                    child: Text("Already have an account? Login",style: TextStyle(
                                   color: Colors.white38,
                                 ),
                                 )
                               )
                                 
                                    
                            )),
                          ],
                        ),
                        )
                         
                      ),
                    );
  }
}
