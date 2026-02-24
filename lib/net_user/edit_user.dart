import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sumanth_net_admin/error_screen.dart';
import 'package:sumanth_net_admin/isp/jaze_isp.dart';

import '../utils.dart';

class EditUser extends StatefulWidget {

  final user,uid;

  const EditUser({Key key, this.user, this.uid}) : super(key: key);

  @override
  _EditUserState createState() => _EditUserState(this.user);
}

class _EditUserState extends State<EditUser> {

  final user;
  GlobalKey<FormState> form_key = new GlobalKey<FormState>();

  bool loading = false;

  _EditUserState(this.user);

  TextEditingController nameC,mobileC,emailC,addressC, ipC;
  bool staticIP = false;
  

  @override
  void initState() {
    super.initState();
    nameC = new TextEditingController(text: user['name']);
    mobileC = new TextEditingController(text: user['mobile']);
    emailC = new TextEditingController(text: user['email']);
    addressC = new TextEditingController(text: user['address']);
    ipC = new TextEditingController(text: user['static_ip']);
    staticIP = user['static_ip']!="";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            title: Text(
              'Edit User',
              style: TextStyle(
                  color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            actions: <Widget>[
              TextButton(
                  onPressed: () async {
                    editUser();
                  },
                  child: Text(
                    'Edit',
                    style: TextStyle(color: Colors.blue),
                  ))
            ],
          ),
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: form_key,
                    child: Column(
                      children: <Widget>[
                        Center(child: Text(user['user_id'],style: TextStyle(fontSize: 24),)),
                        SizedBox(height: 8,),
                        TextFormField(
                          controller: nameC,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          maxLength: 30,
                          onEditingComplete: (){
                            FocusScope.of(context).unfocus();
                            FocusScope.of(context).nextFocus();
                          },
                          textCapitalization: TextCapitalization.words,
                          inputFormatters:  [
                            // FilteringTextInputFormatter.allow(RegExp('[a-zA-Z .]')),
                            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z .]')),
                          ],
                          validator: (v){
                            if(v.isEmpty){
                              return 'Cannot be empty';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.black)),
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: const EdgeInsets.all(8),
                              labelText: 'First Name',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.black)),
                              fillColor: Colors.white),
                        ),
                        SizedBox(height: 8,),
                        TextFormField(
                          controller: emailC,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          textCapitalization: TextCapitalization.none,
                          inputFormatters:  [
                            FilteringTextInputFormatter.allow(RegExp('[a-zA-z0-9@._-]')),
                          ],
                          onEditingComplete: (){
                            FocusScope.of(context).unfocus();
                            FocusScope.of(context).nextFocus();
                          },validator: (v){
                            Pattern pattern =
                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                            RegExp regex = new RegExp(pattern);
                            if(v.isEmpty){
                              return 'Cannot be empty';
                            }
                            else{
                              if (!regex.hasMatch(v)) {
                                return 'Enter valid email';
                              } else {
                                return null;
                              }
                            }
                          },
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.black)),
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: const EdgeInsets.all(8),
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.black)),
                              fillColor: Colors.white),
                        ),
                        SizedBox(height: 24,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(child: TextFormField(
                              controller: mobileC,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              maxLength: 10,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters:  [
                                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                              ],
                              onEditingComplete: (){
                                FocusScope.of(context).unfocus();
                                FocusScope.of(context).nextFocus();
                              },validator: (v){
                              if(v.isEmpty){
                                return 'Cannot be empty';
                              }
                              if(v.length<10){
                                return 'Must be 10 digits';
                              }
                              return null;
                            },
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.black)),
                                  labelStyle: TextStyle(color: Colors.black),
                                  contentPadding: const EdgeInsets.all(8),
                                  labelText: 'Mobile',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.black)),
                                  fillColor: Colors.white),
                            )),
                            SizedBox(width: 8),
                            Flexible(
                              child: TextFormField(
                                controller: ipC,
                                textInputAction: TextInputAction.next,
                                maxLines: null,
                                enableSuggestions: true,
                                keyboardType: TextInputType.number,
                                onEditingComplete: (){
                                  FocusScope.of(context).unfocus();
                                  FocusScope.of(context).nextFocus();
                                },validator: (v){
                                  if(v.isEmpty){
                                    return 'Cannot be empty';
                                  }else {
                                      return null;
                                  }
                                },
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.black)),
                                    labelStyle: TextStyle(color: Colors.black),
                                    contentPadding: const EdgeInsets.all(8),
                                    labelText: 'IP',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.black)),
                                    fillColor: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8,),
                        TextFormField(
                          controller: addressC,
                          textInputAction: TextInputAction.done,
                          maxLines: null,
                          enableSuggestions: true,
                          maxLength: 50,
                          textCapitalization: TextCapitalization.words,
                          onEditingComplete: (){
                            FocusScope.of(context).unfocus();
                          },validator: (v){
                            if(v.isEmpty){
                              return 'Cannot be empty';
                            }else {
                                return null;
                            }
                          },
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.black)),
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: const EdgeInsets.all(8),
                              labelText: 'Address',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.black)),
                              fillColor: Colors.white),
                        ),
                        SizedBox(height: 8,),
                        Row(
                          children: [
                            Text("Static IP: "),
                            Switch.adaptive(value: staticIP, onChanged: (v) async {
                              Utils.showLoadingDialog(context, "Loading");
                              await FirebaseFirestore.instance.collection(Utils.isp.usersCollection).doc("${user['uid']}").update({
                                "static_ip": v
                              }).then((value) {
                                staticIP = v;
                                Utils.isp.netUsers[user["uid"]]["static_ip"] = v;
                              }).catchError((e){
                                print("ERROR: $e");
                              });
                              setState(() {});
                              Navigator.pop(context);
                            })
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if(loading)
              Center(child: CircularProgressIndicator())
            ],
          ),
        ),
      ),
    );
  }

  editUser() async {
    if(form_key.currentState.validate()){
      setState(() {
        loading=true;
      });
      Utils.showLoadingDialog(context, "Editing..");
      ISPResponse ispResponse = await Utils.isp.editUser(user, nameC.text, mobileC.text, emailC.text, addressC.text, ipC.text);
      setState(() {
        loading=false;
      });
      Navigator.pop(context);
      if(ispResponse.success) {
        await Utils.showADialog(context, "Done", "${ispResponse.message}");
        Navigator.pop(context);
      } else {
        await Navigator.push(context, Utils.createRoute(ErrorScreen(ispResponse: ispResponse),Utils.LTR));
        Navigator.pop(context);
      }
    }
  }

  /*editUser()async{
    if(form_key.currentState.validate()){
      setState(() {
        loading=true;
      });
      await Utils.checkLogin();
      var r = await http.post(Utils.EDIT_USER,headers: Utils.headers,
          body: {
            "userId": user['uid'],
            "account": "022825sumanthanetworks",
            "userName": user['user_id'],
            "password": "",
            "userGroupId": "${Utils.plans[user['plan']]['g']}",
            "userPlanId": "${Utils.plans[user['plan']]['p']}",
            "overrideAmount": "",
            "overrideAmountBasedOn": "withTax",
            "firstName": nameController.text,
            "lastName": lastNameController.text,
            "phoneNumber": mobileController.text,
            "enterOTPDisplay": "yes",
            "tempPhone": "",
            "altPhoneNumber": "",
            "emailId": emailController.text,
            "altEmailId": "",
            "address_line1": addressController.text,
            "address_line2": "Ptc",
            "address_city": "Hyderabad",
            "address_pin": "502319",
            "address_state": "Telangana",
            "address_country": "IN",
            "address": "",
            "installation_address_line1": "",
            "installation_address_line2": "",
            "installation_address_city": "",
            "installation_address_pin": "",
            "installation_address_state": "",
            "installation_address_country": "IN",
            "installationCharge": "",
            "installationChargeOverrideAmount": "",
            "depositAmount": "",
            "routerCharge": "",
            "routerChargeOverrideAmount": "",
            "routerChargeMethod": "oneTime",
            "userIPTVPlanId": "",
            "userIPPhonePlanId": "",
            "afterAction": "suspend",
            "gstNumber": "",
            "gstApplicableFrom": "",
            "userType": "home",
            "circuitId": user['circuit_id'],
            "collection_area_import": "",
            "collection_street_import": "",
            "collection_block_import": "",
            "collection_latitude_import": "",
            "collection_longitude_import": "",
            "location_details_not_import": "yes",
            "id_proof": "",
            "id_pin": "",
            "DocumentSubmittedIdProofUploadedValue": "",
            "installationTime": "${user['installation_time']} 00:00:00",
            "DocumentSubmittedProofUploadedValue": "",
            "caf_num": "",
            "DocumentSubmittedFormUploadedValue": "",
            "DocumentSubmittedReportUploadedValue": "",
            "mac": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": user['binded_mac'],
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "staticIpAddress[]": "",
            "staticIpBoundMac[]": "",
            "ipPoolName": "",
            "activationDate": "custom",
            "customActivationDate": "${user['activation_date'].replaceAll('/', '-')} 00:00:00",
            "expirationDate": "custom",
            "customExpirationDate": "${user['expiry_date'].replaceAll('/', '-')} 10:00:00",
            "userState": "unblock",
            "comments": "",
            "generateRandomPasswordComplexity": "n",
            "generateRandomPasswordLength": "4",
            "generateRandomUsernameComplexity": "n",
            "generateRandomUsernameLength": "8"
          });
      setState(() {
        loading=false;
      });
      if(jsonDecode(r.body)['status']=='success'){
        Navigator.pop(context);
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (context) => ErrorScreen(error: r.body,html: false,),));
      }
    }
  }*/
}
