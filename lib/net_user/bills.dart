import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:sumanth_net_admin/isp/jaze_isp.dart';
import 'package:sumanth_net_admin/net_pay.dart';
import './net_user.dart';
import 'package:sumanth_net_admin/pdf_generation.dart';
import '../utils.dart';

class UserBills extends StatefulWidget {
  final user;

  const UserBills({Key key, this.user}) : super(key: key);

  @override
  _UserBillsState createState() => _UserBillsState();
}

class _UserBillsState extends State<UserBills> {
  bool gotBills = false;
  List bills = [], fireStoreBills = [];
  http.Response resp;

  TextStyle messageStyle = TextStyle(color: Colors.black);
  TextStyle macStyle = TextStyle(color: Colors.blue);

  List<Plan> plans = Utils.isp.plans_.list;
  BoxDecoration contDec = BoxDecoration(
      border: Border(top: BorderSide(color: Colors.black)),
      color: Colors.white);
  EdgeInsets contPad = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  var contMarg = const EdgeInsets.symmetric(vertical: 2);
  String ic = '0',
      total = '0',
      gstc = '0',name='';
  pw.Document pdf;
  Plan selectedPlan;
  TextStyle
  buttonTextStyle = new TextStyle(color: Colors.blue), successPriceStyle = TextStyle(color: Colors.green,fontSize: 18,fontWeight: FontWeight.bold), failurePriceStyle = TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold), pendingPriceStyle = TextStyle(color: Colors.amber,fontSize: 18,fontWeight: FontWeight.bold);

  TextStyle buttonTextStyle2 = TextStyle(
    color: Colors.white,
    fontSize: 12,
  );

  String date = "";

  @override
  void initState() {
    super.initState();
    name = widget.user['name'];
    WidgetsBinding.instance.addPostFrameCallback((_) {getBills();});
  }

  getBills() async {
    Utils.showLoadingDialog(context, "Getting Bills");
    setState(() {
      gotBills = false;
    });
    ISPResponse ispResponse = await Utils.isp.getBills(widget.user["uid"]);
    var resp = ispResponse.response["data"];
    if(ispResponse.success) {
      bills = resp;
      await FirebaseFirestore.instance
          .collection(Utils.isp.billsCollection).where("uid",isEqualTo: widget.user["uid"])
          .get()
          .then((pays) async {
        fireStoreBills = [];
        for (int i = 0; i < pays.docs.length; i++) {
          var npt = pays.docs[i].data();
          fireStoreBills.add(npt);
        };}).catchError((e) {
          print("ERROR: $e");
      });

      fireStoreBills.sort((a, b) {
        String av = a['bill_id'], bv = b['bill_id'];
        if (bv == null || bv == "") {
          bv = "9999999999";
          b['bill_id'] = "-";
        }
        if (av == null || av == "") {
          av = "9999999999";
          a['bill_id'] = "-";
        }
        return bv.compareTo(av);
      });

      setState(() {
        gotBills = true;
      });
    } else {
      setState(() {
        gotBills = false;
      });
      await Utils.showErrorDialog(context, "Error", "${ispResponse.message}");
    }
    Navigator.pop(context);
  }

  copy(context, text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'User Bills',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () async {
                  getBills();
                },
                child: Text(
                  'Reload',
                  style: TextStyle(color: Colors.blue),
                ))
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          bottom: TabBar(tabs: [Tab(child: Text("Renews", style: TextStyle(color: Colors.black),),),Tab(child: Text("Bills", style: TextStyle(color: Colors.black),),),]),
        ),
        body: TabBarView(children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('${widget.user['user_id']} - ${widget.user['name']}'),
                Text('${widget.user['email']} - ${widget.user['mobile']}'),
                Text('${widget.user['address']}'),
              ] +
                  List<Widget>.generate(bills.length, (index) {
                    return Container(
                      padding: contPad,
                      decoration: contDec,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        onTap: () async {
                          copy(context, "${bills[index]['FranchiseStatement']['reference_id']}");
                        },
                        title: Text(
                          '${bills[index]['FranchiseStatement']['reference_id']}'
                        ),
                        subtitle: Text("${bills[index]['FranchiseStatement']['date_created'].split(" ")[0]}"),
                        trailing: IconButton(onPressed: ()async {
                          selectedPlan = plans.first;
                          await assignPayment(bills[index]['FranchiseStatement']);
                        }, icon: Icon(Icons.request_page_outlined, size: 24, color: Colors.blue,)),
                      )
                    );
                  }),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('${widget.user['user_id']} - ${widget.user['name']}'),
                Text('${widget.user['email']} - ${widget.user['mobile']}'),
                Text('${widget.user['address']}'),
              ] +
                  List<Widget>.generate(fireStoreBills.length, (j) {

                    NetPay pay = NetPay.fromJson(fireStoreBills[j]);
                    return NetPayTile(user: widget.user,pay: pay,);
                    /*return InkWell(
                      splashColor: Colors.black,
                      onTap: (){
                        if(pay['s']!='failed')
                          showReceipt(context, pay, widget.user);
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
                                  FittedBox(child: Text("${pay['p']}", style: const TextStyle(color: Colors.black,fontSize: 16))),
                                  FittedBox(child: Text(pay['s'] == 'success'?"Renewal ${pay['rs']==0?"Pending":pay['rs']==1?"Success":"Failed"}":"Transaction Not Successful", style: TextStyle(color: (pay['rs']==0?Colors.amber:pay['rs']==1?Colors.green:Colors.red),fontSize: 12))),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  FittedBox(child: Text("${pay['d']}", style: const TextStyle(color: Colors.grey,fontSize: 10),)),
                                  Text(
                                    "\u20b9 ${pay['a']}",
                                    style:  pay['s'] == 'success'
                                        ? successPriceStyle
                                        : pay['s'] == 'failed'? failurePriceStyle:pendingPriceStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );*/
                  }),
            ),
          ),
        ]),
      ),
    );
  }

  assignPayment(p) async {
    List<Map<String, dynamic>> amounts = [
      {
        "key": "internet",
        "title": "Internet",
        "check": true,
        "controller": new TextEditingController(text: '${selectedPlan.price}'),
      },
      {
        "key": "ip",
        "title": "Public IP",
        "check": false,
        "controller": new TextEditingController(text: '0'),
      },
      {
        "key": "installation",
        "title": "Installation",
        "check": false,
        "controller": new TextEditingController(text: '0'),
      },
      {
        "key": "router",
        "title": "Router",
        "check": false,
        "controller": new TextEditingController(text: '0'),
      },
      {
        "key": "other",
        "title": "Others",
        "check": false,
        "controller": new TextEditingController(text: '0'),
      },
    ];
    selectedPlan = plans[0];
    Map user = widget.user;
    List<String> d = p['date_created'].substring(0, 10).toString().split("-");

    TextEditingController notesC = TextEditingController();
    print(d);
    DateTime billDate = DateTime(int.parse(d[2]), int.parse(d[1]), int.parse(d[0]));
    DateTime expiryDate = billDate.add(Duration(days: (30*(selectedPlan.months))));
    TextEditingController dateC = new TextEditingController(text: "${Utils.formatDate(billDate)}");
    TextEditingController expiryC = new TextEditingController(text: "${Utils.formatDate(expiryDate)}");

    var u = {
      'total': selectedPlan.price, // total amount
      'id': Utils.generateId("${Utils.isp.billsCollection}_"),
      'bill_id': p['reference_id'],
      'coupon': "",
      "date": "${Utils.formatDate(billDate)}", // date
      "expiry": "${Utils.formatDate(expiryDate)}", // date
      "bill": {
        'internet': selectedPlan.price, // internet charges,
        'gst': 0, // gst,
        'ip': 0, // static price,
        "installation": 0,
        "router": 0,
        "other": 0,
        'saved': (selectedPlan.mrp) - (selectedPlan.price), // saved
      },
      "notes": "",
      'plan': selectedPlan.name, // plan
      'pay_resp': "{PAYMENTMODE: Direct, GATEWAYNAME: UPI, STATUS: Success, RESPMSG: ,}", // response
      "renewal": {
        'status': 1, // renewal status
        'error': "", // renewal error
      },
      'status': "success", // payment status
      'uid': user["uid"], // uid
      'userid': user["user_id"], // user id
    };

    List<dynamic> paymentOptions = ["UPI", "Cash", "Card"];
    int selected = 0;
    GlobalKey<FormState> formKey = new GlobalKey<FormState>();

    bool gst = false;

    var calculate = () async {
      u["bill"]["gst"] = 0;
      u["total"] = 0;
      amounts.forEach((amnt) {
        if(amnt["check"]) {
          u["bill"][amnt["key"]] = int.parse(amnt["controller"].text);
          u["total"] += u["bill"][amnt["key"]];
        } else {
          u["bill"][amnt["key"]] = 0;
        }
      });
      if(gst){
        u["bill"]["gst"] = (u["bill"]["internet"] * 0.18).toInt();
        u["total"] += u["bill"]["gst"];
      }
      u["bill"]["saved"] = (selectedPlan.mrp - u["bill"]["internet"]);
      u["pay_resp"] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";
    };

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              actionsPadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              titlePadding: const EdgeInsets.all(8),
              buttonPadding: const EdgeInsets.all(2),
              title: Text('Bill Details'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8,8,8,0),
                        child: Align(alignment: Alignment.centerLeft, child: Text("Plan")),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        padding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black)),
                        child: DropdownButton<Plan>(
                            isExpanded: true,
                            items: List.generate(
                                plans.length,
                                    (index) => DropdownMenuItem<Plan>(
                                  child: Text('${plans[index].title}'),
                                  value: plans[index],
                                )),
                            value: selectedPlan,
                            onChanged: (Plan v) {
                              setDState(() {
                                selectedPlan = v;
                                u['plan'] = selectedPlan.name;
                                amounts[0]["controller"].text = "${selectedPlan.price}";
                                expiryDate = billDate.add(Duration(days: (30*(selectedPlan.months))));
                                u["expiry"] = expiryC.text = "${Utils.formatDate(expiryDate)}";
                                setDState((){calculate();});
                              });
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Flexible(
                                child: InkWell(
                                  onTap: () async {
                                    billDate = await showDatePicker(context: context, initialDate: billDate, firstDate: billDate.subtract(Duration(days: 365)), lastDate: billDate.add(Duration(days: 365)))??billDate;
                                    u["date"] = dateC.text = "${Utils.formatDate(billDate)}";
                                    expiryDate = billDate.add(Duration(days: (30*(selectedPlan.months))));
                                    u["expiry"] = expiryC.text = "${Utils.formatDate(expiryDate)}";
                                    setDState((){});
                                  },
                                  child: TextField(
                              controller: dateC,
                              maxLines: 1,
                              decoration: InputDecoration(
                                  labelText: "Bill Date",
                                  enabled: false
                              ),
                            ),
                                )),
                            SizedBox(width: 16,),
                            Flexible(
                                child: TextField(
                              controller: expiryC,
                              maxLines: 1,
                              decoration: InputDecoration(
                                labelText: "Expiry Date",
                                enabled: false
                              ),
                            )),
                          ],
                        ),
                      )
                    ] +
                        List.generate(amounts.length, (i) {
                          return Container(
                            color: i%2==0?Colors.transparent:Colors.black12,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Checkbox(value: amounts[i]["check"], onChanged: (v) {
                                  setDState(() {
                                    amounts[i]["check"] = v;
                                    calculate();
                                  });
                                }),
                                Flexible(
                                  flex: 2,
                                  child: Align(alignment: Alignment.centerLeft, child: Text("${amounts[i]["title"]}")),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: amounts[i]["controller"],
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(prefixText: "Rs. ", contentPadding: EdgeInsets.zero),
                                    onFieldSubmitted: (v){setDState((){calculate();});},
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                        + [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: notesC,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              maxLines: null,
                              onChanged: (v) {
                                u["notes"] = v;
                              },
                              decoration: InputDecoration(labelText: "Notes", contentPadding: EdgeInsets.zero),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 0, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(onTap: (){if(selected==0){selected = paymentOptions.length;}selected-=1;u["pay_resp"] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";setDState((){});}, child: Icon(CupertinoIcons.left_chevron)),
                                      Text(paymentOptions[selected]),
                                      InkWell(onTap: (){if(selected==paymentOptions.length-1){selected = -1;}selected+=1;u["pay_resp"] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";setDState((){});}, child: Icon(CupertinoIcons.right_chevron)),
                                    ]
                                ),
                                InkWell(
                                  onTap: () {
                                    setDState((){gst = !gst;  calculate();});
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Checkbox(value: gst, onChanged: (bool value) {setDState((){gst = value; calculate();});}),
                                      Text("GST")
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Total: Rs.${u["total"]}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),textAlign: TextAlign.center,),
                          Text('${u["bill"]["internet"]} (Plan)${gst
                              ? ' + ${u["bill"]["gst"]} (with GST)'
                              : ''}', style: TextStyle(fontSize: 12,),textAlign: TextAlign.center,),
                        ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text("Ok"),
                  onPressed: () async {
                    if (formKey.currentState.validate()) {
                      calculate();
                      Utils.showLoadingDialog(context, "Assigning");

                      await FirebaseFirestore.instance
                          .collection('${Utils.isp.billsCollection}')
                          .doc(u["bill_id"])
                          .set(u).catchError((e)async{await Utils.showErrorDialog(context, "Error", "$e");});

                      Navigator.pop(context);
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

}
