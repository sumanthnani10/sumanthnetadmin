import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'error_screen.dart';
import 'utils.dart';

class UserLogs extends StatefulWidget {

  final user;

  const UserLogs({Key key, this.user}) : super(key: key);

  @override
  _UserLogsState createState() => _UserLogsState();
}

class _UserLogsState extends State<UserLogs> {

  bool gotLogs = false;
  List logs = [];
  http.Response resp;

  TextStyle messageStyle = TextStyle(color: Colors.black,fontSize: 16);
  TextStyle macStyle = TextStyle(color: Colors.black);

  BoxDecoration contDec = BoxDecoration(border: Border(top: BorderSide(color: Colors.black)),color: Colors.white);
  EdgeInsets contPad = const EdgeInsets.symmetric(horizontal: 8,vertical: 4);
  var contMarg = const EdgeInsets.symmetric(vertical: 2);

  @override
  void initState() {
    super.initState();
    getLogs();
  }

  getLogs() async {
    setState(() {
      gotLogs = false;
    });
    await Utils.checkLogin();
    resp = await http.get
      (Utils.getUserLogsByUIDLink(widget.user['uid']), headers: Utils.headers,);
    gotLogs = true;
    // print(resp.bodyBytes);
    logs = jsonDecode(resp.body)['aaData'];
    setState(() {
    });
    /*if (jsonDecode(resp.body)['status'] == 'success') {
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorScreen(
              error: resp.body,
            ),
          ));
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'User Logs',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: gotLogs?
      SingleChildScrollView(
        child: Column(
          children: <Widget>[Text('${widget.user['user_id']}'),Text('${widget.user['name']}')]+
              List<Widget>.generate(logs.length, (index) {
                return Container(
                padding: contPad,
                // margin: contMarg,
                decoration: contDec,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('${logs[index]['message']}',style: messageStyle,),
                    Text('${logs[index]['created']}',style: macStyle,),
                    Text('${logs[index]['mac']} - ${logs[index]['mac_vendor']}',style: macStyle,),
                    if(logs[index]['password']!='-')
                    Text('${logs[index]['password']}',style: macStyle,),
                  ],
                ),
              );
              }),
        ),
      ):LinearProgressIndicator(),
    );
  }
}
