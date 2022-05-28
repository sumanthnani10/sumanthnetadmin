import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Utils{
  static List<dynamic> users = [];
  static Map<String,dynamic> usersMap = {};
  static List<Map> cablePayments = [];
  static List<dynamic> netPayments = [];
  static Map<String,dynamic> netUsers = {};
  static Map<String,String> headers = {};
  static Map<String,dynamic> plans = {};
  static List<dynamic> coupons = [];
  static String cookie = '';
  static String authorization = '';
  static int staticIPPrice = 300;
  static Map<String, int> usersCatCount = {
    'Active': 0,
    'Online': 0,
    'Not Online': 0,
    'Expired': 0,
    'All': 0,
  };

  static const Offset RTL = Offset(1, 0);
  static const Offset LTR = Offset(-1, 0);
  static const Offset UTD = Offset(0, -1);
  static const Offset DTU = Offset(0, 1);


  static final String DOMAIN = "service.rvrnet.com";
  static Uri LOGIN = Uri.https('${DOMAIN}','/backend/login/login_post');
  static Uri LOGOUT = Uri.https('${DOMAIN}','/backend/login/logout');
  static Uri RESET_PASSWORD = Uri.https('${DOMAIN}','/backend/users/reset_user_password.json');
  static Uri CHANGE_EMAIL = Uri.https('${DOMAIN}','/backend/users/edit_user_mobile_email');
  static Uri USERS_COUNT = Uri.https('${DOMAIN}','/backend/dashboard/set_users_count/all/usersCount');
  static Uri ACTIVE_SESSIONS = Uri.https('${DOMAIN}','/backend/monitoring/active_sessions_data/both/null/null/null/all/activeSessions/true/50/1/null/start_time');
  static Uri REMOVE_SESSION = Uri.https('${DOMAIN}','/backend/monitoring/terminate_session');
  static Uri GET_CIRCUIT_ID = Uri.https('${DOMAIN}','/backend/users/add/0/true');
  static Uri ADD_USER = Uri.https('${DOMAIN}','/backend/users/add');
  static Uri EDIT_USER = Uri.https('${DOMAIN}','/backend/users/edit.json');
  static Uri RENEW_USER = Uri.https('${DOMAIN}','/backend/billing/renew_user');
  static Uri SEND_OTP = Uri.https('${DOMAIN}','/backend/users/send_mobile_otp_user');
  static Uri VERIFY_OTP = Uri.https('${DOMAIN}','/backend/users/submit_mobile_otp_user');
  static Uri LOGIN_API = Uri.https('us-central1-sumanthnet-13082020.cloudfunctions.net','/paysApp/login');
  static Uri CREATE_AUTH_USER = Uri.https('us-central1-sumanthnet-13082020.cloudfunctions.net','/paysApp/createUserAuth');
  static Uri UPDATE_AUTH_USER = Uri.https('us-central1-sumanthnet-13082020.cloudfunctions.net','/paysApp/updateUserAuth');
  static Uri GET_USERS = Uri.https('${DOMAIN}','/backend/users/get_all_data/all/all/',{
    "sEcho":"1",
    "iColumns":"58",
    "sColumns":",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
    "iDisplayStart":"0",
    "iDisplayLength":"400",
    "mDataProp_0":"id",
    "sSearch_0":"",
    "bRegex_0":"false",
    "bSearchable_0":"true",
    "bSortable_0":"false",
    "mDataProp_1":"user_id",
    "sSearch_1":"",
    "bRegex_1":"false",
    "bSearchable_1":"true",
    "bSortable_1":"true",
    "mDataProp_2":"username",
    "sSearch_2":"",
    "bRegex_2":"false",
    "bSearchable_2":"true",
    "bSortable_2":"true",
    "mDataProp_3":"circuit_id",
    "sSearch_3":"",
    "bRegex_3":"false",
    "bSearchable_3":"true",
    "bSortable_3":"true",
    "mDataProp_4":"status",
    "sSearch_4":"",
    "bRegex_4":"false",
    "bSearchable_4":"true",
    "bSortable_4":"true",
    "mDataProp_5":"suspended_time",
    "sSearch_5":"",
    "bRegex_5":"false",
    "bSearchable_5":"true",
    "bSortable_5":"true",
    "mDataProp_6":"Actions",
    "sSearch_6":"",
    "bRegex_6":"false",
    "bSearchable_6":"true",
    "bSortable_6":"false",
    "mDataProp_7":"name",
    "sSearch_7":"",
    "bRegex_7":"false",
    "bSearchable_7":"true",
    "bSortable_7":"true",
    "mDataProp_8":"last_name",
    "sSearch_8":"",
    "bRegex_8":"false",
    "bSearchable_8":"true",
    "bSortable_8":"true",
    "mDataProp_9":"phone",
    "sSearch_9":"",
    "bRegex_9":"false",
    "bSearchable_9":"true",
    "bSortable_9":"true",
    "mDataProp_10":"alt_phone",
    "sSearch_10":"",
    "bRegex_10":"false",
    "bSearchable_10":"true",
    "bSortable_10":"true",
    "mDataProp_11":"email",
    "sSearch_11":"",
    "bRegex_11":"false",
    "bSearchable_11":"true",
    "bSortable_11":"true",
    "mDataProp_12":"activation_time",
    "sSearch_12":"",
    "bRegex_12":"false",
    "bSearchable_12":"true",
    "bSortable_12":"true",
    "mDataProp_13":"created",
    "sSearch_13":"",
    "bRegex_13":"false",
    "bSearchable_13":"true",
    "bSortable_13":"true",
    "mDataProp_14":"expiration_time",
    "sSearch_14":"",
    "bRegex_14":"false",
    "bSearchable_14":"true",
    "bSortable_14":"true",
    "mDataProp_15":"installation_time",
    "sSearch_15":"",
    "bRegex_15":"false",
    "bSearchable_15":"true",
    "bSortable_15":"true",
    "mDataProp_16":"staticipmac",
    "sSearch_16":"",
    "bRegex_16":"false",
    "bSearchable_16":"true",
    "bSortable_16":"false",
    "mDataProp_17":"userNasPortId",
    "sSearch_17":"",
    "bRegex_17":"false",
    "bSearchable_17":"true",
    "bSortable_17":"true",
    "mDataProp_18":"balance",
    "sSearch_18":"",
    "bRegex_18":"false",
    "bSearchable_18":"true",
    "bSortable_18":"true",
    "mDataProp_19":"due",
    "sSearch_19":"",
    "bRegex_19":"false",
    "bSearchable_19":"true",
    "bSortable_19":"true",
    "mDataProp_20":"deposit",
    "sSearch_20":"",
    "bRegex_20":"false",
    "bSearchable_20":"true",
    "bSortable_20":"true",
    "mDataProp_21":"gstnumber",
    "sSearch_21":"",
    "bRegex_21":"false",
    "bSearchable_21":"true",
    "bSortable_21":"true",
    "mDataProp_22":"group",
    "sSearch_22":"",
    "bRegex_22":"false",
    "bSearchable_22":"true",
    "bSortable_22":"true",
    "mDataProp_23":"company_name",
    "sSearch_23":"",
    "bRegex_23":"false",
    "bSearchable_23":"true",
    "bSortable_23":"true",
    "mDataProp_24":"address",
    "sSearch_24":"",
    "bRegex_24":"false",
    "bSearchable_24":"true",
    "bSortable_24":"true",
    "mDataProp_25":"address_line1",
    "sSearch_25":"",
    "bRegex_25":"false",
    "bSearchable_25":"true",
    "bSortable_25":"true",
    "mDataProp_26":"address_line2",
    "sSearch_26":"",
    "bRegex_26":"false",
    "bSearchable_26":"true",
    "bSortable_26":"true",
    "mDataProp_27":"address_city",
    "sSearch_27":"",
    "bRegex_27":"false",
    "bSearchable_27":"true",
    "bSortable_27":"true",
    "mDataProp_28":"address_pin",
    "sSearch_28":"",
    "bRegex_28":"false",
    "bSearchable_28":"true",
    "bSortable_28":"true",
    "mDataProp_29":"address_state",
    "sSearch_29":"",
    "bRegex_29":"false",
    "bSearchable_29":"true",
    "bSortable_29":"true",
    "mDataProp_30":"userarea",
    "sSearch_30":"",
    "bRegex_30":"false",
    "bSearchable_30":"true",
    "bSortable_30":"true",
    "mDataProp_31":"userstreet",
    "sSearch_31":"",
    "bRegex_31":"false",
    "bSearchable_31":"true",
    "bSortable_31":"true",
    "mDataProp_32":"userblock",
    "sSearch_32":"",
    "bRegex_32":"false",
    "bSearchable_32":"true",
    "bSortable_32":"true",
    "mDataProp_33":"userlatitude",
    "sSearch_33":"",
    "bRegex_33":"false",
    "bSearchable_33":"true",
    "bSortable_33":"true",
    "mDataProp_34":"userlongitude",
    "sSearch_34":"",
    "bRegex_34":"false",
    "bSearchable_34":"true",
    "bSortable_34":"true",
    "mDataProp_35":"type",
    "sSearch_35":"",
    "bRegex_35":"false",
    "bSearchable_35":"true",
    "bSortable_35":"true",
    "mDataProp_36":"comments",
    "sSearch_36":"",
    "bRegex_36":"false",
    "bSearchable_36":"true",
    "bSortable_36":"true",
    "mDataProp_37":"",
    "sSearch_37":"",
    "bRegex_37":"false",
    "bSearchable_37":"true",
    "bSortable_37":"true",
    "mDataProp_38":"",
    "sSearch_38":"",
    "bRegex_38":"false",
    "bSearchable_38":"true",
    "bSortable_38":"true",
    "mDataProp_39":"",
    "sSearch_39":"",
    "bRegex_39":"false",
    "bSearchable_39":"true",
    "bSortable_39":"true",
    "mDataProp_40":"",
    "sSearch_40":"",
    "bRegex_40":"false",
    "bSearchable_40":"true",
    "bSortable_40":"true",
    "mDataProp_41":"",
    "sSearch_41":"",
    "bRegex_41":"false",
    "bSearchable_41":"true",
    "bSortable_41":"true",
    "mDataProp_42":"",
    "sSearch_42":"",
    "bRegex_42":"false",
    "bSearchable_42":"true",
    "bSortable_42":"true",
    "mDataProp_43":"",
    "sSearch_43":"",
    "bRegex_43":"false",
    "bSearchable_43":"true",
    "bSortable_43":"true",
    "mDataProp_44":"",
    "sSearch_44":"",
    "bRegex_44":"false",
    "bSearchable_44":"true",
    "bSortable_44":"true",
    "mDataProp_45":"",
    "sSearch_45":"",
    "bRegex_45":"false",
    "bSearchable_45":"true",
    "bSortable_45":"true",
    "mDataProp_46":"",
    "sSearch_46":"",
    "bRegex_46":"false",
    "bSearchable_46":"true",
    "bSortable_46":"true",
    "mDataProp_47":"",
    "sSearch_47":"",
    "bRegex_47":"false",
    "bSearchable_47":"true",
    "bSortable_47":"true",
    "mDataProp_48":"",
    "sSearch_48":"",
    "bRegex_48":"false",
    "bSearchable_48":"true",
    "bSortable_48":"true",
    "mDataProp_49":"",
    "sSearch_49":"",
    "bRegex_49":"false",
    "bSearchable_49":"true",
    "bSortable_49":"true",
    "mDataProp_50":"",
    "sSearch_50":"",
    "bRegex_50":"false",
    "bSearchable_50":"true",
    "bSortable_50":"true",
    "mDataProp_51":"",
    "sSearch_51":"",
    "bRegex_51":"false",
    "bSearchable_51":"true",
    "bSortable_51":"true",
    "mDataProp_52":"",
    "sSearch_52":"",
    "bRegex_52":"false",
    "bSearchable_52":"true",
    "bSortable_52":"true",
    "mDataProp_53":"",
    "sSearch_53":"",
    "bRegex_53":"false",
    "bSearchable_53":"true",
    "bSortable_53":"true",
    "mDataProp_54":"",
    "sSearch_54":"",
    "bRegex_54":"false",
    "bSearchable_54":"true",
    "bSortable_54":"true",
    "mDataProp_55":"",
    "sSearch_55":"",
    "bRegex_55":"false",
    "bSearchable_55":"true",
    "bSortable_55":"true",
    "mDataProp_56":"",
    "sSearch_56":"",
    "bRegex_56":"false",
    "bSearchable_56":"true",
    "bSortable_56":"true",
    "mDataProp_57":"details",
    "sSearch_57":"",
    "bRegex_57":"false",
    "bSearchable_57":"true",
    "bSortable_57":"false",
    "sSearch":"",
    "bRegex":"false",
    "iSortCol_0":"2",
    "sSortDir_0":"asc",
    "iSortingCols":"1",
    "_":"1601192604982"
  });

  static String generateId(String pref) {
    var chars =
        'zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210';
    int charLength = chars.length;
    var t = DateTime.now();
    String id = pref;
    // id += chars[(t.year / 100).round()];
    id += chars[t.year % charLength];
    id += chars[t.month];
    id += chars[t.day];
    id += chars[t.hour];
    id += chars[t.minute];
    id += chars[t.second];
    id += chars[t.millisecond % charLength];
    id += chars[t.microsecond % charLength];
    return id;
  }

  static Route createRoute(dest, Offset dir) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) => dest,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = dir;
        var end = Offset.zero;
        var curve = Curves.fastOutSlowIn;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static String notif_token;

  static Uri getUserLogsByUIDLink(String uid){
    return Uri.https('service.rvrnet.com','/backend/users/user_logs_data/$uid/022825sumanthanetworks',{
      "sEcho":"1",
      "iColumns":"7",
      "sColumns":",,,,,,",
      "iDisplayStart":"0",
      "iDisplayLength":"50",
      "mDataProp_0":"created",
      "sSearch_0":"",
      "bRegex_0":"false",
      "bSearchable_0":"true",
      "bSortable_0":"true",
      "mDataProp_1":"ip_addr",
      "sSearch_1":"",
      "bRegex_1":"false",
      "bSearchable_1":"true",
      "bSortable_1":"true",
      "mDataProp_2":"mac",
      "sSearch_2":"",
      "bRegex_2":"false",
      "bSearchable_2":"true",
      "bSortable_2":"true",
      "mDataProp_3":"mac_vendor",
      "sSearch_3":"",
      "bRegex_3":"false",
      "bSearchable_3":"true",
      "bSortable_3":"true",
      "mDataProp_4":"password",
      "sSearch_4":"",
      "bRegex_4":"false",
      "bSearchable_4":"true",
      "bSortable_4":"true",
      "mDataProp_5":"ap_mac",
      "sSearch_5":"",
      "bRegex_5":"false",
      "bSearchable_5":"true",
      "bSortable_5":"true",
      "mDataProp_6":"message",
      "sSearch_6":"",
      "bRegex_6":"false",
      "bSearchable_6":"true",
      "bSortable_6":"true",
      "sSearch":"",
      "bRegex":"false",
      "iSortCol_0":"0",
      "sSortDir_0":"desc",
      "iSortingCols":"1",
      "_":"1601297445110"
    });
  }

  static Uri getUserBillsByUIDLink(String uid){
    // return Uri.https('service.rvrnet.com','/backend/users/get_all_user_invoices/022825sumanthanetworks/all/null/null/$uid/true/50/1/null/created desc');
    return Uri.https('service.rvrnet.com','/backend/users/franchiseStatementData/$uid/022825sumanthanetworks/null/null/true/50/1/null/created desc');
  }

  static Uri getUserSessionsByUIDLink(String uid){
    return Uri.https('service.rvrnet.com','/backend/users/session_data/$uid/022825sumanthanetworks');
  }

  static Uri getUserByUIDLink(String uid){
    return Uri.https('${DOMAIN}','/backend/users/get_all_data/all/all/',{
    "sEcho":"1",
    "iColumns":"58",
    "sColumns":",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
    "iDisplayStart":"0",
    "iDisplayLength":"400",
    "mDataProp_0":"id",
    "sSearch_0":"",
    "bRegex_0":"false",
    "bSearchable_0":"true",
    "bSortable_0":"false",
    "mDataProp_1":"user_id",
    "sSearch_1":"${uid}",
    "bRegex_1":"false",
    "bSearchable_1":"true",
    "bSortable_1":"true",
    "mDataProp_2":"username",
    "sSearch_2":"",
    "bRegex_2":"false",
    "bSearchable_2":"true",
    "bSortable_2":"true",
    "mDataProp_3":"circuit_id",
    "sSearch_3":"",
    "bRegex_3":"false",
    "bSearchable_3":"true",
    "bSortable_3":"true",
    "mDataProp_4":"status",
    "sSearch_4":"",
    "bRegex_4":"false",
    "bSearchable_4":"true",
    "bSortable_4":"true",
    "mDataProp_5":"suspended_time",
    "sSearch_5":"",
    "bRegex_5":"false",
    "bSearchable_5":"true",
    "bSortable_5":"true",
    "mDataProp_6":"Actions",
    "sSearch_6":"",
    "bRegex_6":"false",
    "bSearchable_6":"true",
    "bSortable_6":"false",
    "mDataProp_7":"name",
    "sSearch_7":"",
    "bRegex_7":"false",
    "bSearchable_7":"true",
    "bSortable_7":"true",
    "mDataProp_8":"last_name",
    "sSearch_8":"",
    "bRegex_8":"false",
    "bSearchable_8":"true",
    "bSortable_8":"true",
    "mDataProp_9":"phone",
    "sSearch_9":"",
    "bRegex_9":"false",
    "bSearchable_9":"true",
    "bSortable_9":"true",
    "mDataProp_10":"alt_phone",
    "sSearch_10":"",
    "bRegex_10":"false",
    "bSearchable_10":"true",
    "bSortable_10":"true",
    "mDataProp_11":"email",
    "sSearch_11":"",
    "bRegex_11":"false",
    "bSearchable_11":"true",
    "bSortable_11":"true",
    "mDataProp_12":"activation_time",
    "sSearch_12":"",
    "bRegex_12":"false",
    "bSearchable_12":"true",
    "bSortable_12":"true",
    "mDataProp_13":"created",
    "sSearch_13":"",
    "bRegex_13":"false",
    "bSearchable_13":"true",
    "bSortable_13":"true",
    "mDataProp_14":"expiration_time",
    "sSearch_14":"",
    "bRegex_14":"false",
    "bSearchable_14":"true",
    "bSortable_14":"true",
    "mDataProp_15":"installation_time",
    "sSearch_15":"",
    "bRegex_15":"false",
    "bSearchable_15":"true",
    "bSortable_15":"true",
    "mDataProp_16":"staticipmac",
    "sSearch_16":"",
    "bRegex_16":"false",
    "bSearchable_16":"true",
    "bSortable_16":"false",
    "mDataProp_17":"userNasPortId",
    "sSearch_17":"",
    "bRegex_17":"false",
    "bSearchable_17":"true",
    "bSortable_17":"true",
    "mDataProp_18":"balance",
    "sSearch_18":"",
    "bRegex_18":"false",
    "bSearchable_18":"true",
    "bSortable_18":"true",
    "mDataProp_19":"due",
    "sSearch_19":"",
    "bRegex_19":"false",
    "bSearchable_19":"true",
    "bSortable_19":"true",
    "mDataProp_20":"deposit",
    "sSearch_20":"",
    "bRegex_20":"false",
    "bSearchable_20":"true",
    "bSortable_20":"true",
    "mDataProp_21":"gstnumber",
    "sSearch_21":"",
    "bRegex_21":"false",
    "bSearchable_21":"true",
    "bSortable_21":"true",
    "mDataProp_22":"group",
    "sSearch_22":"",
    "bRegex_22":"false",
    "bSearchable_22":"true",
    "bSortable_22":"true",
    "mDataProp_23":"company_name",
    "sSearch_23":"",
    "bRegex_23":"false",
    "bSearchable_23":"true",
    "bSortable_23":"true",
    "mDataProp_24":"address",
    "sSearch_24":"",
    "bRegex_24":"false",
    "bSearchable_24":"true",
    "bSortable_24":"true",
    "mDataProp_25":"address_line1",
    "sSearch_25":"",
    "bRegex_25":"false",
    "bSearchable_25":"true",
    "bSortable_25":"true",
    "mDataProp_26":"address_line2",
    "sSearch_26":"",
    "bRegex_26":"false",
    "bSearchable_26":"true",
    "bSortable_26":"true",
    "mDataProp_27":"address_city",
    "sSearch_27":"",
    "bRegex_27":"false",
    "bSearchable_27":"true",
    "bSortable_27":"true",
    "mDataProp_28":"address_pin",
    "sSearch_28":"",
    "bRegex_28":"false",
    "bSearchable_28":"true",
    "bSortable_28":"true",
    "mDataProp_29":"address_state",
    "sSearch_29":"",
    "bRegex_29":"false",
    "bSearchable_29":"true",
    "bSortable_29":"true",
    "mDataProp_30":"userarea",
    "sSearch_30":"",
    "bRegex_30":"false",
    "bSearchable_30":"true",
    "bSortable_30":"true",
    "mDataProp_31":"userstreet",
    "sSearch_31":"",
    "bRegex_31":"false",
    "bSearchable_31":"true",
    "bSortable_31":"true",
    "mDataProp_32":"userblock",
    "sSearch_32":"",
    "bRegex_32":"false",
    "bSearchable_32":"true",
    "bSortable_32":"true",
    "mDataProp_33":"userlatitude",
    "sSearch_33":"",
    "bRegex_33":"false",
    "bSearchable_33":"true",
    "bSortable_33":"true",
    "mDataProp_34":"userlongitude",
    "sSearch_34":"",
    "bRegex_34":"false",
    "bSearchable_34":"true",
    "bSortable_34":"true",
    "mDataProp_35":"type",
    "sSearch_35":"",
    "bRegex_35":"false",
    "bSearchable_35":"true",
    "bSortable_35":"true",
    "mDataProp_36":"comments",
    "sSearch_36":"",
    "bRegex_36":"false",
    "bSearchable_36":"true",
    "bSortable_36":"true",
    "mDataProp_37":"",
    "sSearch_37":"",
    "bRegex_37":"false",
    "bSearchable_37":"true",
    "bSortable_37":"true",
    "mDataProp_38":"",
    "sSearch_38":"",
    "bRegex_38":"false",
    "bSearchable_38":"true",
    "bSortable_38":"true",
    "mDataProp_39":"",
    "sSearch_39":"",
    "bRegex_39":"false",
    "bSearchable_39":"true",
    "bSortable_39":"true",
    "mDataProp_40":"",
    "sSearch_40":"",
    "bRegex_40":"false",
    "bSearchable_40":"true",
    "bSortable_40":"true",
    "mDataProp_41":"",
    "sSearch_41":"",
    "bRegex_41":"false",
    "bSearchable_41":"true",
    "bSortable_41":"true",
    "mDataProp_42":"",
    "sSearch_42":"",
    "bRegex_42":"false",
    "bSearchable_42":"true",
    "bSortable_42":"true",
    "mDataProp_43":"",
    "sSearch_43":"",
    "bRegex_43":"false",
    "bSearchable_43":"true",
    "bSortable_43":"true",
    "mDataProp_44":"",
    "sSearch_44":"",
    "bRegex_44":"false",
    "bSearchable_44":"true",
    "bSortable_44":"true",
    "mDataProp_45":"",
    "sSearch_45":"",
    "bRegex_45":"false",
    "bSearchable_45":"true",
    "bSortable_45":"true",
    "mDataProp_46":"",
    "sSearch_46":"",
    "bRegex_46":"false",
    "bSearchable_46":"true",
    "bSortable_46":"true",
    "mDataProp_47":"",
    "sSearch_47":"",
    "bRegex_47":"false",
    "bSearchable_47":"true",
    "bSortable_47":"true",
    "mDataProp_48":"",
    "sSearch_48":"",
    "bRegex_48":"false",
    "bSearchable_48":"true",
    "bSortable_48":"true",
    "mDataProp_49":"",
    "sSearch_49":"",
    "bRegex_49":"false",
    "bSearchable_49":"true",
    "bSortable_49":"true",
    "mDataProp_50":"",
    "sSearch_50":"",
    "bRegex_50":"false",
    "bSearchable_50":"true",
    "bSortable_50":"true",
    "mDataProp_51":"",
    "sSearch_51":"",
    "bRegex_51":"false",
    "bSearchable_51":"true",
    "bSortable_51":"true",
    "mDataProp_52":"",
    "sSearch_52":"",
    "bRegex_52":"false",
    "bSearchable_52":"true",
    "bSortable_52":"true",
    "mDataProp_53":"",
    "sSearch_53":"",
    "bRegex_53":"false",
    "bSearchable_53":"true",
    "bSortable_53":"true",
    "mDataProp_54":"",
    "sSearch_54":"",
    "bRegex_54":"false",
    "bSearchable_54":"true",
    "bSortable_54":"true",
    "mDataProp_55":"",
    "sSearch_55":"",
    "bRegex_55":"false",
    "bSearchable_55":"true",
    "bSortable_55":"true",
    "mDataProp_56":"",
    "sSearch_56":"",
    "bRegex_56":"false",
    "bSearchable_56":"true",
    "bSortable_56":"true",
    "mDataProp_57":"details",
    "sSearch_57":"",
    "bRegex_57":"false",
    "bSearchable_57":"true",
    "bSortable_57":"false",
    "sSearch":"",
    "bRegex":"false",
    "iSortCol_0":"2",
    "sSortDir_0":"asc",
    "iSortingCols":"1",
    "_":"1601192604982"
    });
  }

  static getUsers(context) async {
    await Utils.checkLogin();
    var res = await http.get(Utils.GET_USERS, headers: Utils.headers);
    // print(res.body);
    List<dynamic> data = jsonDecode(res.body)['aaData'];
    Map<String, dynamic> usersdata = {};
    List<String> ids = Utils.netUsers.keys.toList();
    List<String> notIn = [];
    String username;
    int i=0;
    data.forEach((e) async {
      username = e['username'].substring(
          e['username'].indexOf('022825sumanthanetworks') + 24,
          e['username'].indexOf('</' + 'a>'));
      username = username.split(' ').first;
      if(!ids.contains(e['user_id']) && i==0){
        notIn.add(e['user_id']);
      }
      usersdata[e['user_id']] = {
        'uid': e['user_id'],
        'address': e['address_line1'],
        'activation_date':
        e['activation_time'].substring(0, 10).replaceAll('-', '/'),
        'user_id': username,
        'zone': e['account_id'],
        'expiry_date':
        e['expiration_time'].substring(0, 10).replaceAll('-', '/'),
        'mobile': e['phone'],
        'name': e['name'] + ' ' + e['last_name'],
        'first_name': e['name'],
        'last_name': e['last_name'],
        'created_date': e['created'],
        'plan': e['group'],
        'group_id': e['user_group_id'],
        'email': e['email'],
        'status': e['status'],
        'circuit_id': e['circuit_id'],
        'installation_time': e['installation_time'],
        'binded_mac': e['lowercasedStaticipmac'] == ""
            ? ""
            : e['lowercasedStaticipmac'][0].substring(9),
        'is_online': e['online'] == 'yes',
        'online_mac': e['mac'],
      };
      String m = e['phone'];
      /*if(m.isEmpty || !(m.length==12 || m.length==10) || !(m.substring(0)=='9' || m.substring(0)=='8' || m.substring(0)!='7')){
      }*/
    });

    res =
    await http.get(Utils.ACTIVE_SESSIONS, headers: Utils.headers);
    data = jsonDecode(jsonDecode(res.body)['message']);
    // await Navigator.push(context, Utils.createRoute(ErrorScreen(error: data,html: false,), Utils.DTU));
    // return;
    var uid;
    data.forEach((e) {
      e = e["UserSession"];
      uid = e['user_id'];
      usersdata[uid]['online_mac'] = e['mac'];
      usersdata[uid]['mac_vendor'] = e['mac_vendor'];
      usersdata[uid]['ip'] = e['ip_addr'];
      usersdata[uid]['auth_type'] = e['authType'];
      usersdata[uid]['downloaded'] = e['download_bytes'];
      usersdata[uid]['uploaded'] = e['upload_bytes'];
      usersdata[uid]['duration'] = e['duration'];
      usersdata[uid]['start_time'] = e['start_time'];
      usersdata[uid]['user_session_id'] = e['id'];
    });
    Utils.usersMap = usersdata;
    Utils.users = usersdata.values.toList();
    Utils.usersCatCount["All"] = Utils.users.length;
    Utils.usersCatCount["Online"] = Utils.users.sublist(0).where((e) => (e['is_online'])).length;
    Utils.usersCatCount["Not Online"] = Utils.users.sublist(0).where((e) => (!e['is_online'] && e['status'] == 'active')).length;
    Utils.usersCatCount["Active"] = Utils.users.sublist(0).where((e) => (e['status'] == 'active')).length;
    Utils.usersCatCount["Expired"] = Utils.users.sublist(0).where((e) => (e['status'] == 'expired')).length;
    if(notIn.length>0) {
      createAppUser(notIn, context);
    }
  }

  static resetAppPassword(context, u) async {
    Utils.showLoadingDialog(context, "Loading");
    String password = "${u['mobile'].length>6?u['mobile']:'12345678'}";
    password = "12345678";
    var resp = await http.post(Utils.UPDATE_AUTH_USER,
        body: {
          "user_id": u['user_id'],
          "password": password,
          "name": "${u['name']}",
          "uid": "${u['uid']}",
        });
    Navigator.pop(context);
    // print(resp.body);
    if (resp.statusCode != 200){
      await Utils.showErrorDialog(context ,'Error',
          'Password Update of ${u['user_id']} - ${u['name']} was Not Successful\n${jsonDecode(resp.body)}');
    }
  }

  static createAppUser(List<String> notIn, context) async {
    notIn.forEach((e) async {
      var u = Utils.users.where((element) => element['uid'] == e).first;
      var resp = await http.post(Utils.CREATE_AUTH_USER,
          body: {
            "user_id": u['user_id'],
            "password": "${u['mobile'].length>6?u['mobile']:'12345678'}",
            "name": "${u['name']}",
            "uid": "${u['uid']}",
          });
      if (resp.statusCode != 200){
        Utils.showErrorDialog(context ,'Error',
            'Auth Creation of ${u['user_id']} - ${u['name']} was Not Successful\n${jsonDecode(resp.body)['msg']}');
      }
      Utils.netUsers[u['uid']] = {'user_id': u['user_id'],};
    });
  }

  static Future<bool> checkLogin() async {

    var r;
    try{
       r = await http.post(Utils.USERS_COUNT, headers: headers);
    } catch(e) {
      print(e);
    }
    // print("---------- ${r.request.headers}");
    return false;
    // print(r.body);
    if(r.body=='' || r.body[0]!='{'){
      r = await http.post(Utils.LOGIN,
          body: {"username": "022825", "password": "bssss888"}, headers: {});
      // Utils.cookie = r.headers['set-cookie'].substring(0,r.headers['set-cookie'].indexOf(';'));
      String s = r.headers['set-cookie'];
      String d = '';
      d=s.substring(s.indexOf('jazewifi_'));
      d=d.substring(0,d.indexOf(';'));
      d=s.substring(0,s.indexOf(';'))+';'+d;
      Utils.cookie = d;
      Utils.headers['cookie'] = d;

      Utils.authorization = jsonDecode(r.body)['message'];
      Utils.headers['authorization'] = Utils.authorization;
      return false;
    }
    return true;
  }

  static Future<bool> showErrorDialog(BuildContext context,String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: Colors.red),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static showLoadingDialog(BuildContext context, String title) {
    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(8),
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 8,
                  ),
                  Text(title)
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/*
  static Map<String,List<String>> plans = {
    'Basic Unlimited-8Mbps':['44418','13014','400','1','1'],
    'Netplus Unlimited_40Mbps_1Month':['9940','10537','500','1','1'],
    'Value Plus Unlimited_60Mbps_1Month':['10212','10553','550','1','1'],
    'Value Plus Unlimited_60Mbps_3months':['10484','10555','1650','3','1'],
    'Value Plus Unlimited_60Mbps_6Months':['10757','10556','3300','6','1'],
    'Gold Unlimited_80Mbps_1Month':['11030','10532','600','1','1'],
    'Gold Unlimited_80Mbps_3Months':['32597','10534','1800','3','1'],
    'Gold Unlimited_80Mbps_6Months':['12397','10533','3600','6','1'],
    'Platinum Unlimited_200Mbps_1month' : ['12945','10538','900','1','1'],
    'Platinum Unlimited_200Mbps_3Months' : ['13493','10540','2700','3','1'],
    'Platinum Unlimited_200Mbps_6Months' : ['13219','10541','5400','6','1'],
    'Platinum Unlimited-400 Mbps-1M' : ['47069','13177','1200','1','1'],
    'Platinum Unlimited_400Mbps-3M' : ['47581','13178','3600','3','1'],
    'Platinum Unlimited_400 Mbps-6M' : ['48093','13179','7200','6','1'],
    'Basic Unlimited-4Mbps':['44418','13014','400','1','0'],
    'Netplus Unlimited_20Mbps_1Month':['9940','10537','500','1','0'],
    'Value Plus Unlimited_30Mbps_1Month':['10212','10553','550','1','0'],
    'Value Plus Unlimited_30Mbps_3months':['10484','10555','1650','3','0'],
    'Value Plus Unlimited_30Mbps_6Months':['10757','10556','3300','6','0'],
    'Gold Unlimited_40Mbps_1Month':['11030','10532','600','1','0'],
    'Gold Unlimited_40Mbps_3Months':['32597','10534','1800','3','0'],
    'Gold Unlimited_40Mbps_6Months':['12397','10533','3600','6','0'],
    'Platinum Unlimited_100Mbps_1month' : ['12945','10538','900','1','0'],
    'Platinum Unlimited_100Mbps_3Months' : ['13493','10540','2700','3','0'],
    'Platinum Unlimited_100Mbps_6Months' : ['13219','10541','5400','6','0'],
    'Platinum Unlimited-200 Mbps-1M' : ['47069','13177','1200','1','0'],
    'Platinum Unlimited_200Mbps-3M' : ['47581','13178','3600','3','0'],
    'Platinum Unlimited_200 Mbps-6M' : ['48093','13179','7200','6','0'],
    'VoIP public Unlimited-5 Mbps':['35689','10557','0','1','1'],
    '75 Mbps_150GB 3M':['15472','10917','0','3','1'],
    '100 Mbps_200GB 3M':['15955','10918','0','3','1'],
    '150 Mbps_400GB 3M':['','10919','0','3','1']
  };*/