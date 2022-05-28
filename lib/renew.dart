import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:sumanth_net_admin/error_screen.dart';
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
  bool loading = false;
  String selected_plan = '';
  String validity = '1 Month';
  var response;
  String id = Utils.generateId("npay_");
  var u;

  List<dynamic> paymentOptions = ["Gpay","Phonepe","Paytm","Cash","Card"];
  int selected = 0, times = 1;

  TextEditingController amountFieldController;
  TextEditingController dateFieldController;
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  bool gst = false;
  bool static = false;

  @override
  void initState() {
    super.initState();
    plans = Utils.plans.keys.where((e) => Utils.plans[e]['a']).toList();
    selected_plan = widget.user['plan'];
    validity = '${Utils.plans[selected_plan]['m']} ${Utils.plans[selected_plan]['m']==1?"Month":"Months"}';
    DateTime now = DateTime.now();
    u = {
      'a': Utils.plans[selected_plan]['sr'], // total amount
      'i': "$id",
      'c': "", // coupon used
      "d": "${now.day>9?now.day:"0${now.day}"}-${now.month>9?now.month:"0${now.month}"}-${now.year}", // date
      'gst': 0, // gst
      'i_c': Utils.plans[selected_plan]['sr'], // internet charges
      'p': selected_plan, // plan
      'r': "{PAYMENTMODE: Direct, GATEWAYNAME: Gpay, STATUS: Success, RESPMSG: ,}", // response
      'rs': 1, // renewal status
      'rse': "", // renewal error
      's': "success", // payment status
      'sa': Utils.plans[selected_plan]['r'] - Utils.plans[selected_plan]['sr'], // saved
      'stc': 0, // static price
      'uid': widget.user["uid"], // uid
      'u_id': widget.user["user_id"], // user id
    };
    amountFieldController = new TextEditingController(text: '${Utils.plans[selected_plan]['sr']}');
    dateFieldController = new TextEditingController(text: u['d']);
  }

  Future<bool> renewUser(i) async {
    setState(() {
      loading = true;
    });

    Utils.showLoadingDialog(context, "Renew (${i+1}/$times)");
    await Utils.checkLogin();
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
    if(selected_plan!=widget.user['plan']){
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
        "planId": Utils.plans[selected_plan]['p'],
        "groupId": Utils.plans[selected_plan]['g'],
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
    // print(body.toString());
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
          .collection('npay')
          // .doc(id)
          .doc(u["bill_id"])
          .set(u).catchError((e)async{await Utils.showErrorDialog(context, "Error", "$e");});

      Navigator.pop(context);
      return true;
    } else {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorScreen(error: resp.toString(),html: false),
          ));
      return false;
    }
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
                      id = Utils.generateId("npay_");
                      if(!await renewUser(i)){
                        break;
                      }
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
                      Text('${widget.user['user_id']}'),
                      Text('${widget.user['name']}'),
                      Text('${widget.user['address']}'),
                      Text('${widget.user['mobile']}'),
                      Text('${widget.user['email']}'),
                      Text('${widget.user['plan']}'),
                      Text(
                          '${widget.user['activation_date']} to ${widget.user['expiry_date']}'),
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
                          child: Text('${selected_plan}')),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text('${validity}')),
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
                                child: Text('${plans[index]}'),
                                value: plans[index],
                              )),
                      value: selected_plan,
                      onChanged: (v) {
                        setState(() {
                          selected_plan = v;
                          u['p'] = selected_plan;
                          validity = '${Utils.plans[selected_plan]['m']} ${Utils.plans[selected_plan]['m']==1?"Month":"Months"}';
                          amountFieldController.text = "${Utils.plans[selected_plan]['sr']}";
                          setState((){calculate();});
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: dateFieldController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(labelText: "Date"),
                          onChanged: (v){
                            u['d'] = v;
                          },
                        ),
                      ),
                      Container(color: Colors.black, width: 1,height: 48, margin: const EdgeInsets.symmetric(horizontal: 8),),
                      Flexible(
                        child: TextFormField(
                          controller: amountFieldController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: "Amount", prefixText: "Rs. "),
                          onFieldSubmitted: (v){setState((){calculate();});},
                        ),
                      ),
                    ],
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
                            InkWell(onTap: (){if(selected==0){selected = paymentOptions.length;}selected-=1;u['r'] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";setState((){});}, child: Icon(CupertinoIcons.left_chevron)),
                            Text(paymentOptions[selected]),
                            InkWell(onTap: (){if(selected==paymentOptions.length-1){selected = -1;}selected+=1;u['r'] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";setState((){});}, child: Icon(CupertinoIcons.right_chevron)),
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
                      InkWell(
                        onTap: () {
                          setState((){static = !static;  calculate();});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(value: static, onChanged: (bool value) {setState((){static = value; calculate();});}),
                            Text("Static IP")
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                    'Total: Rs.${u['a']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),textAlign: TextAlign.center,),
                Text('${u['i_c']} (Plan)${gst
                        ? ' + ${u['gst']} (with GST)'
                        : ''} ${static
                        ? ' + ${u['stc']} (static IP)'
                        : ''}', style: TextStyle(fontSize: 12,),textAlign: TextAlign.center,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  calculate() async {
    u['gst'] = 0;
    u['stc'] = (static?Utils.staticIPPrice:0)* Utils.plans[selected_plan]['m'];
    u['i_c'] = int.parse(amountFieldController.text);
    if(gst){
      u["gst"] = (u['i_c'] * 0.18).toInt();
    }
    u['a'] = u['i_c'] + u['gst'] + u['stc'];
    u['sa'] = Utils.plans[selected_plan]['r'] - u['i_c'];
    u['r'] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";
  }

}
