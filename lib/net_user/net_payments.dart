import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sumanth_net_admin/net_pay.dart';
import './net_user.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pdf_generation.dart';
import '../utils.dart';

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

  ScrollController scrollC = new ScrollController();

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
    scrollC
      ..addListener(() {
        if (scrollC.offset >=
                scrollC.position.maxScrollExtent &&
            !scrollC.position.outOfRange) {
          viewItems += 20;
          setState(() {});
        } else if (scrollC.offset ==
            scrollC.position.minScrollExtent) {
          setState(() {
            viewItems = 20;
          });
        }
      });
  }

  @override
  void dispose() {
    scrollC.dispose();
    super.dispose();
  }

  getNetPayments() async {
    setState(() {
      gettingPayments = true;
    });
    await FirebaseFirestore.instance
        .collection('${Utils.isp.billsCollection}')
        .get()
        .then((pays) async {
      Utils.isp.netPayments = [];
      for (int i = 0; i < pays.docs.length; i++) {
        var np = pays.docs[i];
        var npt = np.data();
        npt['i'] = np.id;
        Utils.isp.netPayments.add(npt);
      }
      ;

      Utils.isp.netPayments.sort((a, b) {
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

  changeSelected() async {
    payms = [];
    if (selected == 0) {
      payms = Utils.isp.netPayments
          .where((e) => e['status'] == 'success' && ((e['renewal']["status"] ?? 0) == 1))
          .toList();
    } else if (selected == 1) {
      payms = Utils.isp.netPayments
          .where((e) => e['status'] == 'success' && ((e['renewal']["status"] ?? 0) != 1))
          .toList();
    } else {
      payms = Utils.isp.netPayments.where((e) => e['status'] != 'success').toList();
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
              '${Utils.isp.code.toUpperCase()} Net Payments',
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
              controller: scrollC,
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
                      var user = Utils.isp.usersMap[pay['uid']];
                      return NetPayTile(pay: NetPay.fromJson(pay),user: user,);
                      /*return InkWell(
                        splashColor: Colors.black,
                        onTap: () async {
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
