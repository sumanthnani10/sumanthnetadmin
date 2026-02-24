import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sumanth_net_admin/error_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils.dart';

class SendOtp extends StatefulWidget {
  final Map<String, dynamic> user;

  const SendOtp({Key key, this.user}) : super(key: key);

  @override
  _SendOtpState createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> {
  bool loading = false, sentOTP = false;
  http.Response resp;

  TextEditingController otpC = new TextEditingController();
  String otp = '';

  @override
  void initState() {
    super.initState();
    sendOTP();
  }

  sendOTP() async {/*
    setState(() {
      sentOTP = false;
    });
    await Utils.checkLogin();
    resp =
        await http.post(Utils.SEND_OTP, headers: Utils.headers, body: {
      "phone": "${widget.user['mobile']}",
      "accountId": "022825sumanthanetworks",
      "userId": "${widget.user['uid']}"
    });
    setState(() {
      sentOTP = true;
    });
    if (jsonDecode(resp.body)['status'] == 'success') {
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorScreen(
              text: resp.body,
                html: false
            ),
          ));
    }
  */}

  verifyOTP() async {
    /*if (!loading) {
      setState(() {
        loading = true;
      });
      await Utils.checkLogin();
      resp = await http.post(Utils.VERIFY_OTP,
          headers: Utils.headers,
          body: {
            "phone": "${widget.user['mobile']}",
            "accountId": "022825sumanthanetworks",
            "userId": "${widget.user['uid']}",
            "otp": "${otpC.text}"
          });
      setState(() {
        loading = false;
      });
      if (jsonDecode(resp.body)['status'] == 'success') {
        Navigator.pop(context);
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(
                text: resp.body,
                html: false,
              ),
            ));
      }
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Send Otp',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          actions: <Widget>[
            FlatButton(
                onPressed: () async {
                  verifyOTP();
                },
                child: Text(
                  'Verify',
                  style: TextStyle(color: Colors.blue),
                ))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: <Widget>[
              if(!sentOTP)
                LinearProgressIndicator(),
                SizedBox(height: 4,),
              if(!sentOTP)
                Text('Sending OTP....'),

              if(sentOTP)
                Text('OTP Sent. Enter OTP.'),
              if(sentOTP)
                TextButton(onPressed: (){sendOTP();}, child: Text('Resend OTP',style: TextStyle(color: Colors.blue),)),
              InkWell(
                onTap: (){
                  callUser(widget.user['mobile']);
                },
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Call: ${widget.user['mobile']}',
                        maxLines: 1,style: TextStyle(color: Colors.blue, fontSize: 16))),
              ),
              SizedBox(height: 8,),
              if(sentOTP)
                TextField(
                  controller: otpC,
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_){
                    FocusScope.of(context).unfocus();
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textCapitalization: TextCapitalization.none,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black)),
                      labelStyle: TextStyle(color: Colors.black),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      labelText: 'OTP',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black)),
                      fillColor: Colors.white),
                ),

            ],
          ),
        ),
      ),
    );
  }

  callUser(mobile) async {
    if (await canLaunch(
        'tel:${mobile}')) {
      await launch(
          'tel:${mobile}');
    } else {
      throw 'Could not launch tel:${mobile}';
    }
  }
}
