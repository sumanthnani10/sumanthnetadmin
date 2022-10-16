import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sumanth_net_admin/pdf_generation.dart';
import 'package:sumanth_net_admin/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'isp/jaze_isp.dart';

class NetPay {

  String
      billID,
      coupon,
      date,
      expiry,
      orderID,
      plan,
      userID,
      notes,
      payResponse,
      status,
      renewalError,
      uid;
  int total,
      internetCharges,
      installationCharges,
      ipCharges,
      otherCharges,
      routerCharges,
      savedCharges,
      renewalStatus,
      gstCharges;

  NetPay({
    @required this.billID,
    @required this.coupon,
    @required this.date,
    @required this.expiry,
    @required this.orderID,
    @required this.plan,
    @required this.userID,
    @required this.notes,
    @required this.payResponse,
    @required this.status,
    @required this.uid,
    @required this.total,
    @required this.internetCharges,
    @required this.installationCharges,
    @required this.ipCharges,
    @required this.otherCharges,
    @required this.routerCharges,
    @required this.savedCharges,
    @required this.gstCharges,
    @required this.renewalError,
    @required this.renewalStatus,
  });

  factory NetPay.fromJson(Map<dynamic, dynamic> i) {
    i["bill"] = i["bill"] ?? {
      'internet': 0,
      'gst': 0,
      'ip': 0,
      "installation": 0,
      "router": 0,
      "other": 0,
      'saved': 0,
    };
    i["renewal"] = i["renewal"]??{
      'status': 0, // renewal status
      'error': "Not found in firebase.", // renewal error
    };
    /*List<String> d = i["date"].split("-");
    if(i["date"].contains("/")) {
      d = i["date"].split("/");
    }
    DateTime date = DateTime(int.parse(d[2]), int.parse(d[1]), int.parse(d[0]));
    if(i["expiry"] == null) {
      date = date.add(Duration(days: 30));
      i["expiry"] = Utils.formatDate(date);
    }
    i["date"] = Utils.formatDate(date);*/
    return NetPay(
        billID: i["bill_id"]??"",
        coupon: i["coupon"]??"",
        date: i["date"]??"",
        expiry: i["expiry"]??"",
        orderID: i["id"]??"",
        plan: i["plan"]??"",
        userID: i["userid"]??"",
        notes: i["notes"]??"",
        payResponse: i["pay_resp"]??"",
        status: i["status"]??"",
        uid: i["uid"]??"",
        total: i["total"]??0,
        internetCharges: i["bill"]["internet"]?? 0, // internet charges,
        installationCharges: i["bill"]["installation"]?? 0, // gst,
        ipCharges: i["bill"]["ip"]?? 0, // static price,
        otherCharges: i["bill"]["other"]?? 0,
        routerCharges: i["bill"]["router"]?? 0,
        savedCharges: i["bill"]["saved"]?? 0,
        gstCharges: i["bill"]["gst"]?? 0,
        renewalError: i["renewal"]["error"],
        renewalStatus: i["renewal"]["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "bill_id": billID,
      "coupon": coupon,
      "date": date,
      "expiry": expiry,
      "id": orderID,
      "plan": plan,
      "userid": userID,
      "notes": notes,
      "pay_resp": payResponse,
      "status": status,
      "uid": uid,
      "total": total,
      "bill": {
        'internet': internetCharges,
        'gst': gstCharges,
        'ip': ipCharges,
        "installation": installationCharges,
        "router": routerCharges,
        "other": otherCharges,
        'saved': savedCharges,
      },
      "renewal": {
        'status': renewalStatus, // renewal status
        'error': renewalError, // renewal error
      },
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

  Plan plan;

  @override
  void initState() {
    plan = Utils.isp.plans[pay.plan];
    super.initState();
  }

  callUser(mobile) async {
    if (await canLaunch('tel:${mobile}')) {
      await launch('tel:${mobile}');
    } else {
      throw 'Could not launch tel:${mobile}';
    }
  }

  showReceipt(context, NetPay pay, Map user) async {

    List amounts = [
      {
        "key": "internet",
        "title": "Internet",
      },
      {
        "key": "ip",
        "title": "Public IP",
      },
      {
        "key": "installation",
        "title": "Installation",
      },
      {
        "key": "router",
        "title": "Router",
      },
      {
        "key": "other",
        "title": "Others",
      },
    ];
    var rem = <Widget>[];
    double h8 = 8;
    if (pay.status != 'failed') {
      var s = pay.payResponse.toString();
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
    Map bill = pay.toJson();
    
    await showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Receipt'),
              TextButton.icon(
                onPressed: () async {
                  if (pay.billID != null && pay.billID != "") {
                    Utils.showLoadingDialog(context, "Generating Bill");
                    await PdfGeneration.generateBill(user, pay.toJson());
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
            InkWell(
                onTap: () {
                  copy(context, '${pay.userID.toUpperCase()}');
                },
                child: Text('${pay.userID.toUpperCase()}',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600))),
            SizedBox(
              height: h8,
            ),]+List.generate(amounts.length, (i) {
            var amount = amounts[i];
            if(bill["bill"][amount["key"]] == null || bill["bill"][amount["key"]] == 0){
              return Container();
            }
            return Container(
              padding: const EdgeInsets.all(4),
              color: Colors.grey.shade200,
              child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('${amount["title"]} ${(amount["key"]==amounts[0]["key"] && pay.gstCharges!=0)?"(Incl. 18% GST)":""}',
                        style: TextStyle(fontSize: 14)),
                    Text('Rs.${bill["bill"][amount["key"]]+(amount["key"]==amounts[0]["key"]?bill["bill"]["gst"]:0)}.00',
                        style: TextStyle(fontSize: 14)),
                  ]),
            );
          })+[
            Align(
              alignment: Alignment.centerRight,
              child: Text('Total: Rs.${bill["total"]}\n',
                style: TextStyle(
                    fontWeight: FontWeight.bold)),
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
                          "id": pay.orderID,
                          "renewal": {
                            "status": 1,
                            "error": "Manual Renewal."
                          }
                            });
                        await FirebaseFirestore.instance
                            .collection("${Utils.isp.billsCollection}")
                            .doc("${tpay["bill_id"]}")
                            .set(tpay);
                        await FirebaseFirestore.instance
                            .collection("${Utils.isp.billsCollection}")
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
                          "status": "failed",
                          "id": pay.orderID,
                          "renewal": {
                            "status": -1,
                            "error": "Manual Update"
                          }
                        });
                        await FirebaseFirestore.instance
                            .collection("${Utils.isp.billsCollection}")
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
                            "status": "success",
                            "id": pay.orderID,
                            "renewal": {
                              "status": 1,
                              "error": "Manual Update."
                            }
                          });
                          await FirebaseFirestore.instance
                              .collection("${Utils.isp.billsCollection}")
                              .doc("${tpay["bill_id"]}")
                              .set(tpay);
                          await FirebaseFirestore.instance
                              .collection("${Utils.isp.billsCollection}")
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
            SizedBox(height: h8,),
            InkWell(
                onTap: () {
                  copy(context, '${pay.orderID ?? "-"}');
                },
                child: Text('Order Id: ${pay.orderID ?? "-"}')),
            SizedBox(height: h8,),
            InkWell(
                onTap: () {
                  copy(context, '${pay.notes ?? "-"}');
                },
                child: Text('Notes: ${pay.notes ?? "-"}')),
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
                  FittedBox(child: Text("${plan.title}", style: const TextStyle(color: Colors.black,fontSize: 16))),
                  FittedBox(child: Text("${widget.user["user_id"]}", style: TextStyle(color: Colors.black,fontSize: 10))),
                  FittedBox(child: Text("${widget.pay.status == 'success'?"Renewal ${widget.pay.renewalStatus==0?"Pending":(widget.pay.renewalStatus==1)?"Success":"Failed"}":"Transaction Not Successful"}", style: TextStyle(color: (widget.pay.renewalStatus==0?Colors.amber:widget.pay.renewalStatus==1?Colors.green:Colors.red),fontSize: 12))),
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
                    "\u20b9 ${widget.pay.total}",
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
