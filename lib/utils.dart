import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:sumanth_net_admin/isp/rvr.dart';
import 'package:sumanth_net_admin/isp/ssc.dart';

import 'isp/jaze_isp.dart';

class Utils {
  static List<Map> cablePayments = [];
  static List<dynamic> coupons = [];
  static int staticIPPrice = 300;
  static Map<String, int> usersCatCount = {
    'Active': 0,
    'Online': 0,
    'Not Online': 0,
    'Expired': 0,
    'All': 0,
  };

  static const Offset RTL = Offset(1, 0);
  static const Offset LTR = Offset(-1, 0);
  static const Offset UTD = Offset(0, -1);
  static const Offset DTU = Offset(0, 1);

  static JazeISP rvrIsp = RVRISP();
  static JazeISP sscIsp = SSCISP();
  static JazeISP isp;
  static String ispCode = "ssc";

  static changeISP(ispC) async {
    ispCode = ispC;
    if(ispCode == "rvr") {
      isp = rvrIsp;
    } else if(ispCode == "ssc") {
      isp = sscIsp;
    }
    if(isp.users.length == 0) {
      await isp.getUsers();
    } if(isp.plans.length == 0) {
      await isp.loadPlans();
    }
  }

  static String generateId(String pref) {
    var chars =
        'zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210';
    int charLength = chars.length;
    var t = DateTime.now();
    String id = pref;
    // id += chars[(t.year / 100).round()];
    id += chars[t.year % charLength];
    id += chars[t.month];
    id += chars[t.day];
    id += chars[t.hour];
    id += chars[t.minute];
    id += chars[t.second];
    id += chars[t.millisecond % charLength];
    id += chars[t.microsecond % charLength];
    return id;
  }

  static Route createRoute(dest, Offset dir) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) => dest,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = dir;
        var end = Offset.zero;
        var curve = Curves.fastOutSlowIn;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static String digitsFormat(int num, [int digits = 2]) {
    String s = "$num";
    if (s.length < digits) {
      s = List<String>.generate(digits - s.length, (_) => "0").join("") + s;
    }
    return s;
  }

  static String formatDate(DateTime dateTime, [bool time = false]) {
    String s =
        "${digitsFormat(dateTime.day)}/${digitsFormat(dateTime.month)}/${dateTime.year}";
    if (time) {
      s +=
      " ${digitsFormat(dateTime.hour > 12 ? (12 - dateTime.hour) : dateTime.hour > 12)}/${digitsFormat(dateTime.minute)}/${dateTime.second} ${dateTime.hour > 12 ? "PM" : "AM"}";
    }
    return s;
  }

  static String notif_token;

  static createAppUser(List<String> notIn) async {
    ISPResponse ispResponse;
    notIn.forEach((e) async {
      var u = isp.users.where((element) => element['uid'] == e).first;
      ispResponse = await isp.uploadUser(u);
      if(ispResponse.success)
      debugPrint("${ispResponse.message}");
    });
  }

  static Future<bool> showADialog(BuildContext context, String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showErrorDialog(BuildContext context,String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: Colors.red),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static showLoadingDialog(BuildContext context, String title) {
    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(8),
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 8,
                  ),
                  Text(title)
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
/*
  static Map<String,List<String>> plans = {
    'Basic Unlimited-8Mbps':['44418','13014','400','1','1'],
    'Netplus Unlimited_40Mbps_1Month':['9940','10537','500','1','1'],
    'Value Plus Unlimited_60Mbps_1Month':['10212','10553','550','1','1'],
    'Value Plus Unlimited_60Mbps_3months':['10484','10555','1650','3','1'],
    'Value Plus Unlimited_60Mbps_6Months':['10757','10556','3300','6','1'],
    'Gold Unlimited_80Mbps_1Month':['11030','10532','600','1','1'],
    'Gold Unlimited_80Mbps_3Months':['32597','10534','1800','3','1'],
    'Gold Unlimited_80Mbps_6Months':['12397','10533','3600','6','1'],
    'Platinum Unlimited_200Mbps_1month' : ['12945','10538','900','1','1'],
    'Platinum Unlimited_200Mbps_3Months' : ['13493','10540','2700','3','1'],
    'Platinum Unlimited_200Mbps_6Months' : ['13219','10541','5400','6','1'],
    'Platinum Unlimited-400 Mbps-1M' : ['47069','13177','1200','1','1'],
    'Platinum Unlimited_400Mbps-3M' : ['47581','13178','3600','3','1'],
    'Platinum Unlimited_400 Mbps-6M' : ['48093','13179','7200','6','1'],
    'Basic Unlimited-4Mbps':['44418','13014','400','1','0'],
    'Netplus Unlimited_20Mbps_1Month':['9940','10537','500','1','0'],
    'Value Plus Unlimited_30Mbps_1Month':['10212','10553','550','1','0'],
    'Value Plus Unlimited_30Mbps_3months':['10484','10555','1650','3','0'],
    'Value Plus Unlimited_30Mbps_6Months':['10757','10556','3300','6','0'],
    'Gold Unlimited_40Mbps_1Month':['11030','10532','600','1','0'],
    'Gold Unlimited_40Mbps_3Months':['32597','10534','1800','3','0'],
    'Gold Unlimited_40Mbps_6Months':['12397','10533','3600','6','0'],
    'Platinum Unlimited_100Mbps_1month' : ['12945','10538','900','1','0'],
    'Platinum Unlimited_100Mbps_3Months' : ['13493','10540','2700','3','0'],
    'Platinum Unlimited_100Mbps_6Months' : ['13219','10541','5400','6','0'],
    'Platinum Unlimited-200 Mbps-1M' : ['47069','13177','1200','1','0'],
    'Platinum Unlimited_200Mbps-3M' : ['47581','13178','3600','3','0'],
    'Platinum Unlimited_200 Mbps-6M' : ['48093','13179','7200','6','0'],
    'VoIP public Unlimited-5 Mbps':['35689','10557','0','1','1'],
    '75 Mbps_150GB 3M':['15472','10917','0','3','1'],
    '100 Mbps_200GB 3M':['15955','10918','0','3','1'],
    '150 Mbps_400GB 3M':['','10919','0','3','1']
  };*/