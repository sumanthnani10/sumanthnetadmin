import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sumanth_net_admin/pdf_generation.dart';
import 'package:sumanth_net_admin/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'net_user.dart';

class NetPay {
  String billID,
      coupon,
      date,
      orderID,
      plan,
      response,
      renewalStatusError,
      status,
      userID,
      uid;
  int amount, gst, internetCharges, renewalStatus, saved, staticPrice;

  NetPay({
    @required this.amount,
    @required this.billID,
    @required this.coupon,
    @required this.date,
    @required this.gst,
    @required this.orderID,
    @required this.internetCharges,
    @required this.plan,
    @required this.response,
    @required this.renewalStatus,
    @required this.renewalStatusError,
    @required this.status,
    @required this.saved,
    @required this.staticPrice,
    @required this.userID,
    @required this.uid,
  });

  factory NetPay.fromJson(Map<dynamic, dynamic> i) {
    return NetPay(
        amount: i["a"]??0,
        billID: i["bill_id"]??"",
        coupon: i["c"]??"",
        date: i["d"]??"",
        gst: i["gst"]??0,
        orderID: i["i"]??"",
        internetCharges: i["i_c"]??0,
        plan: i["p"]??"",
        response: i["r"]??"",
        renewalStatus: i["rs"]??0,
        renewalStatusError: "${i["rse"]}"??"",
        status: i["s"]??"",
        saved: i["sa"]??0,
        staticPrice: i["stc"]??0,
        userID: i["u_id"]??"",
        uid: i["uid"]??"",
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "a": amount,
      "bill_id": billID,
      "c": coupon,
      "d": date,
      "gst": gst,
      "i": orderID,
      "i_c": internetCharges,
      "p": plan,
      "r": response,
      "rs": renewalStatus,
      "rse": renewalStatusError,
      "s": status,
      "sa": saved,
      "stc": staticPrice,
      "u_id": userID,
      "uid": uid,
    };
  }
}

class NetPayTile extends StatefulWidget {
  
  final Map user;
  final NetPay pay;


  const NetPayTile({Key key, this.user, this.pay}) : super(key: key);

  @override
  State<NetPayTile> createState() => _NetPayTileState(this.user, this.pay);
}

class _NetPayTileState extends State<NetPayTile> {
  BoxDecoration contDec = BoxDecoration(
      border: Border(top: BorderSide(color: Colors.black)),
      color: Colors.white);



