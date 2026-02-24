import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumanth_net_admin/authentication.dart';
import 'package:sumanth_net_admin/firebase_options.dart';
import 'package:sumanth_net_admin/home.dart';
import 'package:sumanth_net_admin/net_pay.dart';
import 'package:sumanth_net_admin/test.dart';
import 'package:sumanth_net_admin/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
    await Firebase.initializeApp(options: FirebaseOptionsConfig.web);
  } else {
    await Firebase.initializeApp();
  }
  // if(!kIsWeb)
    setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      constraints: BoxConstraints(maxWidth: 400),
      child: MaterialApp(
        home: LoginScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins'),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final LocalAuthenticationService auth = locator<LocalAuthenticationService>();
  SharedPreferences prefs;

  int adminNum = 1;
  TextEditingController password_controller = new TextEditingController();

  String admin = '', password = '';

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    checkPermissions().then((value) => logOut());
  }

  Future<bool> checkPermissions() async {
    if(kIsWeb) return true;
    return (await Permission.sms.request().isGranted);
  }

  logOut() async {
    if (kIsWeb) {
      await FirebaseAuth.instance.authStateChanges().first;
    }
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) {
        loginWithBiom();
      }
    });
    prefs = await SharedPreferences.getInstance();
    setState(() {
      adminNum = (prefs.getInt('adminnum') ?? 1);
    });
  }

  loginWithBiom() async {
    // if (kIsWeb) return;
    if (await auth.canAuthenticate) {
      if (await auth.authenticate()) {
        login([
          'sumanth10',
          'srinivas1972',
          'sangeetha1983',
          'snoopy2004'
        ][adminNum - 1]);
      } else {
        scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text('Use Password to login.')));
      }
    }
  }

  login(password) async {
    setState(() {
      loading = true;
    });
    String email = 'admin$adminNum@snet.in';
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: email,
            password: password)
        .catchError((e) {
      print("ERROR: $e");
     ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    });

    Utils.isp = Utils.sscIsp;
    // await Utils.rvrIsp.login();
    await Utils.sscIsp.login();
    // await Utils.rvrIsp.getUsers(context);
    await Utils.sscIsp.getUsers();
    Utils.ispCode = "ssc";

    if(!kIsWeb){
      String token = await FirebaseMessaging.instance.getToken();
      Utils.notif_token = token;
      await FirebaseFirestore.instance
          .collection('data')
          .doc('notif_ids')
          .update({
        'admin${adminNum}': token,
      });
    }

    await prefs.setInt('adminnum', adminNum);
    var tt =
        await FirebaseFirestore.instance.collection('data').doc('net').get();
    Utils.staticIPPrice = tt.data()['static_ip_price'];
    Utils.coupons = tt.data()['coupons'].values.toList();
    Map<String, dynamic> pl = tt.data()['plans'];
    setState(() {
      loading = false;
    });
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ));
  }

  /*login(password) async {
    setState(() {
      loading = true;
    });
    String email = 'admin$adminNum@snet.in';
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: email,
            password: password)
        .catchError((e) {
      print("ERROR: $e");
     ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    });

    if(kIsWeb) {
      var r = await http.post(Utils.LOGIN_API);
      var re = jsonDecode(r.body);
      Utils.authorization = re["message"]['authorization'];
      Utils.headers['authorization'] = Utils.authorization;
    } else {
      var r = await http.post(Utils.LOGIN,
          // body: {"username": "admin@1", "password": "12356"});
          body: {"username": "022825", "password": "bssss888"});

      String s = r.headers['set-cookie'];

      String d = '';
      d = s.substring(s.indexOf('jazewifi_'));
      d = d.substring(0, d.indexOf(';'));
      d = s.substring(0, s.indexOf(';')) + ';' + d;
      Utils.cookie = d;
      Utils.headers['cookie'] = d;
      Utils.authorization = jsonDecode(r.body)['message'];
      Utils.headers['authorization'] = Utils.authorization;

      String token = await FirebaseMessaging.instance.getToken();
      Utils.notif_token = token;
      await FirebaseFirestore.instance
          .collection('data')
          .doc('notif_ids')
          .update({
        'admin${adminNum}': token,
      });
    }

    await prefs.setInt('adminnum', adminNum);
    await FirebaseFirestore.instance.collection('nusers').get().then((v) {
      v.docs.forEach((e) {
        Utils.netUsers[e.id] = e.data();
      });
    });
    var tt =
        await FirebaseFirestore.instance.collection('data').doc('net').get();
    Utils.staticIPPrice = tt.data()['static_ip_price'];
    Utils.coupons = tt.data()['coupons'].values.toList();
    Map<String, dynamic> pl = tt.data()['plans'];
    var sortedKeys = pl.keys.toList(growable: false)
      ..sort((k1, k2) => pl[k1]['i'].compareTo(pl[k2]['i']));
    Utils.plans =
        new Map.fromIterable(sortedKeys, key: (k) => k, value: (k) => pl[k]);
    await Utils.getUsers(context);
    setState(() {
      loading = false;
    });
    SSC.init();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ));
  }*/

  @override
  Widget build(BuildContext context) {
    // Utils.isp.getUsers(context);
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Login',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        // backgroundColor: Colors.white,
        body: AbsorbPointer(
          absorbing: loading,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Admin Login',
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 1, horizontal: 8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black)),
                          child: DropdownButton(
                              isExpanded: true,
                              items: List.generate(
                                  4,
                                  (index) => DropdownMenuItem(
                                        child: Text('admin${index + 1}'),
                                        value: index + 1,
                                      )),
                              value: adminNum,
                              onChanged: (v) {
                                setState(() {
                                  adminNum = v;
                                });
                              }),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: password_controller,
                          maxLines: 1,
                          onFieldSubmitted: (term) {
                            FocusScope.of(context).unfocus();
                            FocusScope.of(context).nextFocus();
                          },
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          textCapitalization: TextCapitalization.none,
                          validator: (pname) {
                            if (pname.isEmpty) {
                              return "Please enter Password";
                            } else {
                              password = pname;
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.black)),
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.black)),
                              fillColor: Colors.white),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState.validate()) {
                              FocusScope.of(context).unfocus();
                              login(password);
                            }
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(primary: Colors.green),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        if (!kIsWeb)
                          ElevatedButton(
                            onPressed: () async {
                              loginWithBiom();
                            },
                            child: Text(
                              'Login with Fingerprint',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(primary: Colors.blue),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              if (loading) Center(child: CircularProgressIndicator())
            ],
          ),
        ),
      ),
    );
  }
}
