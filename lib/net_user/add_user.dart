import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sumanth_net_admin/error_screen.dart';
import 'package:sumanth_net_admin/isp/jaze_isp.dart';
import 'package:sumanth_net_admin/utils.dart';

class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  List<Plan> plans = [];
  String userID = "",
      name = '',
      phone = '',
      email = '',
      address = '',
      gender = "Male",
      staticIp = "10.10.60.";
  Plan selectedPlan;
  bool loading = false;
  var logger = Logger();

  TextEditingController userIDC = new TextEditingController();
  TextEditingController nameC = new TextEditingController();
  TextEditingController phoneC = new TextEditingController();
  TextEditingController emailC = new TextEditingController();
  TextEditingController addressC = new TextEditingController();
  TextEditingController staticIPC = new TextEditingController(
      text: "10.10.10.${Utils.sscIsp.getSpecifics()["lastIP"]}");
  TextEditingController notesC = new TextEditingController(text: "");

  String id = Utils.generateId("${Utils.isp.billsCollection}_");
  var u;
  DateTime now = DateTime.now();

  List<dynamic> paymentOptions = ["UPI", "Cash", "Card"];
  int selected = 0;

  TextEditingController amountC;

  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  List amounts = [];
  bool gst = false;
  bool static = false;
  String circuitID = "";

  String uid = "";

  @override
  void initState() {
    super.initState();
    plans = Utils.isp.plans_.list;
    Utils.isp.loadPlans();
    selectedPlan = plans[0];
    /*u = {
      'a': Utils.isp.plans[selectedPlan].price, // total amount
      'i': "$id", // bill id
      'c': "", // coupon used
      "d": "${now.day>9?now.day:"0${now.day}"}-${now.month>9?now.month:"0${now.month}"}-${now.year}", // date
      'gst': 0, // gst
      'i_c': Utils.isp.plans[selectedPlan].price, // internet charges
      'p': selectedPlan, // plan
      'r': "{PAYMENTMODE: Direct, GATEWAYNAME: UPI, STATUS: Success, RESPMSG: ,}", // response
      'rs': 1, // renewal states
      'rse': "", // renewal error
      's': "success", // payment status
      'sa': Utils.isp.plans[selectedPlan].mrp - Utils.isp.plans[selectedPlan].price, // saved
      'stc': 0, // static price
      'uid': "", // uid
      'u_id': "", // user id
    };*/
    u = {
      'total': selectedPlan.price ?? 0,
      // total amount
      'id': "$id",
      'bill_id': "",
      'coupon': "",
      // coupon used
      "date": "${Utils.formatDate(now)}",
      "expiry":
          "${Utils.formatDate(now.add(Duration(days: 30 * selectedPlan.months)))}", // date
      "bill": {
        'internet': selectedPlan.price ?? 0,
        // internet charges,
        'gst': 0,
        // gst,
        'ip': 0,
        // static price,
        "installation": 0,
        "router": 0,
        "others": 0,
        'saved': (selectedPlan.mrp) - (selectedPlan.price),
        // saved
      },
      "notes": "",
      'plan': selectedPlan.name,
      // plan
      'pay_resp':
          "{PAYMENTMODE: Direct, GATEWAYNAME: UPI, STATUS: Success, RESPMSG: ,}",
      // response
      "renewal": {
        'status': 1, // renewal status
        'error': "", // renewal error
      },
      'status': "success",
      // payment status
      'uid': "",
      // uid
      'userid': "",
      // user id
    };
    amounts = [
      {
        "key": "internet",
        "title": "Internet Charges",
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
    amountC = new TextEditingController(text: '${selectedPlan.price}');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getCircuitId();
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
            'Add User',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: <Widget>[
            TextButton(
                onPressed: () async {
                  addUser();
                },
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.blue),
                ))
          ],
        ),
        body: AbsorbPointer(
          absorbing: loading,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            onChanged: (v) {
                              userID = v;
                              u['userid'] = v;
                            },
                            validator: (v) {
                              if (v.isEmpty) {
                                return 'Enter User ID';
                              } else {
                                return null;
                              }
                            },
                            controller: userIDC,
                            keyboardType: TextInputType.text,
                            onEditingComplete: () {
                              FocusScope.of(context).unfocus();
                              FocusScope.of(context).nextFocus();
                            },
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            maxLines: 1,
                            decoration: InputDecoration(
                                filled: false,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(8)),
                                hintText: "User ID *",
                                labelText: 'User ID *'),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            onChanged: (v) {
                              name = v;
                            },
                            validator: (v) {
                              if (v.isEmpty) {
                                return 'Enter Name';
                              } else {
                                return null;
                              }
                            },
                            controller: nameC,
                            keyboardType: TextInputType.text,
                            onEditingComplete: () {
                              FocusScope.of(context).unfocus();
                              FocusScope.of(context).nextFocus();
                            },
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            maxLines: 1,
                            decoration: InputDecoration(
                                filled: false,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(8)),
                                hintText: "Name *",
                                labelText: 'Name *'),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: TextFormField(
                                  onEditingComplete: () {
                                    FocusScope.of(context).unfocus();
                                    FocusScope.of(context).nextFocus();
                                  },
                                  textInputAction: TextInputAction.next,
                                  onChanged: (v) {
                                    phone = v;
                                  },
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return 'Enter Phone Number';
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: phoneC,
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      filled: false,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      hintText: "Phone *",
                                      labelText: 'Phone *'),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Flexible(
                                flex: 2,
                                child: TextFormField(
                                  onEditingComplete: () {
                                    FocusScope.of(context).unfocus();
                                    FocusScope.of(context).nextFocus();
                                  },
                                  textInputAction: TextInputAction.next,
                                  onChanged: (v) {
                                    email = v;
                                  },
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return 'Enter Email';
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: emailC,
                                  keyboardType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.none,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      filled: false,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      hintText: "Email *",
                                      labelText: 'Email *'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            onEditingComplete: () {
                              FocusScope.of(context).unfocus();
                              FocusScope.of(context).nextFocus();
                            },
                            maxLength: 50,
                            textInputAction: TextInputAction.done,
                            onChanged: (v) {
                              address = v;
                            },
                            validator: (v) {
                              if (v.isEmpty) {
                                return 'Enter Address';
                              } else {
                                return null;
                              }
                            },
                            controller: addressC,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            maxLines: 1,
                            decoration: InputDecoration(
                                filled: false,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(8)),
                                hintText: "Address *",
                                labelText: 'Address *'),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: TextFormField(
                                  onEditingComplete: () {
                                    FocusScope.of(context).unfocus();
                                    FocusScope.of(context).nextFocus();
                                  },
                                  textInputAction: TextInputAction.done,
                                  onChanged: (v) {
                                    staticIp = v;
                                  },
                                  validator: (v) {
                                    return null;
                                  },
                                  controller: staticIPC,
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      filled: false,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      hintText: "Static IP",
                                      labelText: 'Static IP'),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          child: ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            gender = "Male";
                                          });
                                        },
                                        child: Text(
                                          "Male",
                                          style: TextStyle(
                                              color: gender == "Male"
                                                  ? Colors.black
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(8),
                                            primary: gender != "Male"
                                                ? Colors.black
                                                : Colors.white),
                                      )),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                          child: ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            gender = "Female";
                                          });
                                        },
                                        child: Text(
                                          "Female",
                                          style: TextStyle(
                                              color: gender == "Female"
                                                  ? Colors.black
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(8),
                                            primary: gender != "Female"
                                                ? Colors.black
                                                : Colors.white),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 1, horizontal: 8),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
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
                                  setState(() {
                                    selectedPlan = v;
                                    u['plan'] = v.name;
                                    amountC.text = "${selectedPlan.price}";
                                    u["expiry"] =
                                        "${Utils.formatDate(now.add(Duration(days: 30 * selectedPlan.months)))}";
                                    setState(() {
                                      calculate();
                                    });
                                  });
                                }),
                          ),
                          /*Padding(
                        padding: const EdgeInsets.only(right: 0, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        if (selected > 0) {
                                          selected -= 1;
                                          u["pay_resp"] =
                                              "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";
                                          setState(() {});
                                        }
                                      },
                                      icon: Icon(
                                          CupertinoIcons.left_chevron)),
                                  Text(paymentOptions[selected]),
                                  IconButton(
                                      onPressed: () {
                                        if (selected <
                                            paymentOptions.length - 1) {
                                          selected += 1;
                                          u["pay_resp"] =
                                              "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";
                                          setState(() {});
                                        }
                                      },
                                      icon: Icon(
                                          CupertinoIcons.right_chevron)),
                                ]),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  gst = !gst;
                                  calculate();
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                      value: gst,
                                      onChanged: (bool value) {
                                        setState(() {
                                          gst = value;
                                          calculate();
                                        });
                                      }),
                                  Text("GST")
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  static = !static;
                                  calculate();
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                      value: static,
                                      onChanged: (bool value) {
                                        setState(() {
                                          static = value;
                                          calculate();
                                        });
                                      }),
                                  Text("Static IP")
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Total: Rs.${u["bill"]['internet']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${gst ? ' (with GST)' : ''} ${static ? ' (static: ${Utils.staticIPPrice * Utils.isp.plans[selectedPlan].months})' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),*/
                        ] +
                        List.generate(amounts.length, (i) {
                          return Container(
                            color: i % 2 == 0
                                ? Colors.transparent
                                : Colors.black12,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Checkbox(
                                    value: amounts[i]["check"],
                                    onChanged: (v) {
                                      setState(() {
                                        amounts[i]["check"] = v;
                                        calculate();
                                      });
                                    }),
                                Flexible(
                                  flex: 2,
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("${amounts[i]["title"]}")),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: amounts[i]["controller"],
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        prefixText: "Rs. ",
                                        contentPadding: EdgeInsets.zero),
                                    onFieldSubmitted: (v) {
                                      setState(() {
                                        calculate();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }) +
                        [
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
                              decoration: InputDecoration(
                                  labelText: "Notes",
                                  contentPadding: EdgeInsets.zero),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 0, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            if (selected == 0) {
                                              selected = paymentOptions.length;
                                            }
                                            selected -= 1;
                                            u["pay_resp"] =
                                                "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";
                                            setState(() {});
                                          },
                                          child: Icon(
                                              CupertinoIcons.left_chevron)),
                                      Text(paymentOptions[selected]),
                                      InkWell(
                                          onTap: () {
                                            if (selected ==
                                                paymentOptions.length - 1) {
                                              selected = -1;
                                            }
                                            selected += 1;
                                            u["pay_resp"] =
                                                "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";
                                            setState(() {});
                                          },
                                          child: Icon(
                                              CupertinoIcons.right_chevron)),
                                    ]),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      gst = !gst;
                                      calculate();
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                          value: gst,
                                          onChanged: (bool value) {
                                            setState(() {
                                              gst = value;
                                              calculate();
                                            });
                                          }),
                                      Text("GST")
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Total: Rs.${u["total"]}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '${u["bill"]["internet"]} (Plan)${gst ? ' + ${u["bill"]["gst"]} (with GST)' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  addUser() async {
    Utils.showLoadingDialog(context, "Creating User");

    var user = {
      "userName": "$userID",
      "firstName": "$name",
      "phoneNumber": "$phone",
      "emailId": "$email",
      "address_line1": "$address",
    };

    ISPResponse ispResponse = await Utils.isp.addUser(user, selectedPlan.name);
    var resp = ispResponse.response["data"];

    Navigator.pop(context);

    if (ispResponse.success) {
      uid = resp['message']['userId'];
      u['uid'] = uid;

      Utils.showLoadingDialog(context, "Billing");

      ispResponse = await Utils.isp.addLatestBillToFirebase(u);
      resp = ispResponse.response["data"];

      Navigator.pop(context);

      if (!ispResponse.success) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorScreen(ispResponse: ispResponse),
            ));
      }
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorScreen(ispResponse: ispResponse),
          ));
    }
  }

  /*addUserOld() async {
    Utils.showLoadingDialog(context, "Creating User");
    var tomorrow = now.add(Duration(days: 1));
    var body = {
      "userName": "$userID",
      "password": "12345678",
      "userGroupId": "${Utils.isp.plans[selectedPlan]['g']}",
      "userPlanId": "${Utils.isp.plans[selectedPlan]['p']}",
      "firstName": "$name",
      "phoneNumber": "$phone",
      "emailId": "$email",
      "address_line1": "$address",
      "additionalField1": "$gender",
      "circuitId": "$circuitID",
      "gstApplicableFrom":
          "${now.year}-${now.month > 9 ? now.month : "0${now.month}"}-${now.day > 9 ? now.day : "0${now.day}"}",
      "customExpirationDate":
          "${tomorrow.day > 9 ? tomorrow.day : "0${tomorrow.day}"}-${tomorrow.month > 9 ? tomorrow.month : "0${tomorrow.month}"}-${tomorrow.year} ${tomorrow.hour > 9 ? tomorrow.hour : "0${tomorrow.hour}"}:${tomorrow.minute > 9 ? tomorrow.minute : "0${tomorrow.minute}"}:${tomorrow.second > 9 ? tomorrow.second : "0${tomorrow.second}"}",
      "chequeDate":
          "${now.day > 9 ? now.day : "0${now.day}"}-${now.month > 9 ? now.month : "0${now.month}"}-${now.year}",
      "installation_address_line1": "$address",
      "lastName": "",
      "enterOTPDisplay": "yes",
      "tempPhone": "",
      "altPhoneNumber": "",
      "altEmailId": "",
      "address_line2": "ptc",
      "address_city": "hyderabad",
      "address_pin": "502319",
      "address_state": "telangana",
      "address_country": "IN",
      "address": "",
      "createBilling": "on",
      "afterAction": "suspend",
      "gstNumber": "",
      "userType": "home",
      "selectStbMac": "",
      "collection_area_import": "",
      "collection_street_import": "",
      "collection_block_import": "",
      "collection_latitude_import": "",
      "collection_longitude_import": "",
      "location_details_not_import": "yes",
      "id_proof": "",
      "id_pin": "",
      "data[Document][submittedIdProof]": "(binary)",
      "installationTime": "",
      "data[Document][submittedproof]": "(binary)",
      "data[Document][submittedform]": "(binary)",
      "caf_num": "",
      "data[Document][submittedReport]": "(binary)",
      "mac": "",
      "ipPoolName": "",
      "disableUserIpAuth": "",
      "disableUserMacAuth": "",
      "disableUserPppoeAuth": "",
      "disableUserHotspotAuth": "",
      "activationDate": "now",
      "expirationDate": "never",
      "comments": "",
      "notifyUserSms": "on",
      "notifyUserEmail": "on",
      "notifyUserWhatsapp": "on",
      "accountId": "022825sumanthanetworks",
      "installation_address_line2": "ptc",
      "installation_address_city": "hyderabad",
      "installation_address_pin": "502319",
      "installation_address_state": "telangana",
      "staticIpAddress[]": "",
      "staticIpBoundMac[]": "",
      "ipMacBillingCharge[]": "",
      "ipMacBillingOverrideEnable[]": 31,
      "ipMacBillingOverrideAmount[]": "",
      "ipMacBillingChargeMethod[]": "",
      "ipMacBillingActiveSince[]": "",
      "ipMacBillingActiveUntil[]": "",
      "ipMacBillingPeriod[]": "",
      "ipMacBillingPeriodType[]": "",
      "ipMacBillingIncludeTax[]": 31,
      "ipoverrideBillingCycleEnable[]": 31,
      "ipoverrideBillingCycleValue[]": "",
      "ipoverrideBillingCycleValueDate[]": "",
      "ipoverrideBillingCycleValueDay[]": "",
      "overrideAmountBasedOn": "withTax",
      "useBillingAddAsInstallationAdd": "on",
      "installation_address_country": "IN",
      "routerChargeMethod": "oneTime",
      "paymentmethod": "cash",
      "bankTransferMethod": "NEFT"
    };
    await Utils.checkLogin();

    logger.i(body);
    logger.i(jsonEncode(body));
    var response =
        await http.post(Utils.ADD_USER, body: jsonEncode(body), headers: {
      'cookie': Utils.cookie,
      'authorization': Utils.authorization,
      "Content-Type": "application/json"
    });
    var resp = json.decode(response.body);
    if (resp['status'] == 'success') {
      uid = resp['message']['userId'];
      u['uid'] = uid;

      Utils.showLoadingDialog(context, "Billing");

      await Utils.checkLogin();
      resp = await http.post(
        Utils.getUserBillsByUIDLink(uid),
        headers: Utils.headers,
      );
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        setState(() {
          u["bill_id"] =
              jsonDecode(r['message'])[0]["FranchiseStatement"]["reference_id"];
        });
      } else {
        await Utils.showErrorDialog(
            context, "Error", "Getting Bill ID unsuccessful.");
      }

      await FirebaseFirestore.instance
          .collection('${Utils.isp.billsCollection}')
          // .doc(id)
          .doc(u["bill_id"])
          .set(u)
          .catchError((e) async {
        await Utils.showErrorDialog(context, "Error", "$e");
      });

      await addUserAuth();

      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          Utils.createRoute(
              SendOtp(
                user: {"mobile": phone, "uid": uid},
              ),
              Utils.RTL));
    } else {
      Navigator.pop(context);
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ErrorScreen(error: resp.toString(),html: false,),
      //     ));
    }
  }*/

  calculate() async {
    u["bill"]["gst"] = 0;
    u["total"] = 0;
    amounts.forEach((amnt) {
      if (amnt["check"]) {
        u["bill"][amnt["key"]] = int.parse(amnt["controller"].text);
        u["total"] += u["bill"][amnt["key"]];
      } else {
        u["bill"][amnt["key"]] = 0;
      }
    });
    if (gst) {
      u["bill"]["gst"] = (u["bill"]["internet"] * 0.18).toInt();
      u["total"] += u["bill"]["gst"];
    }
    // u["total"] = u["bill"]["internet"] + u["bill"]["gst"] + u["bill"]["ip"];
    u["bill"]["saved"] = (selectedPlan.mrp - u["bill"]["internet"]);
    u["pay_resp"] =
        "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";
  }

  getCircuitId() async {
    Utils.showLoadingDialog(context, "Getting User ID.");
    circuitID = await Utils.isp.getCircuitID();
    userIDC.text = "022825$circuitID";
    u["u_id"] = "022825$circuitID";
    userID = "022825$circuitID";
    Navigator.pop(context);
    setState(() {});
  }
}
