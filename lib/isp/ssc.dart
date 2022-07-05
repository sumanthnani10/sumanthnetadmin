import 'dart:convert';

import 'package:sumanth_net_admin/isp/jaze_isp.dart';
import 'package:http/http.dart' as http;

class SSCISP extends JazeISP {

  List<int> staticIPs = List<int>.generate(200, (i) => i+3);
  int lastIP = 3;
  String ipPref = "10.10.60.";

  SSCISP() {
    code = "ssc";
    DOMAIN = "https://ssc.kingsbroadband.net";
    ENTITY = "mail1";
    USERNAME = "admin@1";
    PASSWORD = "12356";
    usersCollection = "ssc_users";
    billsCollection = "ssc_pays";
    init();
    /*plans = {
      "15": {
        "g": "31347",
        "p": "272431"
      },
      "20": {
        "g": "31349",
        "p": "272433"
      },
      "30": {
        "g": "26883",
        "p": "243283"
      },
      "50": {
        "g": "26885",
        "p": "243769"
      },
      "75": {
        "g": "26887",
        "p": "243829"
      },
      "100": {
        "g": "26889",
        "p": "243889"
      },
      "150": {
        "g": "26891",
        "p": "243949"
      },
      "200": {
        "g": "26893",
        "p": "244009"
      }
    };*/
  }

  capitalize1st(String string) {
    string = string.toLowerCase();
    string = string.replaceAll("  ", " ");
    string = string.replaceAll(",,", "");
    string = string.trim();
    List<String> split = string.split(" ");
    string = "";
    split.forEach((s) {
      string += s[0].toUpperCase() + s.substring(1) + " ";
    });
    return string.trim();
  }

  formatAddress(String address) {
    address = capitalize1st(address);
    address = address.replaceAll("ptc", "");
    address = address.replaceAll("Shanti", "Shanthi");
    address = address.replaceAll("Jpc", "JP Colony");
    address = address.replaceAll("Abc", "Ambedkar Colony");
    address = address.replaceAll(",", ", ");
    address = address.replaceAll("  ", " ");
    if(!address.contains("Patancheru")) {
      address += ", Patancheru";
    }
    return address;
  }

  getUsers(context) async {
    await super.getUsers(context);
    users.forEach((u) {
      if(u["static_ip"] != null && u["static_ip"] != "") {
        if(u["static_ip"].contains(ipPref)) {
          int ip = int.parse(u["static_ip"].replaceAll(ipPref, ""));
          staticIPs.remove(ip);
        }
      }
    });
    lastIP = staticIPs.first;
  }

