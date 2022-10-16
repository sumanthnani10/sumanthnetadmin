import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sumanth_net_admin/isp/jaze_isp.dart';
import '../utils.dart';

class Sessions extends StatefulWidget {

  final user;

  const Sessions({Key key, this.user}) : super(key: key);

  @override
  _SessionsState createState() => _SessionsState();
}

class _SessionsState extends State<Sessions> {

  bool gotSessions = false;
  List sessions = [];
  http.Response resp;

  TextStyle smallStyle = TextStyle(color: Colors.black,fontSize: 12);
  TextStyle macStyle = TextStyle(color: Colors.black);

  BoxDecoration contDec = BoxDecoration(border: Border(top: BorderSide(color: Colors.black)),color: Colors.white);
  EdgeInsets contPad = const EdgeInsets.symmetric(horizontal: 8,vertical: 4);
  var contMarg = const EdgeInsets.symmetric(vertical: 2);

  @override
  void initState() {
    super.initState();
    getSessions();
  }

  getSessions() async {
    setState(() {
      gotSessions = false;
    });
    ISPResponse ispResponse = await Utils.isp.getSessions(widget.user["uid"]);
    if(ispResponse.success) {
      sessions = ispResponse.response["data"];
    } else {
      Utils.showErrorDialog(context, "Error", "${ispResponse.message}");
    }
    setState(() {
      gotSessions = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'User Sessions',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(onPressed: (){getSessions();}, child: Text("Reload"))
          ],
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: gotSessions?
        SingleChildScrollView(
          child: Column(
            children: <Widget>[Text('${widget.user['user_id']}'),Text('${widget.user['name']}')]+
                List<Widget>.generate(sessions.length, (index) => Container(
                  padding: contPad,
                  // margin: contMarg,
                  decoration: contDec,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('${sessions[index]['mac']} - ${sessions[index]['mac_vendor']}',style: macStyle,),
                      Text('Downloaded : ${sessions[index]['download_bytes']} - Uploaded : ${sessions[index]['upload_bytes']}',style: macStyle,),
                      Text('Start : ${sessions[index]['start_time']} - End : ${sessions[index]['stop_time']}',style: smallStyle,),
                    ],
                  ),
                )),
          ),
        ):LinearProgressIndicator(),
      ),
    );
  }
}
