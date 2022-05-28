import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:sumanth_net_admin/error_screen.dart';
import 'package:sumanth_net_admin/otp_verification.dart';
import 'package:sumanth_net_admin/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  List<String> plans = [];
  String userID = "",name = '',phone='',email='',address='',selected_plan='', gender = "Male";
  bool loading = false;
  var logger = Logger();

  TextEditingController userIDController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();

  String id = Utils.generateId("npay_");
  var u;

  List<dynamic> paymentOptions = ["Gpay","Phonepe","Paytm","Cash","Card"];
  int selected = 0;

  TextEditingController amountFieldController;

  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  bool gst = false;
  bool static = false;
  DateTime now = DateTime.now();
  String circuitID = "";

  String uid = "";
  
  @override
  void initState() {
    super.initState();
    plans = Utils.plans.keys.where((e) => Utils.plans[e]['a']).toList();
    selected_plan = "Netplus Unlimited_40Mbps_1Month";
    u = {
      'a': Utils.plans[selected_plan]['sr'], // total amount
      'i': "$id", // bill id
      'c': "", // coupon used
      "d": "${now.day>9?now.day:"0${now.day}"}-${now.month>9?now.month:"0${now.month}"}-${now.year}", // date
      'gst': 0, // gst
      'i_c': Utils.plans[selected_plan]['sr'], // internet charges
      'p': selected_plan, // plan
      'r': "{PAYMENTMODE: Direct, GATEWAYNAME: Gpay, STATUS: Success, RESPMSG: ,}", // response
      'rs': 1, // renewal states
      'rse': "", // renewal error
      's': "success", // payment status
      'sa': Utils.plans[selected_plan]['r'] - Utils.plans[selected_plan]['sr'], // saved
      'stc': 0, // static price
      'uid': "", // uid
      'u_id': "", // user id
    };
    amountFieldController = new TextEditingController(text: '${Utils.plans[selected_plan]['sr']}');
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
            TextButton(onPressed: () async { addUser(); }, child: Text('Add',style: TextStyle(color: Colors.blue),))
          ],
        ),
        body: Stack(
          children: <Widget>[
            AbsorbPointer(
              absorbing: loading,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                  children: <Widget>[
                      TextFormField(
                        onChanged: (v) {
                          userID = v;
                          u['u_id'] = v;
                        },
                        validator: (v){
                          if(v.isEmpty){
                            return 'Enter User ID';
                          }
                          else{
                            return null;
                          }
                        },
                        controller: userIDController,
                        keyboardType: TextInputType.text,
                        onEditingComplete: (){
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context).nextFocus();
                        },textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        maxLines: 1,
                        decoration: InputDecoration(
                            filled: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(8)),
                            hintText: "User ID *",
                            labelText: 'User ID *'),
                      ),
                      SizedBox(height: 8,),
                      TextFormField(
                        onChanged: (v) {
                          name = v;
                        },
                        validator: (v){
                          if(v.isEmpty){
                            return 'Enter Name';
                          }
                          else{
                            return null;
                          }
                        },
                        controller: nameController,
                        keyboardType: TextInputType.text,

                        onEditingComplete: (){
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context).nextFocus();
                        },textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        maxLines: 1,
                        decoration: InputDecoration(

                            filled: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(8)),
                            hintText: "Name *",
                            labelText: 'Name *'),
                      ),
                      SizedBox(height: 8,),
                      TextFormField(
                        onEditingComplete: (){
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context).nextFocus();
                        },textInputAction: TextInputAction.next,
                        onChanged: (v) {
                          phone = v;
                        },
                        validator: (v){
                          if(v.isEmpty){
                            return 'Enter Phone Number';
                          }
                          else{
                            return null;
                          }
                        },
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        decoration: InputDecoration(

                            filled: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(8)),
                            hintText: "Phone *",
                            labelText: 'Phone *'),
                      ),
                      SizedBox(height: 8,),
                      TextFormField(
                        onEditingComplete: (){
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context).nextFocus();
                        },
                        textInputAction: TextInputAction.next,
                        onChanged: (v) {
                          email = v;
                        },
                        validator: (v){
                          if(v.isEmpty){
                            return 'Enter Email';
                          }
                          else{
                            return null;
                          }
                        },
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        maxLines: 1,
                        decoration: InputDecoration(

                            filled: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(8)),
                            hintText: "Email *",
                            labelText: 'Email *'),
                      ),
                      SizedBox(height: 8,),
                      TextFormField(
                        onEditingComplete: (){
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context).nextFocus();
                        },
                        maxLength: 50,
                        textInputAction: TextInputAction.done,
                        onChanged: (v) {
                          address = v;
                        },
                        validator: (v){
                          if(v.isEmpty){
                            return 'Enter Address';
                          }
                          else{
                            return null;
                          }
                        },
                        controller: addressController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        maxLines: 1,
                        decoration: InputDecoration(

                            filled: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(8)),
                            hintText: "Address *",
                            labelText: 'Address *'),
                      ),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                        margin:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
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
                                u['p'] = v;
                                amountFieldController.text = "${Utils.plans[selected_plan]['sr']}";
                                setState((){calculate();});
                              });
                            }),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: amountFieldController,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: "Amount", prefixText: "Rs. "),
                            onChanged: (v){setState((){calculate();});},
                            onFieldSubmitted: (v){setState((){calculate();});},
                          ),
                        ),
                      ),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                        color:
                                        gender == "Male" ? Colors.black : Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(8),
                                      primary:gender != "Male" ? Colors.black : Colors.white),
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
                                        color:
                                        gender == "Female" ? Colors.black : Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(8),
                                      primary:
                                      gender != "Female" ? Colors.black : Colors.white),
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 0, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(onPressed: (){if(selected>0){selected-=1;u['r'] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";setState((){});}}, icon: Icon(CupertinoIcons.left_chevron)),
                                  Text(paymentOptions[selected]),
                                  IconButton(onPressed: (){if(selected<paymentOptions.length-1){selected+=1;u['r'] = "{PAYMENTMODE: Direct, GATEWAYNAME: ${paymentOptions[selected]}, STATUS: Success, RESPMSG: ,}";setState((){});}}, icon: Icon(CupertinoIcons.right_chevron)),
                                ]
                            ),
                            InkWell(
                              onTap: () {
                                setState((){gst = !gst;  calculate();});
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                mainAxisAlignment: MainAxisAlignment.start,
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
                      Text('${gst
                          ? ' (with GST)'
                          : ''} ${static
                          ? ' (static: ${Utils.staticIPPrice * Utils.plans[selected_plan]['m']})'
                          : ''}', style: TextStyle(fontSize: 12,),textAlign: TextAlign.center,),
                  ],
                ),
                    )),
              ),
            ),
            if(loading)
            Center(child: CircularProgressIndicator())
          ],
        ),
      ),
    );
  }

  addUser() async {
    Utils.showLoadingDialog(context, "Creating User");
    var tomorrow = now.add(Duration(days: 1));
    var body = {
      "userName": "${userID}",
      "password": "12345678",
      "userGroupId": "${Utils.plans[selected_plan]['g']}",
      "userPlanId": "${Utils.plans[selected_plan]['p']}",
      "firstName": "${name}",
      "phoneNumber": "${phone}",
      "emailId": "${email}",
      "address_line1": "${address}",
      "additionalField1": "${gender}",
      "circuitId": "${circuitID}",
      "gstApplicableFrom": "${now.year}-${now.month>9?now.month:"0${now.month}"}-${now.day>9?now.day:"0${now.day}"}",
      "customExpirationDate": "${tomorrow.day>9?tomorrow.day:"0${tomorrow.day}"}-${tomorrow.month>9?tomorrow.month:"0${tomorrow.month}"}-${tomorrow.year} ${tomorrow.hour>9?tomorrow.hour:"0${tomorrow.hour}"}:${tomorrow.minute>9?tomorrow.minute:"0${tomorrow.minute}"}:${tomorrow.second>9?tomorrow.second:"0${tomorrow.second}"}",
      "chequeDate": "${now.day>9?now.day:"0${now.day}"}-${now.month>9?now.month:"0${now.month}"}-${now.year}",
      "installation_address_line1": "${address}",
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
    var response = await http.post(
        Utils.ADD_USER,
        body: jsonEncode(body),headers: {'cookie':Utils.cookie, 'authorization': Utils.authorization, "Content-Type": "application/json"});
    var resp = json.decode(response.body);
    // print(resp);
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


      await addUserAuth();

      Navigator.pop(context);
      Navigator.pushReplacement(context, Utils.createRoute(SendOtp(user: {
        "mobile": phone,
        "uid": uid
      },), Utils.RTL));
    } else {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorScreen(error: resp.toString(),html: false,),
          ));
    }
  }

  addUserAuth() async {
    var resp = await http.post(Utils.CREATE_AUTH_USER,
        body: {
          "user_id": userID,
          "password": "${phone}",
          "name": "${name}",
          "uid": "${uid}",
        });
    if (resp.statusCode != 200){
      Utils.showErrorDialog(context ,'Error',
          'Auth Creation of ${u['user_id']} - ${u['name']} was Not Successful\n${jsonDecode(resp.body)['msg']}');
    }
    Utils.netUsers[u['uid']] = {'user_id': u['user_id'],};
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
  
  getCircuitId() async {
    Utils.showLoadingDialog(context, "Getting User ID.");
    await Utils.checkLogin();
    var resp = await http.get(Utils.GET_CIRCUIT_ID,
      headers: Utils.headers,
    );
    var r = jsonDecode(resp.body);
    if (r['status'] == 'success') {
      circuitID = "${r['message']['circuitId']}";
      userIDController.text = "022825${r['message']['circuitId']}";
      u["u_id"] = "022825${r['message']['circuitId']}";
      userID = "022825${r['message']['circuitId']}";
      setState(() {});
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }
  
}