  getAddUserBody(user, plan) async {
    DateTime now = DateTime.now();
    String gstApplicableFrom =
        "${now.year}-${now.month > 9 ? "${now.month}" : "0${now.month}"}-${now.day > 9 ? "${now.day}" : "0${now.day}"}";
    String chequeDate =
        "${now.day > 9 ? "${now.day}" : "0${now.day}"}-${now.month > 9 ? "${now.month}" : "0${now.month}"}-${now.year}";
    now = now.add(Duration(days: 1));
    String customExpirationDate =
        "${now.day > 9 ? "${now.day}" : "0${now.day}"}-${now.month > 9 ? "${now.month}" : "0${now.month}"}-${now.year} ${now.hour > 9 ? "${now.hour}" : "0${now.hour}"}:${now.minute > 9 ? "${now.minute}" : "0${now.minute}"}:${now.second > 9 ? "${now.second}" : "0${now.second}"}";
    await getPlanProfileID(plan);
    String circuitID = await getCircuitID();
    Map pland = plans[plan];
    var newUser = {
      "accountId": "$ENTITY",
      "userName": "${user["userName"]}",
      "firstName": "${user["firstName"].trim()}",
      "phoneNumber": "${user["phoneNumber"]}",
      "emailId": "${user["emailId"]}",
      "address_line1": "${formatAddress(user["address_line1"])}",
      "installation_address_line1": "${formatAddress(user["address_line1"])}",
      "userGroupId": "${pland["g"]}",
      "userPlanId": "${pland["p"]}",
      "circuitId": "$circuitID",
      "gstApplicableFrom": "$gstApplicableFrom",
      "customExpirationDate": "$customExpirationDate",
      "chequeDate": "$chequeDate",
      "staticIpAddress[]": "10.10.60.$lastIP",
      "password": "12345678",
      "gender": "none",
      "lastName": "",
      "enterOTPDisplay": "no",
      "tempPhone": "",
      "altPhoneNumber": "",
      "altEmailId": "",
      "address_line2": "",
      "address_city": "hyderabad",
      "address_pin": "502319",
      "address_state": "telangana",
      "address_country": "IN",
      "address": "",
      "data[Document][imagePic]": "(binary)",
      "data[Document][imageSign]": "(binary)",
      "createBilling": "on",
      "installationCharge": "",
      "pageName": "addUsers",
      "depositAmount": "",
      "routerCharge": "",
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
      "data[Document][submittedIdProofBack]": "(binary)",
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
      "userReferralCode": "",
      "notifyUserSms": "yes",
      "notifyUserEmail": "yes",
      "notifyUserWhatsapp": "yes",
      "installation_address_line2": "",
      "installation_address_city": "hyderabad",
      "installation_address_pin": "502319",
      "installation_address_state": "telangana",
      "staticIpBoundMac[]": "",
      "ipMacBillingCharge[]": "",
      "ipMacBillingOverrideEnable[]": "31",
      "ipMacBillingOverrideAmount[]": "",
      "ipMacBillingChargeMethod[]": "",
      "ipMacBillingActiveSince[]": "",
      "ipMacBillingActiveUntil[]": "",
      "ipMacBillingPeriod[]": "",
      "ipMacBillingPeriodType[]": "",
      "ipMacBillingIncludeTax[]": "31",
      "ipoverrideBillingCycleEnable[]": "31",
      "ipoverrideBillingCycleValue[]": "",
      "ipoverrideBillingCycleValueDate[]": "",
      "ipoverrideBillingCycleValueDay[]": "",
      "overrideAmountBasedOn": "withTax",
      "useBillingAddAsInstallationAdd": "on",
      "installation_address_country": "IN",
      "routerChargeMethod": "oneTime",
      "paymentmethod": "cash",
      "bankTransferMethod": "NEFT",
      "userIPTVProfileType": "",
      "userVoiceProfileType": "",
      "userOTTProfileType": ""
    };
    return newUser;
  }

