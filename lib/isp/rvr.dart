import 'package:sumanth_net_admin/isp/jaze_isp.dart';

class RVRISP extends JazeISP {

  RVRISP() {
    code = "rvr";
    DOMAIN = "https://service.rvrnet.com";
    ENTITY = "022825sumanthanetworks";
    USERNAME = "022825";
    PASSWORD = "bssss888";
    usersCollection = "rvr_users";
    billsCollection = "rvr_pay";
    init();
  }

  @override
  getAddUserBody(user, plan) async {
    String circuitID = await getCircuitID();
    DateTime now = DateTime.now();
    var tomorrow = now.add(Duration(days: 1));
    return {
      "userName": "${user["userID"]}",
      "password": "12345678",
      "userGroupId": "${plans[plan].groupID}",
      "userPlanId": "${plans[plan].profileID}",
      "firstName": "${user["name"]}",
      "phoneNumber": "${user["phone"]}",
      "emailId": "${user["email"]}",
      "address_line1": "${user["address"]}",
      "additionalField1": "${user["gender"]}",
      "circuitId": "$circuitID",
      "gstApplicableFrom": "${now.year}-${now.month>9?now.month:"0${now.month}"}-${now.day>9?now.day:"0${now.day}"}",
      "customExpirationDate": "${tomorrow.day>9?tomorrow.day:"0${tomorrow.day}"}-${tomorrow.month>9?tomorrow.month:"0${tomorrow.month}"}-${tomorrow.year} ${tomorrow.hour>9?tomorrow.hour:"0${tomorrow.hour}"}:${tomorrow.minute>9?tomorrow.minute:"0${tomorrow.minute}"}:${tomorrow.second>9?tomorrow.second:"0${tomorrow.second}"}",
      "chequeDate": "${now.day>9?now.day:"0${now.day}"}-${now.month>9?now.month:"0${now.month}"}-${now.year}",
      "installation_address_line1": "${user["address"]}",
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
  }

}
