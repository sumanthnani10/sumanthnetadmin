import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:sumanth_net_admin/error_screen.dart';
import 'package:sumanth_net_admin/isp/jaze_isp.dart';
import 'package:sumanth_net_admin/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Renew extends StatefulWidget {
  final user;

  const Renew({Key key, this.user}) : super(key: key);

  @override
  _RenewState createState() => _RenewState();
}

class _RenewState extends State<Renew> {
  List<String> plans = [];
  List amounts = [];
  bool loading = false;
  String selectedPlan = '';
  String validity = '1 Month';
  var response;
  String id = Utils.generateId("${Utils.isp.billsCollection}_");
  var u;

  List<dynamic> paymentOptions = ["Gpay","Phonepe","Paytm","Cash","Card"];
  int selected = 0, times = 1;

  TextEditingController notesFieldController;
  bool amountFieldCheck = true, routerFieldCheck = false, installationFieldCheck = false, otherFieldCheck = false;
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  bool gst = false;

  @override
  void initState() {
    super.initState();
    plans = Utils.isp.planNames;
    selectedPlan = widget.user['plan'];
    validity = '${Utils.isp.plans[selectedPlan]['m']??""} ${Utils.isp.plans[selectedPlan]['m']==1?"Month":"Months"}';
    DateTime now = DateTime.now();
    u = {
      'total': Utils.isp.plans[selectedPlan]['sr']??0, // total amount
      'id': "$id",
      'bill_id': "",
      'coupon': "", // coupon used
      "date": "${now.day>9?now.day:"0${now.day}"}-${now.month>9?now.month:"0${now.month}"}-${now.year}", // date
      "bill": {
        'internet': Utils.isp.plans[selectedPlan]['sr']??0, // internet charges,
        'gst': 0, // gst,
        'ip': 0, // static price,
        "installation": 0,
        "router": 0,
        "other": 0,
        'saved': (Utils.isp.plans[selectedPlan]["pay_resp"]??0) - (Utils.isp.plans[selectedPlan]['sr']??0), // saved
      },
      "notes": "",
      'plan': selectedPlan, // plan
      'pay_resp': "{PAYMENTMODE: Direct, GATEWAYNAME: Gpay, STATUS: Success, RESPMSG: ,}", // response
      "renewal": {
        'status': 1, // renewal status
        'error': "", // renewal error
      },
      'status': "success", // payment status
      'uid': widget.user["uid"], // uid
      'userid': widget.user["user_id"], // user id
    };
    amounts = [
      {
        "key": "internet",
        "title": "Internet Charges",
        "check": true,
        "controller": new TextEditingController(text: '${Utils.isp.plans[selectedPlan]['sr']??0}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Renew',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
                onPressed: () async {
                  if (!loading) {
                    for(int i = 0; i < times; i++) {
                      id = Utils.generateId("${Utils.isp.billsCollection}_");
                      await renewUser(i);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Renew',
                  style: TextStyle(color: Colors.blue),
                ))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  color: Colors.blue[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('${widget.user['user_id']} - ${widget.user['name']}\n${widget.user['address']}\n${widget.user['mobile']} - ${widget.user['email']}\n${widget.user['plan']} (${widget.user['activation_date']} to ${widget.user['expiry_date']})\n${widget.user['static_ip']}'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  color: Colors.green[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text('${selectedPlan} - ${validity}')),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(onTap: (){if(times != 1)times-=1;setState((){});}, child: Icon(CupertinoIcons.minus)),
                            SizedBox(width: 8,),
                            Text("$times times",style: TextStyle(fontWeight: FontWeight.bold),),
                            SizedBox(width: 8,),
                            InkWell(onTap: (){times+=1;setState((){});}, child: Icon(CupertinoIcons.plus)),
                          ]
                      ),
                    ],
                  ),
                ),
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
                  child: DropdownButton(
                      isExpanded: true,
                      items: List.generate(
                          plans.length,
                          (index) => DropdownMenuItem(
                                child: Text('${plans[index]}'),
                                value: plans[index],
                              )),
                      value: selectedPlan,
                      onChanged: (v) {
                        setState(() {
                          selectedPlan = v;
                          u['p'] = selectedPlan;
                          validity = '${Utils.isp.plans[selectedPlan]['m']} ${Utils.isp.plans[selectedPlan]['m']==1?"Month":"Months"}';
                          amounts[0]["controller"].text = "${Utils.isp.plans[selectedPlan]['sr']??0}";
                          setState((){calculate();});
                        });
                      }),
                )] +
                List.generate(amounts.length, (i) {
                  return Container(
                      color: i%2==0?Colors.transparent:Colors.black12,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Checkbox(value: amounts[i]["check"], onChanged: (v) {
                            setState(() {
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
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(prefixText: "Rs. ", contentPadding: EdgeInsets.zero),
                              onFieldSubmitted: (v){setState((){calculate();});},
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
                    controller: notesFieldController,
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
                            InkWell(onTap: (){if(selected==0){selected = paymentOptions.length;}selected-=1;u["pay_resp"] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";setState((){});}, child: Icon(CupertinoIcons.left_chevron)),
                            Text(paymentOptions[selected]),
                            InkWell(onTap: (){if(selected==paymentOptions.length-1){selected = -1;}selected+=1;u["pay_resp"] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";setState((){});}, child: Icon(CupertinoIcons.right_chevron)),
                          ]
                      ),
                      InkWell(
                        onTap: () {
                          setState((){gst = !gst;  calculate();});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(value: gst, onChanged: (bool value) {setState((){gst = value; calculate();});}),
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
      ),
    );
  }

  Future<bool> renewUser(i) async {
    Utils.showLoadingDialog(context, "Renew (${i+1}/$times)");
    calculate();
    ISPResponse ispResponse = await Utils.isp.renewUser(widget.user, selectedPlan);
    var resp = ispResponse.response["data"];
    u["renewal"] = resp["renewal"];
    Navigator.pop(context);

    if (ispResponse.success) {
      Utils.showLoadingDialog(context, "Billing ${i+1}/$times");

      ispResponse = await Utils.isp.addLatestBillToFirebase(u);
      resp = ispResponse.response["data"];
      Navigator.pop(context);
      print(ispResponse.success);
      print(ispResponse.message);
      print(resp);
      if (!ispResponse.success) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(ispResponse: ispResponse),
            ));
        return false;
      } else {
        return true;
      }

    } else {
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorScreen(ispResponse: ispResponse),
          ));
      return false;
    }
  }

  calculate() async {
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
    // u["total"] = u["bill"]["internet"] + u["bill"]["gst"] + u["bill"]["ip"];
    u["bill"]["saved"] = -(Utils.isp.plans[selectedPlan]["p"]??0 - u["bill"]["internet"]);
    u["pay_resp"] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";
  }

}

/*Future<bool> renewUserOld(i) async {
    setState(() {
      loading = true;
    });

    Utils.showLoadingDialog(context, "Renew (${i+1}/$times)");
    DateTime today = DateTime.now();
    String date = '${today.year}-${today.month}-${today.day<10?'0${today.day}':today.day}';

    var body = {
      "userIds": widget.user['uid'].toString(),
      "accountId": "022825sumanthanetworks",
      "renewDefaultSettings": 'false',
      "isForceMakePayment": 'true',
      "isRenewPresentDate": 'false',
      "isPreviousGroupchange": 'false',
      "isRenewPaidUsers": 'false',
      "isRenewWithDays": 'false',
      "payAsYouGoDays": "30",
      "payAsYouGoResetEvery": "",
      "renewPeriod": "days",
      "renewTimes": "1",
      "isChangePlan": 'false',
      "planId": "presentPlan",
      "groupId": "",
      "renewEnable": "0",
      "scheduleRenew": 'false',
      "scheduleBasedOn": "nextBilling",
      "scheduleDate": date,
      "prorataBasis": 'false',
      "prorataDateBasis": 'false',
      "overridePriceEnable": 'false',
      "overrideAmount": "",
      "overridePriceBasedOn": "withTax",
      "renewalcomments": ""
    };
    if(selectedPlan!=widget.user['plan']){
      body = {
        "userIds": widget.user['uid'].toString(),
        "accountId": "022825sumanthanetworks",
        "renewDefaultSettings": "false",
        "isForceMakePayment": "true",
        "isRenewPresentDate": "false",
        "isPreviousGroupchange": "false",
        "isRenewPaidUsers": "false",
        "isRenewWithDays": "false",
        "payAsYouGoDays": "30",
        "payAsYouGoResetEvery": "",
        "renewPeriod": "days",
        "renewTimes": "1",
        "isChangePlan": "true",
        "planId": Utils.isp.plans[selectedPlan]['p'],
        "groupId": Utils.isp.plans[selectedPlan]['g'],
        "renewEnable": "0",
        "scheduleRenew": "false",
        "scheduleBasedOn": "nextBilling",
        "scheduleDate": date,
        "prorataBasis": "false",
        "prorataDateBasis": "false",
        "overridePriceEnable": "false",
        "overrideAmount": "",
        "overridePriceBasedOn": "withTax",
        "renewalcomments": ""
      };
    }
    response = await http.post(
        Utils.RENEW_USER,
        body: body,headers: {'cookie':Utils.cookie, 'authorization': Utils.authorization});
    var resp = json.decode(response.body);
    Navigator.pop(context);
    if (resp['status'] == 'success') {
      Utils.showLoadingDialog(context, "Billing ${i+1}/$times");

      await Utils.checkLogin();
      resp = await http.post(
        Utils.getUserBillsByUIDLink(widget.user['uid']),
        headers: Utils.headers,
      );
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        setState(() {
          u["bill_id"] = jsonDecode(r['message'])[0]["FranchiseStatement"]["reference_id"];
        });
      } else {
        await Utils.showErrorDialog(context, "Error", "Getting Bill ID unsuccessful.");

      }

      await FirebaseFirestore.instance
          .collection('${Utils.isp.billsCollection}')
          // .doc(id)
          .doc(u["bill_id"])
          .set(u).catchError((e)async{await Utils.showErrorDialog(context, "Error", "$e");});

      Navigator.pop(context);
      return true;
    } else {
      Navigator.pop(context);
      /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorScreen(error: resp.toString(),html: false),
          ));*/
      return false;
    }
  }*/