  Future<ISPResponse> shiftUser(user, plan) async {
    try {
      String circuitID = await getCircuitID();
      DateTime now = DateTime.now();
      String gstApplicableFrom =
          "${now.year}-${now.month > 9 ? "${now.month}" : "0${now.month}"}-${now.day > 9 ? "${now.day}" : "0${now.day}"}";
      String chequeDate =
          "${now.day > 9 ? "${now.day}" : "0${now.day}"}-${now.month > 9 ? "${now.month}" : "0${now.month}"}-${now.year}";
      now = now.add(Duration(days: 1));
      String customExpirationDate =
          "${now.day > 9 ? "${now.day}" : "0${now.day}"}-${now.month > 9 ? "${now.month}" : "0${now.month}"}-${now.year} ${now.hour > 9 ? "${now.hour}" : "0${now.hour}"}:${now.minute > 9 ? "${now.minute}" : "0${now.minute}"}:${now.second > 9 ? "${now.second}" : "0${now.second}"}";
      await getPlanProfileID(plan);
      Map pland = plans[plan];
      var newUser = {
        "accountId": "$ENTITY",
        "userName": "${user["user_id"]}",
        "firstName": "${user["name"].trim()}",
        "phoneNumber": "${user["mobile"]}",
        "emailId": "${user["email"]}",
        "address_line1": "${formatAddress(user["address"])}",
        "installation_address_line1": "${formatAddress(user["address"])}",
        "userGroupId": "${pland["g"]}",
        "userPlanId": "${pland["p"]}",
        "circuitId": "$circuitID",
        "gstApplicableFrom": "$gstApplicableFrom",
        "customExpirationDate": "$customExpirationDate",
        "chequeDate": "$chequeDate",
        "staticIpAddress[]": "10.10.60.${lastIP}",
        "password": "12345678",
        "gender": "none",
        "lastName": "",
        "enterOTPDisplay": "no",
        "tempPhone": "",
        "altPhoneNumber": "",
        "altEmailId": "",
        "address_line2": "",
        "address_city": "hyderabad",
        "address_pin": "502319",
        "address_state": "telangana",
        "address_country": "IN",
        "address": "",
        "data[Document][imagePic]": "(binary)",
        "data[Document][imageSign]": "(binary)",
        "createBilling": "on",
        "installationCharge": "",
        "pageName": "addUsers",
        "depositAmount": "",
        "routerCharge": "",
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
        "data[Document][submittedIdProofBack]": "(binary)",
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
        "userReferralCode": "",
        "notifyUserSms": "yes",
        "notifyUserEmail": "yes",
        "notifyUserWhatsapp": "yes",
        "installation_address_line2": "",
        "installation_address_city": "hyderabad",
        "installation_address_pin": "502319",
        "installation_address_state": "telangana",
        "staticIpBoundMac[]": "",
        "ipMacBillingCharge[]": "",
        "ipMacBillingOverrideEnable[]": "31",
        "ipMacBillingOverrideAmount[]": "",
        "ipMacBillingChargeMethod[]": "",
        "ipMacBillingActiveSince[]": "",
        "ipMacBillingActiveUntil[]": "",
        "ipMacBillingPeriod[]": "",
        "ipMacBillingPeriodType[]": "",
        "ipMacBillingIncludeTax[]": "31",
        "ipoverrideBillingCycleEnable[]": "31",
        "ipoverrideBillingCycleValue[]": "",
        "ipoverrideBillingCycleValueDate[]": "",
        "ipoverrideBillingCycleValueDay[]": "",
        "overrideAmountBasedOn": "withTax",
        "useBillingAddAsInstallationAdd": "on",
        "installation_address_country": "IN",
        "routerChargeMethod": "oneTime",
        "paymentmethod": "cash",
        "bankTransferMethod": "NEFT",
        "userIPTVProfileType": "",
        "userVoiceProfileType": "",
        "userOTTProfileType": ""
      };
      var resp =
          await http.post(Uri.parse(ADD_USER), body: newUser, headers: headers);
      var r = jsonDecode(resp.body);
      if (r["status"] == "success") {
        staticIPs.remove(lastIP);
        lastIP = staticIPs.first;
        return ISPResponse(true, "User shifted successfully.", newUser);
      } else {
        print("ERROR: ${r["message"]}");
        return ISPResponse(false, "User shifting unsuccessful.", r);
      }
    } catch (e) {
      print("ERROR: $e");
      return ISPResponse(false, "ERROR: $e");
    }
  }

  @override
  getRenewBody(user, plan) async {
    Map<String, String> body = await super.getRenewBody(user, plan);
    body.addAll({
      "accountIdsSelected" : "mail1",
      "optionType" : "selected",
      "pinId" : "",
      "multipleacc" : "undefined",
      "ottBillingType" : "single",
      "data[Document][uploadimg]" : "",
      "voicePlanId" : "presentPlan",
      "paymentTypeVal3" : "",
      "paymentType" : "none",
      "iptvProfileId" : "presentPackage",
      "applyCoupon" : "false",
      "paymentTypeVal1" : "",
      "ottProfileId" : "presentPackage",
      "couponCode" : "",
      "voiceBillingType" : "single",
      "iptvBillingType" : "single",
      "voiceChangePackRenew" : "false",
      "ottPlanId" : "presentPlan",
      "havePin" : "false",
      "iptvPlanId" : "presentPlan",
      "iptvProfileType" : "",
      "ottProfileType" : "",
      "voiceProfileType" : "",
      "pinPassword" : "",
      "voiceProfileId" : "presentPackage",
      "paymentTypeVal2" : "",
      "ottChangePackRenew" : "false",
      "iptvChangePackRenew" : "false"
    });
    return body;
  }

}