  TextStyle buttonTextStyle = new TextStyle(color: Colors.blue),
      successPriceStyle = TextStyle(
          color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
      failurePriceStyle = TextStyle(
          color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
      pendingPriceStyle = TextStyle(
          color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
      buttonTextStyle2 = TextStyle(
    color: Colors.white,
    fontSize: 12,
  );

  copy(context, text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  final Map user;
  final NetPay pay;
  
  _NetPayTileState(this.user, this.pay);

  callUser(mobile) async {
    if (await canLaunch('tel:${mobile}')) {
      await launch('tel:${mobile}');
    } else {
      throw 'Could not launch tel:${mobile}';
    }
  }

  showReceipt(context, NetPay pay, Map user) async {
    var rem = <Widget>[];
    double h8 = 8;
    if (pay.status != 'failed') {
      var s = pay.response.toString();
      s = s.replaceAll(': ', '": "');
      s = s.replaceAll(', ', '", "');
      s = s.replaceAll('{', '{"');
      s = s.replaceAll('}', '"}');
      var r;
      r = jsonDecode(s);
      rem = <Widget>[
        SizedBox(
          height: h8,
        ),
        Text('Date: ${pay.date}'),
        SizedBox(
          height: h8,
        ),
        InkWell(
            onTap: () {
              copy(context, '${r['TXNID']??"-"}');
            },
            child: Text('Transaction Id: ${r['TXNID']??"-"}')),
        SizedBox(
          height: h8,
        ),
        InkWell(
            onTap: () {
              copy(context, '${r['BANKTXNID']??"-"}');
            },
            child: Text('Bank Transaction Id: ${r['BANKTXNID']??"-"}')),
        SizedBox(
          height: h8,
        ),
        Text('Payment Mode: ${r['PAYMENTMODE']} - ${r['GATEWAYNAME']}'),
        SizedBox(
          height: h8,
        ),
        InkWell(
            onTap: () {
              copy(context, '${r['STATUS']} - ${r['RESPMSG']}');
            },
            child: Text('Status: ${r['STATUS']} - ${r['RESPMSG']}')),

        SizedBox(
          height: h8,
        ),
        InkWell(
            onTap: () {
              copy(context, '${r['CHECKSUMHASH']}');
            },
            child: Text(
              'CSH: ${r['CHECKSUMHASH']}',
              style: TextStyle(fontSize: 6),
            )),
      ];
    }
    
    await showDialog(
      context: context,
      builder: (contex) {
        return SimpleDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Receipt'),
              TextButton.icon(
                onPressed: () async {
                  Map<String, dynamic> netUser = user.cast();
                  netUser.addAll(Utils.netUsers[user['uid']]);
                  NetUser nUser = NetUser.fromJson(netUser);
                  if (pay.billID != null && pay.billID != "") {
                    Utils.showLoadingDialog(context, "Generating Bill");
                    await PdfGeneration.generateBill(
                        pay.gst != 0,
                        nUser.userId,
                        nUser.name,
                        nUser.address,
                        nUser.mobile,
                        nUser.email,
                        pay.plan,
                        pay.billID,
                        pay.date,
                        "${pay.internetCharges}",
                        "${pay.gst}",
                        "${pay.amount}");
                    Navigator.pop(context);
                  }
                },
                label: Text("Share Bill"),
                icon: Icon(Icons.share),
              )
            ],
          ),
          contentPadding: const EdgeInsets.all(8),
          titlePadding: const EdgeInsets.symmetric(horizontal: 8),
          children: <Widget>[
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Rs. ${pay.amount}   ',
                  style:
                  TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                )),
            InkWell(
                onTap: () {
                  copy(context, '${pay.userID.toUpperCase()}');
                },
                child: Text('${pay.userID.toUpperCase()}',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600))),
            SizedBox(
              height: h8,
            ),
            InkWell(
                onTap: () {
                  callUser('${user['mobile']}');
                },
                onLongPress: () {
                  copy(context, '${pay.userID}');
                },
                child: Text(
                  '${user['mobile']}',
                  style: buttonTextStyle,
                )),
            SizedBox(
              height: h8,
            ),
            InkWell(
                onTap: () {
                  copy(context, '${pay.orderID ?? "-"}');
                },
                child: Text('Order Id: ${pay.orderID ?? "-"}')),
            SizedBox(
              height: h8,
            ),
            if (pay.status == "success")
              InkWell(
                  onTap: () async {
                    if (pay.billID == null ||
                        pay.billID == "" ||
                        pay.billID == "-" ||
                        pay.billID == "9999999999") {
                      var r = await askBillID() ?? [false];
                      if (r[0]) {
                        Utils.showLoadingDialog(context, "Loading");
                        Map<String, dynamic> tpay = pay.toJson();
                        tpay.addAll({
                          "bill_id": r[1],
                          "rs": 1,
                          "i": pay.orderID,
                          "rse": "Manual Renewal."
                        });
                        await FirebaseFirestore.instance
                            .collection("npay")
                            .doc("${tpay["bill_id"]}")
                            .set(tpay);
                        await FirebaseFirestore.instance
                            .collection("npay")
                            .doc("${pay.orderID}")
                            .delete();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    } else {
                      copy(context, '${pay.billID}');
                    }
                  },
                  child: Text('Bill Id: ${pay.billID ?? "-"}')),
            if (pay.status == "pending")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      onPressed: () async {
                        Utils.showLoadingDialog(context, "Loading");
                        Map<String, dynamic> tpay = pay.toJson();
                        tpay.addAll({
                          "bill_id": "",
                          "rs": -1,
                          "s": "failed",
                          "i": pay.orderID,
                          "rse": "Manual Update."
                        });
                        print("${pay.orderID}");
                        await FirebaseFirestore.instance
                            .collection("npay")
                            .doc("${pay.orderID}")
                            .update(tpay);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Failed',
                        style: buttonTextStyle2,
                      ),
                    ),
                  ),
                  SizedBox(width: 16,),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      onPressed: () async {
                        var r = await askBillID() ?? [false];
                        if (r[0]) {
                          Utils.showLoadingDialog(context, "Loading");
                          Map<String, dynamic> tpay = pay.toJson();
                          tpay.addAll({
                            "bill_id": r[1],
                            "rs": 1,
                            "i": pay.orderID,
                            "s": "success",
                            "rse": "Manual Renewal."
                          });
                          await FirebaseFirestore.instance
                              .collection("npay")
                              .doc("${tpay["bill_id"]}")
                              .set(tpay);
                          await FirebaseFirestore.instance
                              .collection("npay")
                              .doc("${pay.orderID}")
                              .delete();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Success',
                        style: buttonTextStyle2,
                      ),
                    ),
                  ),
                ],
              ),
          ] +
              rem,
        );
      },
    );
    return;
  }

  askBillID() async {
    TextEditingController billIdFieldController =
    new TextEditingController(text: '');
    GlobalKey<FormState> formKey = new GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDState) => AlertDialog(
            title: Text('Bill Id'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: billIdFieldController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v.length == 0) {
                    return "Enter Bill ID";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(labelText: "BILL ID"),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop([false]);
                },
              ),
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  if (formKey.currentState.validate()) {
                    Navigator.of(context)
                        .pop([true, billIdFieldController.text]);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.black,
      onTap: (){
        if(widget.pay.status!='failed')
          showReceipt(context, widget.pay, widget.user);
      },
      child: Container(
        decoration: contDec,
        padding:
        const EdgeInsets.fromLTRB(8,8,8,8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(child: Text("${widget.pay.plan}", style: const TextStyle(color: Colors.black,fontSize: 16))),
                  FittedBox(child: Text(widget.pay.status == 'success'?"Renewal ${widget.pay.renewalStatus==0?"Pending":(widget.pay.renewalStatus==1)?"Success":"Failed"}":"Transaction Not Successful", style: TextStyle(color: (widget.pay.renewalStatus==0?Colors.amber:widget.pay.renewalStatus==1?Colors.green:Colors.red),fontSize: 12))),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(child: Text("${widget.pay.date}", style: const TextStyle(color: Colors.grey,fontSize: 10),)),
                  Text(
                    "\u20b9 ${widget.pay.amount}",
                    style:  widget.pay.status == 'success'
                        ? successPriceStyle
                        : widget.pay.status == 'failed'? failurePriceStyle:pendingPriceStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*

a: amount
bill_id: billID
c: coupon
d: date
gst: gst
i: orderID
i_c: internetCharges
p: plan
r: response
rs: renewalStatus
rse: renewalStatusError
s: status
sa: saved
stc: staticPrice
u_id: userID
uid: uid

*/
