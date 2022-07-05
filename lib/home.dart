import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sumanth_net_admin/cable/cable_payments.dart';
import 'package:sumanth_net_admin/isp/jaze_isp.dart';
import 'package:sumanth_net_admin/main.dart';
import 'package:sumanth_net_admin/users.dart';

import 'coupons.dart';
import 'net_payments.dart';
import 'net_plans.dart';
import 'utils.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> scafKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = [];

  static List<List> _widgetDetails = <List>[
    [Icon(Icons.home_outlined), Icon(Icons.home_rounded), 'Home'],
    [
      Icon(Icons.supervised_user_circle_outlined),
      Icon(Icons.supervised_user_circle_rounded),
      'All Users'
    ],
    [
      ImageIcon(AssetImage("assets/icons/Net Payments Outlined.png")),
      ImageIcon(AssetImage("assets/icons/Net Payments Filled.png")),
      'Net Pays'
    ],
    [
      ImageIcon(AssetImage("assets/icons/Net Prices Outlined.png")),
      ImageIcon(AssetImage("assets/icons/Net Prices Filled.png")),
      'Net Plans'
    ],
    [
      ImageIcon(AssetImage("assets/icons/Cable Payments Outlined.png")),
      ImageIcon(AssetImage("assets/icons/Cable Payments Filled.png")),
      'Cable Pays',
    ],
    [
      ImageIcon(AssetImage("assets/icons/Coupons Outlined.png")),
      ImageIcon(AssetImage("assets/icons/Coupons Filled.png")),
      'Coupons'
    ],
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int activeUsers = 0, onlineUsers = 0;

  getCount(setDState) async {
    ISPResponse ispResponse = await Utils.isp.getUsersCount();
    var resp = ispResponse.response["data"];
    if(ispResponse.success) {
      activeUsers = resp["res"]['active'];
      onlineUsers = resp["res"]['online'];
    }
    setDState(() {});
  }

  @override
  void initState() {
    _widgetOptions = <Widget>[
      getHomePage(),
      WillPopScope(onWillPop: () async {setState(() {_selectedIndex = 0;});return false;},child: UsersScreen()),
      WillPopScope(onWillPop: () async {setState(() {_selectedIndex = 0;});return false;},child: NetPayments()),
      WillPopScope(onWillPop: () async {setState(() {_selectedIndex = 0;});return false;},child: NetPlans()),
      WillPopScope(onWillPop: () async {setState(() {_selectedIndex = 0;});return false;},child: CablePayments()),
      WillPopScope(onWillPop: () async {setState(() {_selectedIndex = 0;});return false;},child: Coupons())
    ];
    super.initState();
    FirebaseMessaging.onMessage.listen((event) {
      var message = event.data;
      if (message['data']['type'] == 'cable_payment') {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CablePayments(
                id: message['data']['order_id'],
              ),
            ));
      }
      if (message['data']['type'] == 'net_payment') {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NetPayments(
                id: message['data']['order_id'],
              ),
            ));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      var message = event.data;
      if (message['data']['type'] == 'cable_payment') {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CablePayments(
                id: message['data']['order_id'],
              ),
            ));
      }
      if (message['data']['type'] == 'net_payment') {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NetPayments(
                id: message['data']['order_id'],
              ),
            ));
      }
    });
  }

  Widget getHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ));
              },
              child: Text(
                'Sign Out',
                style: TextStyle(color: Colors.blue),
              ))
        ],
      ),
      body: StatefulBuilder(
        builder: (context, setDState) {
          if(activeUsers==0){
            getCount(setDState);
          }
          return SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: InkWell(
                      onTap: () {
                        getCount(setDState);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Active : $activeUsers'),
                          Text('Online : $onlineUsers'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    margin:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              setDState(() {
                                Utils.changeISP("rvr");
                                getCount(setDState);
                              });
                            },
                            child: Text(
                              "RVR",
                              style: TextStyle(
                                  color:
                                  Utils.ispCode == "rvr" ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(8),
                                primary:Utils.ispCode != "rvr" ? Colors.black : Colors.white),
                          )),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                setDState(() {
                                  Utils.changeISP("ssc");
                                  getCount(setDState);
                                });
                              },
                              child: Text(
                                "SSC",
                                style: TextStyle(
                                    color:
                                    Utils.ispCode == "ssc" ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(8),
                                  primary:Utils.ispCode != "ssc" ? Colors.black : Colors.white),
                            )),
                      ],
                    ),
                  ),
                ] +
                    List.generate(_widgetDetails.length - 1, (i) {
                      i += 1;
                      return InkWell(
                        onTap: () {
                          _onItemTapped(i);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            '${_widgetDetails[i][2]}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      );
                    })),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedFontSize: 12,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.shifting,
          onTap: _onItemTapped,
          items: List.generate(
            _widgetOptions.length,
            (i) => BottomNavigationBarItem(
              backgroundColor: Colors.black,
              icon: _widgetDetails[i][0],
              activeIcon: _widgetDetails[i][1],
              label: _widgetDetails[i][2],
            ),
          ),
        ),
      ),
    );
  }
}
