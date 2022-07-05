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
import 'package:sumanth_net_admin/net_user.dart';
import 'package:sumanth_net_admin/pdf_generation.dart';
import 'utils.dart';

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

  BoxDecoration contDec = BoxDecoration(
      border: Border(top: BorderSide(color: Colors.black)),
      color: Colors.white);
  EdgeInsets contPad = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  var contMarg = const EdgeInsets.symmetric(vertical: 2);
  String ic = '0',
      total = '0',
      gstc = '0',name='';
  pw.Document pdf;
  String selected_plan;
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
    getBills();
  }

  getBills() async {
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
      Utils.showErrorDialog(context, "Error", "${ispResponse.message}");
    }
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              copy(context, "${bills[index]['FranchiseStatement']['reference_id']}");
                            },
                            child: Text(
                              '${bills[index]['FranchiseStatement']['reference_id']} (${bills[index]['FranchiseStatement']['date_created']})',
                              style: messageStyle,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                  onTap: ()async {
                                    selected_plan = "${Utils.isp.planNames.first}";
                                    List d = bills[index]['FranchiseStatement']['date_created'].substring(0, 10).toString().split("-");
                                    if (await askAmount(bills[index]['FranchiseStatement'], "${d[2]}-${d[1]}-${d[0]}")??false) {
                                      Map pay = bills[index]['FranchiseStatement'];
                                      Map netUser = widget.user.cast();
                                      NetUser nUser = NetUser.fromJson(netUser);
                                      Utils.showLoadingDialog(context, "Generating Bill");
                                      await PdfGeneration.generateBill(
                                          gstc!="0",
                                          nUser.userId,
                                          name,
                                          nUser.address,
                                          nUser.mobile,
                                          nUser.email,
                                          selected_plan,
                                          pay['reference_id'],
                                          '$date',
                                          "$ic",
                                          "$gstc",
                                          "$total");
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    'Generate Bill',
                                    style: macStyle,
                                  )),
                              InkWell(
                                  onTap: ()async {
                                    selected_plan = "${Utils.isp.planNames.first}";
                                    if (await assignPayment(bills[index]['FranchiseStatement'])??false) {
                                      Map pay = bills[index]['FranchiseStatement'];
                                      Map netUser = widget.user.cast();
                                      netUser.addAll(Utils.isp.netUsers[widget.user['uid']]);
                                      NetUser nUser = NetUser.fromJson(netUser);
                                      Utils.showLoadingDialog(context, "Assigning Payment");

                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    'Assign Payment',
                                    style: macStyle,
                                  )),
                            ],
                          )
                        ],
                      ),
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

  askAmount(p, dat) async {
    TextEditingController amountFieldController =
    new TextEditingController(text: '${Utils.isp.plans[selected_plan]['sr']??0}');
    TextEditingController nameFieldController =
    new TextEditingController(text: name);
    TextEditingController dateFieldController =
    new TextEditingController(text: dat);
    List<String> plans = Utils.isp.planNames;
    GlobalKey<FormState> formKey = new GlobalKey<FormState>();

    bool gst = false;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
            title: Text('Bill Details'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                      margin:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black)),
                      child: DropdownButton(
                          isExpanded: true,
                          items: List.generate(
                              plans.length,
                                  (index) => DropdownMenuItem(
                                child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))),child: Text('${plans[index]}',style: TextStyle(fontSize: 10),)),
                                value: plans[index],
                              )),
                          value: selected_plan,
                          onChanged: (v) {
                            setDState(() {
                              selected_plan = v;
                              amountFieldController.text = "${Utils.isp.plans[selected_plan]['sr']??0}";
                            });
                          }),
                    ),
                    TextFormField(
                      controller: nameFieldController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(labelText: "Name"),
                    ),
                    TextFormField(
                      controller: dateFieldController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: "Date"),
                      onFieldSubmitted: (v){setDState((){});},
                    ),
                    TextFormField(
                      controller: amountFieldController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Amount"),
                      onFieldSubmitted: (v){setDState((){});},
                    ),
                    InkWell(
                      onTap: () {
                        setDState((){gst = !gst;});
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(value: gst, onChanged: (bool value) {setDState((){gst = value;});}),
                          Text("GST")
                        ],
                      ),
                    ),
                    Text(
                        'Total: Rs.${gst
                            ? int.parse(amountFieldController.text) +
                            (0.18 * int.parse(amountFieldController.text))
                            : amountFieldController.text} ${gst
                            ? ' (with GST)'
                            : ''}'),
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
                onPressed: () {
                  if (formKey.currentState.validate()) {
                    date = dateFieldController.text;
                    ic = amountFieldController.text;
                    gstc = gst?(0.18 * int.parse(amountFieldController.text))
                        .toString().split('.').first:'0';
                    total = gst?(int.parse(amountFieldController.text) +
                        (0.18 * int.parse(amountFieldController.text)))
                        .toString().split('.').first:ic;
                    name = nameFieldController.text;
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

  assignPayment(p) async {
    Map user = widget.user;
    List d = p['date_created'].substring(0, 10).toString().split("-");
    String id = Utils.generateId("${Utils.isp.billsCollection}_");
    var u = {
      'a': Utils.isp.plans[selected_plan]['sr']??0, // total amount
      'bill_id': p['reference_id'], // bill id
      'c': "", // coupon used
      "d": "${d[2]}-${d[1]}-${d[0]}", // date
      'gst': 0, // gst
      'i_c': Utils.isp.plans[selected_plan]['sr']??0, // internet charges
      'p': selected_plan, // plan
      'r': "{PAYMENTMODE: Direct, GATEWAYNAME: Gpay, STATUS: Success, RESPMSG: ,}", // response
      'rs': 1, // renewal states
      'rse': "", // renewal error
      's': "success", // payment status
      'sa': Utils.isp.plans[selected_plan]['r']??0 - Utils.isp.plans[selected_plan]['sr']??0, // saved
      'stc': 0, // static price
      'uid': user["uid"], // uid
      'u_id': user["user_id"], // user id
    };

    List<dynamic> paymentOptions = ["Gpay","Phonepe","Paytm","Cash","Card"];
    int selected = 0;
    
    TextEditingController amountFieldController = new TextEditingController(text: '${Utils.isp.plans[selected_plan]['sr']??0}');
    TextEditingController dateFieldController = new TextEditingController(text: u['d']);
    List<String> plans = Utils.isp.planNames;
    GlobalKey<FormState> formKey = new GlobalKey<FormState>();

    bool gst = false;
    bool static = false;

    var calculate = () async {
      u['p'] = selected_plan;
      u['gst'] = 0;
      u['stc'] = (static?Utils.staticIPPrice:0)* Utils.isp.plans[selected_plan]['m']??1;
      u['i_c'] = int.parse(amountFieldController.text);
      if(gst){
        u["gst"] = (u['i_c'] * 0.18).toInt();
      }
      u['a'] = u['i_c'] + u['gst'] + u['stc'];
      u['sa'] = Utils.isp.plans[selected_plan]['r']??0 - u['i_c'];
      u['r'] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";
    };

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
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
                      Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                        margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black)),
                        child: DropdownButton(
                            isExpanded: true,
                            items: List.generate(
                                plans.length,
                                    (index) => DropdownMenuItem(
                                  child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))),child: Text('${plans[index]}',style: TextStyle(fontSize: 10),)),
                                  value: plans[index],
                                )),
                            value: selected_plan,
                            onChanged: (v) {
                              setDState(() {
                                selected_plan = v;
                                amountFieldController.text = "${Utils.isp.plans[selected_plan]['sr']??0}";
                                setDState((){calculate();});
                              });
                            }),
                      ),
                      TextFormField(
                        controller: dateFieldController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(labelText: "Date"),
                        onChanged: (v){
                          u['d'] = v;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(onPressed: (){if(selected>0){selected-=1;u['r'] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";setDState((){});}}, icon: Icon(CupertinoIcons.left_chevron), label: Text("")),
                            Text(paymentOptions[selected]),
                            TextButton.icon(onPressed: (){if(selected<paymentOptions.length-1){selected+=1;u['r'] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";setDState((){});}}, icon: Icon(CupertinoIcons.right_chevron), label: Text("")),
                          ]
                      ),
                      TextFormField(
                        controller: amountFieldController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Amount"),
                        onFieldSubmitted: (v){setDState((){calculate();});},
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
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
                          InkWell(
                            onTap: () {
                              setDState((){static = !static;  calculate();});
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(value: static, onChanged: (bool value) {setDState((){static = value; calculate();});}),
                                Text("Static IP")
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                          'Total: Rs.${u['a']} ${gst
                              ? ' (with GST)'
                              : ''}'),
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
