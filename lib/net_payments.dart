import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sumanth_net_admin/net_pay.dart';
import 'package:sumanth_net_admin/net_user.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pdf_generation.dart';
import 'utils.dart';

class NetPayments extends StatefulWidget {
  final String id;

  const NetPayments({Key key, this.id = ''}) : super(key: key);

  @override
  _NetPaymentsState createState() => _NetPaymentsState();
}

class _NetPaymentsState
    extends State<NetPayments> /* with AutomaticKeepAliveClientMixin*/ {
  // @override
  // bool get wantKeepAlive => true;

  bool gettingPayments = true;

  ScrollController scroll_controller = new ScrollController();

  int viewItems = 20;

  TextStyle sStyle = TextStyle(color: Colors.green[800]);
  TextStyle pStyle = TextStyle(color: Colors.amber[800]);
  TextStyle fStyle = TextStyle(color: Colors.red);

  BoxDecoration contDec = BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Colors.black, width: 0.4)));

  TextStyle buttonTextStyle = new TextStyle(color: Colors.blue),
      successPriceStyle = TextStyle(
          color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
      failurePriceStyle = TextStyle(
          color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
      pendingPriceStyle = TextStyle(
          color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold);

  TextStyle buttonTextStyle2 = TextStyle(
    color: Colors.white,
    fontSize: 12,
  );

  int selected = 1;

  List payms = [];

  @override
  void initState() {
    super.initState();
    getNetPayments();
  }

  setListener() {
    scroll_controller
      ..addListener(() {
        if (scroll_controller.offset >=
                scroll_controller.position.maxScrollExtent &&
            !scroll_controller.position.outOfRange) {
          viewItems += 20;
          setState(() {});
        } else if (scroll_controller.offset ==
            scroll_controller.position.minScrollExtent) {
          setState(() {
            viewItems = 20;
          });
        }
      });
  }

  @override
  void dispose() {
    scroll_controller.dispose();
    super.dispose();
  }

  getNetPayments() async {
    setState(() {
      gettingPayments = true;
    });
    await FirebaseFirestore.instance
        .collection('npay')
        .get()
        .then((pays) async {
      Utils.netPayments = [];
      for (int i = 0; i < pays.docs.length; i++) {
        var np = pays.docs[i];
        var npt = np.data();
        npt['i'] = np.id;
        /*if(np.id != (npt['bill_id']??np.id)){
          print("${npt['bill_id']} - ${np.id}");
          await FirebaseFirestore.instance.collection("npay").doc(np.id).delete();
          await FirebaseFirestore.instance.collection("npay").doc("${npt['bill_id']}").set(npt);
        }*/
        // npt['i'] = np.id;
        Utils.netPayments.add(npt);
      }
      ;

      Utils.netPayments.sort((a, b) {
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
    });
    setState(() {
      gettingPayments = false;
    });
    setListener();
    changeSelected();
  }

  copy(context, text) {
    Clipboard.setData(ClipboardData(text: text)).then((value) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Copied.'),
        duration: Duration(milliseconds: 300),
      ));
    });
  }

  callUser(mobile) async {
    if (await canLaunch('tel:${mobile}')) {
      await launch('tel:${mobile}');
    } else {
      throw 'Could not launch tel:${mobile}';
    }
  }

  showReceipt(context, pay, Map user) async {
    // print(pay);
    var rem = <Widget>[];
    double h8 = 8;
    if (pay['s'] != 'failed') {
      var s = pay['r'].toString();
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
        Text('Date: ${pay['d']}'),
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
        if (pay['msg'] != null)
          SizedBox(
            height: h8,
          ),
        if (pay['msg'] != null)
          InkWell(
              onTap: () {
                copy(context, '${pay['msg']}');
              },
              child: Text('Message: ${pay['msg']}')),
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
    } else if (pay['msg'] != null) {
      var s = pay['r'].toString();
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
        Text('Date: ${pay['d']}'),
        SizedBox(
          height: h8,
        ),
        InkWell(
            onTap: () {
              copy(context, '${r['TXNID']}');
            },
            child: Text('Transaction Id: ${r['TXNID']}')),
        SizedBox(
          height: h8,
        ),
        InkWell(
            onTap: () {
              copy(context, '${r['BANKTXNID']}');
            },
            child: Text('Bank Transaction Id: ${r['BANKTXNID']}')),
        SizedBox(
          height: h8,
        ),
        Text('Payment Mode: ${r['PAYMENTMODE']} - ${r['GATEWAYNAME']}'),
        SizedBox(
          height: h8,
        ),
        Text('Message: ${pay['msg']}'),
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
        SizedBox(
          height: h8,
        ),
        Text(
          "Renewal ${pay['rs'] == 0 ? "Pending" : pay['rs'] == 1 ? "Success" : "Failed"}",
        ),
        if (pay['rse'] != null)
          SizedBox(
            height: h8,
          ),
        if (pay['rse'] != null)
          Text(
            "Renewal ${pay['rs'] == 0 ? "Pending" : pay['rs'] == 1 ? "Success" : "Failed"}",
          )
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
                  Map netUser = user.cast();
                  netUser.addAll(Utils.netUsers[user['uid']]);
                  NetUser nUser = NetUser.fromJson(netUser);
                  if (pay['bill_id'] != null && pay['bill_id'] != "") {
                    Utils.showLoadingDialog(context, "Generating Bill");
                    await PdfGeneration.generateBill(
                        pay['gst'] != 0,
                        nUser.userId,
                        nUser.name,
                        nUser.address,
                        nUser.mobile,
                        nUser.email,
                        pay['p'],
                        pay['bill_id'],
                        pay['d'],
                        "${pay['i_c']}",
                        "${pay['gst']}",
                        "${pay['a']}");
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
                      'Rs. ${pay['a']}   ',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    )),
                InkWell(
                    onTap: () {
                      copy(context, '${pay['u_id'].toUpperCase()}');
                    },
                    child: Text('${pay['u_id'].toUpperCase()}',
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
                      copy(context, '${pay['u_id']}');
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
                      copy(context, '${pay['i'] ?? "-"}');
                    },
                    child: Text('Order Id: ${pay['i'] ?? "-"}')),
                SizedBox(
                  height: h8,
                ),
                if (pay["s"] == "success")
                  InkWell(
                      onTap: () async {
                        if (pay['bill_id'] == null ||
                            pay['bill_id'] == "" ||
                            pay['bill_id'] == "-" ||
                            pay['bill_id'] == "9999999999") {
                          var r = await askBillID() ?? [false];
                          if (r[0]) {
                            Utils.showLoadingDialog(context, "Loading");
                            pay.addAll({
                              "bill_id": r[1],
                              "rs": 1,
                              "i": pay['i'],
                              "rse": "Manual Renewal."
                            });
                            print("${pay['i']}");
                            // await FirebaseFirestore.instance.collection("npay").doc("${pay['i']}").get().then((value) => u.addAll(value.data()));
                            await FirebaseFirestore.instance
                                .collection("npay")
                                .doc("${pay['i']}")
                                .delete();
                            await FirebaseFirestore.instance
                                .collection("npay")
                                .doc("${pay['bill_id']}")
                                .set(pay);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        } else {
                          copy(context, '${pay['bill_id']}');
                        }
                      },
                      child: Text('Bill Id: ${pay['bill_id'] ?? "-"}')),
                  if (pay["s"] == "pending")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          onPressed: () async {
                            Utils.showLoadingDialog(context, "Loading");
                            pay.addAll({
                              "bill_id": "",
                              "rs": -1,
                              "s": "failed",
                              "i": pay['i'],
                              "rse": "Manual Update."
                            });
                            print("${pay['i']}");
                            await FirebaseFirestore.instance
                                .collection("npay")
                                .doc("${pay['i']}")
                                .update(pay);
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
                              pay.addAll({
                                "bill_id": r[1],
                                "rs": 1,
                                "i": pay['i'],
                                "s": "success",
                                "rse": "Manual Renewal."
                              });
                              print("${pay['i']}");
                              // await FirebaseFirestore.instance.collection("npay").doc("${pay['i']}").get().then((value) => u.addAll(value.data()));
                              await FirebaseFirestore.instance
                                  .collection("npay")
                                  .doc("${pay['i']}")
                                  .delete();
                              await FirebaseFirestore.instance
                                  .collection("npay")
                                  .doc("${pay['bill_id']}")
                                  .set(pay);
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

  changeSelected() async {
    payms = [];
    if (selected == 0) {
      payms = Utils.netPayments
          .where((e) => e['s'] == 'success' && ((e['rs'] ?? 0) == 1))
          .toList();
    } else if (selected == 1) {
      payms = Utils.netPayments
          .where((e) => e['s'] == 'success' && ((e['rs'] ?? 0) != 1))
          .toList();
    } else {
      payms = Utils.netPayments.where((e) => e['s'] != 'success').toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: gettingPayments,
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            title: Text(
              'Net Payments',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(28),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          selected = 0;
                          changeSelected();
                        },
                        child: Container(
                          width: 113,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Color(0xff00fd5d),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  topLeft: Radius.circular(8)),
                              border: Border.all(
                                  color: Color(0xff00fd5d),
                                  width: selected == 0 ? 3 : 0)),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Success',
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          selected = 1;
                          changeSelected();
                        },
                        child: Container(
                          width: 113,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.yellow,
                              border: Border.all(
                                  color: Colors.yellow,
                                  width: selected == 1 ? 3 : 0)),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Pending',
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          selected = 2;
                          changeSelected();
                        },
                        child: Container(
                          width: 113,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Color(0xffffaf00),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(8),
                                  topRight: Radius.circular(8)),
                              border: Border.all(
                                  color: Color(0xffffaf00),
                                  width: selected == 2 ? 3 : 0)),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Failed',
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () async {
                    getNetPayments();
                  },
                  child: Text(
                    'Reload',
                    style: TextStyle(color: Colors.blue),
                  ))
            ],
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          body: Builder(
            builder: (context) => SingleChildScrollView(
              controller: scroll_controller,
              child: Column(
                children: <Widget>[
                      if (gettingPayments) LinearProgressIndicator()
                    ] +
                    List<Widget>.generate(min(viewItems, payms.length),
                        (index) {
                      var pay = payms[index];
                      /*int td = pay['s'] != 'failed'
                          ? pay['r'].indexOf('TXNDATE')
                          : 0;
                      String date = pay['d'];*/
                      var user = Utils.usersMap[pay['uid']];
                      return NetPayTile(pay: NetPay.fromJson(pay),user: user,);
                      /*return InkWell(
                        splashColor: Colors.black,
                        onTap: () async {
                          print(pay['i']);
                          await showReceipt(context, pay, user);
                          setState(() {

                          });
                        },
                        onLongPress: () {
                          copy(context, '${pay['u_id']}');
                        },
                        onDoubleTap: () {
                          callUser('${user['mobile']}');
                        },
                        child: Container(
                          decoration: contDec,
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${pay['u_id']}",
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16)),
                                    FittedBox(
                                        child: Text("${user['name']}",
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14))),
                                  ],
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                        child: Text(
                                      "${date}",
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 10),
                                    )),
                                    Text(
                                      "\u20b9 ${pay['a']}",
                                      style: pay['s'] == 'success'
                                          ? successPriceStyle
                                          : pay['s'] == 'failed'
                                              ? failurePriceStyle
                                              : pendingPriceStyle,
                                    ),
                                    if (pay['s'] == 'success')
                                      FittedBox(
                                          child: Text(
                                        "Renewal ${pay['rs'] == 0 ? "Pending" : pay['rs'] == 1 ? "Success" : "Failed"}",
                                        style: TextStyle(
                                            color: (pay['rs'] == 0
                                                ? Colors.amber
                                                : pay['rs'] == 1
                                                    ? Colors.green
                                                    : Colors.red),
                                            fontSize: 10),
                                      )),
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
          ),
        ),
      ),
    );
  }
}
