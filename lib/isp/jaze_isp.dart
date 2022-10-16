import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:sumanth_net_admin/firestoreCollection.dart';
import 'package:sumanth_net_admin/utils.dart';

class JazeISP {
  JazeISP() {
    dio = new Dio();
    cookieJar = new CookieJar();
    dio.interceptors.add(new CookieManager(cookieJar));
  }

  var dio;
  var cookieJar;
  List<dynamic> users = [];
  Map<String, dynamic> usersMap = {};
  List<dynamic> netPayments = [];
  Map<String, dynamic> netUsers = {};
  Map<String, String> headers = {};
  Plans plans_;
  Map<String, Plan> plans = {};
  List<String> planNames = [], planKeys = [];
  String code = "",
      cookie = '',
      authorization = '',
      usersCollection = "",
      billsCollection = "",
      balance = "";
  int staticIPPrice = 300;
  Map<String, int> usersCatCount = {
    'Active': 0,
    'Online': 0,
    'Not Online': 0,
    'Expired': 0,
    'All': 0,
  };

  String DOMAIN = "", ENTITY = "", USERNAME = "", PASSWORD = "";
  String LOGIN = '/backend/login/login_post';
  String LOGOUT = '/backend/login/logout';
  String RESET_PASSWORD = '/backend/users/reset_user_password.json';
  String CHANGE_EMAIL = '/backend/users/edit_user_mobile_email';
  String CHANGE_USER_ID = '/backend/users/change_username';
  String USERS_COUNT = '/backend/dashboard/set_users_count/all/usersCount';
  String ACTIVE_SESSIONS =
      '/backend/monitoring/active_sessions_data/both/null/null/null/all/activeSessions/true/50/1/null/start_time';
  String REMOVE_SESSION = '/backend/monitoring/terminate_session';
  String GET_CIRCUIT_ID = '/backend/users/add/0/true';
  String GET_PLAN_PROFILE_ID = '/backend/users/get_current_profile_plans';
  String ADD_USER = '/backend/users/add';
  String EDIT_USER = '/backend/users/edit.json';
  String RENEW_USER = '/backend/billing/renew_user';
  String SEND_OTP = '/backend/users/send_mobile_otp_user';
  String VERIFY_OTP = '/backend/users/submit_mobile_otp_user';
  String GET_USERS = '/backend/users/get_all_data/all/all/';
  String GET_FRANCHISE_BALANCE = '/backend/dashboard/index/true/null/true';

  final Uri LOGIN_API = Uri.https(
      'us-central1-sumanthnet-13082020.cloudfunctions.net', '/paysApp/login');
  final Uri CREATE_AUTH_USER = Uri.https(
      'us-central1-sumanthnet-13082020.cloudfunctions.net',
      '/paysApp/createUserAuth');
  final Uri UPDATE_AUTH_USER = Uri.https(
      'us-central1-sumanthnet-13082020.cloudfunctions.net',
      '/paysApp/updateUserAuth');

  init() {
    LOGIN = "$DOMAIN$LOGIN";
    LOGOUT = "$DOMAIN$LOGOUT";
    RESET_PASSWORD = "$DOMAIN$RESET_PASSWORD";
    CHANGE_EMAIL = "$DOMAIN$CHANGE_EMAIL";
    CHANGE_USER_ID = "$DOMAIN$CHANGE_USER_ID";
    USERS_COUNT = "$DOMAIN$USERS_COUNT";
    ACTIVE_SESSIONS = "$DOMAIN$ACTIVE_SESSIONS";
    REMOVE_SESSION = "$DOMAIN$REMOVE_SESSION";
    GET_CIRCUIT_ID = "$DOMAIN$GET_CIRCUIT_ID";
    GET_PLAN_PROFILE_ID = "$DOMAIN$GET_PLAN_PROFILE_ID";
    ADD_USER = "$DOMAIN$ADD_USER";
    EDIT_USER = "$DOMAIN$EDIT_USER";
    RENEW_USER = "$DOMAIN$RENEW_USER";
    SEND_OTP = "$DOMAIN$SEND_OTP";
    VERIFY_OTP = "$DOMAIN$VERIFY_OTP";
    GET_USERS = "$DOMAIN$GET_USERS";
    GET_FRANCHISE_BALANCE = "$DOMAIN$GET_FRANCHISE_BALANCE";
    plans_ = Plans("${code}_plans");
    loadPlans();
  }

  Map<String, dynamic> getSpecifics() {
    return <String, dynamic>{};
  }

  String getUserLogsByUIDLink(String uid) {
    return '$DOMAIN/backend/users/user_logs_data/$uid/$ENTITY';
  }

  String getUserBillsByUIDLink(String uid) {
    return '$DOMAIN/backend/users/franchiseStatementData/$uid/$ENTITY/null/null/true/50/1/null/created desc';
  }

  String getUserSessionsByUIDLink(String uid) {
    return '$DOMAIN/backend/users/session_data/$uid/$ENTITY';
  }

  Uri getUserByUIDLink(String uid) {
    return Uri.https("$DOMAIN", '/backend/users/get_all_data/all/all/', {
      "sEcho": "1",
      "iColumns": "58",
      "sColumns": ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
      "iDisplayStart": "0",
      "iDisplayLength": "400",
      "mDataProp_0": "id",
      "sSearch_0": "",
      "bRegex_0": "false",
      "bSearchable_0": "true",
      "bSortable_0": "false",
      "mDataProp_1": "user_id",
      "sSearch_1": "$uid",
      "bRegex_1": "false",
      "bSearchable_1": "true",
      "bSortable_1": "true",
      "mDataProp_2": "username",
      "sSearch_2": "",
      "bRegex_2": "false",
      "bSearchable_2": "true",
      "bSortable_2": "true",
      "mDataProp_3": "circuit_id",
      "sSearch_3": "",
      "bRegex_3": "false",
      "bSearchable_3": "true",
      "bSortable_3": "true",
      "mDataProp_4": "status",
      "sSearch_4": "",
      "bRegex_4": "false",
      "bSearchable_4": "true",
      "bSortable_4": "true",
      "mDataProp_5": "suspended_time",
      "sSearch_5": "",
      "bRegex_5": "false",
      "bSearchable_5": "true",
      "bSortable_5": "true",
      "mDataProp_6": "Actions",
      "sSearch_6": "",
      "bRegex_6": "false",
      "bSearchable_6": "true",
      "bSortable_6": "false",
      "mDataProp_7": "name",
      "sSearch_7": "",
      "bRegex_7": "false",
      "bSearchable_7": "true",
      "bSortable_7": "true",
      "mDataProp_8": "last_name",
      "sSearch_8": "",
      "bRegex_8": "false",
      "bSearchable_8": "true",
      "bSortable_8": "true",
      "mDataProp_9": "phone",
      "sSearch_9": "",
      "bRegex_9": "false",
      "bSearchable_9": "true",
      "bSortable_9": "true",
      "mDataProp_10": "alt_phone",
      "sSearch_10": "",
      "bRegex_10": "false",
      "bSearchable_10": "true",
      "bSortable_10": "true",
      "mDataProp_11": "email",
      "sSearch_11": "",
      "bRegex_11": "false",
      "bSearchable_11": "true",
      "bSortable_11": "true",
      "mDataProp_12": "activation_time",
      "sSearch_12": "",
      "bRegex_12": "false",
      "bSearchable_12": "true",
      "bSortable_12": "true",
      "mDataProp_13": "created",
      "sSearch_13": "",
      "bRegex_13": "false",
      "bSearchable_13": "true",
      "bSortable_13": "true",
      "mDataProp_14": "expiration_time",
      "sSearch_14": "",
      "bRegex_14": "false",
      "bSearchable_14": "true",
      "bSortable_14": "true",
      "mDataProp_15": "installation_time",
      "sSearch_15": "",
      "bRegex_15": "false",
      "bSearchable_15": "true",
      "bSortable_15": "true",
      "mDataProp_16": "staticipmac",
      "sSearch_16": "",
      "bRegex_16": "false",
      "bSearchable_16": "true",
      "bSortable_16": "false",
      "mDataProp_17": "userNasPortId",
      "sSearch_17": "",
      "bRegex_17": "false",
      "bSearchable_17": "true",
      "bSortable_17": "true",
      "mDataProp_18": "balance",
      "sSearch_18": "",
      "bRegex_18": "false",
      "bSearchable_18": "true",
      "bSortable_18": "true",
      "mDataProp_19": "due",
      "sSearch_19": "",
      "bRegex_19": "false",
      "bSearchable_19": "true",
      "bSortable_19": "true",
      "mDataProp_20": "deposit",
      "sSearch_20": "",
      "bRegex_20": "false",
      "bSearchable_20": "true",
      "bSortable_20": "true",
      "mDataProp_21": "gstnumber",
      "sSearch_21": "",
      "bRegex_21": "false",
      "bSearchable_21": "true",
      "bSortable_21": "true",
      "mDataProp_22": "group",
      "sSearch_22": "",
      "bRegex_22": "false",
      "bSearchable_22": "true",
      "bSortable_22": "true",
      "mDataProp_23": "company_name",
      "sSearch_23": "",
      "bRegex_23": "false",
      "bSearchable_23": "true",
      "bSortable_23": "true",
      "mDataProp_24": "address",
      "sSearch_24": "",
      "bRegex_24": "false",
      "bSearchable_24": "true",
      "bSortable_24": "true",
      "mDataProp_25": "address_line1",
      "sSearch_25": "",
      "bRegex_25": "false",
      "bSearchable_25": "true",
      "bSortable_25": "true",
      "mDataProp_26": "address_line2",
      "sSearch_26": "",
      "bRegex_26": "false",
      "bSearchable_26": "true",
      "bSortable_26": "true",
      "mDataProp_27": "address_city",
      "sSearch_27": "",
      "bRegex_27": "false",
      "bSearchable_27": "true",
      "bSortable_27": "true",
      "mDataProp_28": "address_pin",
      "sSearch_28": "",
      "bRegex_28": "false",
      "bSearchable_28": "true",
      "bSortable_28": "true",
      "mDataProp_29": "address_state",
      "sSearch_29": "",
      "bRegex_29": "false",
      "bSearchable_29": "true",
      "bSortable_29": "true",
      "mDataProp_30": "userarea",
      "sSearch_30": "",
      "bRegex_30": "false",
      "bSearchable_30": "true",
      "bSortable_30": "true",
      "mDataProp_31": "userstreet",
      "sSearch_31": "",
      "bRegex_31": "false",
      "bSearchable_31": "true",
      "bSortable_31": "true",
      "mDataProp_32": "userblock",
      "sSearch_32": "",
      "bRegex_32": "false",
      "bSearchable_32": "true",
      "bSortable_32": "true",
      "mDataProp_33": "userlatitude",
      "sSearch_33": "",
      "bRegex_33": "false",
      "bSearchable_33": "true",
      "bSortable_33": "true",
      "mDataProp_34": "userlongitude",
      "sSearch_34": "",
      "bRegex_34": "false",
      "bSearchable_34": "true",
      "bSortable_34": "true",
      "mDataProp_35": "type",
      "sSearch_35": "",
      "bRegex_35": "false",
      "bSearchable_35": "true",
      "bSortable_35": "true",
      "mDataProp_36": "comments",
      "sSearch_36": "",
      "bRegex_36": "false",
      "bSearchable_36": "true",
      "bSortable_36": "true",
      "mDataProp_37": "",
      "sSearch_37": "",
      "bRegex_37": "false",
      "bSearchable_37": "true",
      "bSortable_37": "true",
      "mDataProp_38": "",
      "sSearch_38": "",
      "bRegex_38": "false",
      "bSearchable_38": "true",
      "bSortable_38": "true",
      "mDataProp_39": "",
      "sSearch_39": "",
      "bRegex_39": "false",
      "bSearchable_39": "true",
      "bSortable_39": "true",
      "mDataProp_40": "",
      "sSearch_40": "",
      "bRegex_40": "false",
      "bSearchable_40": "true",
      "bSortable_40": "true",
      "mDataProp_41": "",
      "sSearch_41": "",
      "bRegex_41": "false",
      "bSearchable_41": "true",
      "bSortable_41": "true",
      "mDataProp_42": "",
      "sSearch_42": "",
      "bRegex_42": "false",
      "bSearchable_42": "true",
      "bSortable_42": "true",
      "mDataProp_43": "",
      "sSearch_43": "",
      "bRegex_43": "false",
      "bSearchable_43": "true",
      "bSortable_43": "true",
      "mDataProp_44": "",
      "sSearch_44": "",
      "bRegex_44": "false",
      "bSearchable_44": "true",
      "bSortable_44": "true",
      "mDataProp_45": "",
      "sSearch_45": "",
      "bRegex_45": "false",
      "bSearchable_45": "true",
      "bSortable_45": "true",
      "mDataProp_46": "",
      "sSearch_46": "",
      "bRegex_46": "false",
      "bSearchable_46": "true",
      "bSortable_46": "true",
      "mDataProp_47": "",
      "sSearch_47": "",
      "bRegex_47": "false",
      "bSearchable_47": "true",
      "bSortable_47": "true",
      "mDataProp_48": "",
      "sSearch_48": "",
      "bRegex_48": "false",
      "bSearchable_48": "true",
      "bSortable_48": "true",
      "mDataProp_49": "",
      "sSearch_49": "",
      "bRegex_49": "false",
      "bSearchable_49": "true",
      "bSortable_49": "true",
      "mDataProp_50": "",
      "sSearch_50": "",
      "bRegex_50": "false",
      "bSearchable_50": "true",
      "bSortable_50": "true",
      "mDataProp_51": "",
      "sSearch_51": "",
      "bRegex_51": "false",
      "bSearchable_51": "true",
      "bSortable_51": "true",
      "mDataProp_52": "",
      "sSearch_52": "",
      "bRegex_52": "false",
      "bSearchable_52": "true",
      "bSortable_52": "true",
      "mDataProp_53": "",
      "sSearch_53": "",
      "bRegex_53": "false",
      "bSearchable_53": "true",
      "bSortable_53": "true",
      "mDataProp_54": "",
      "sSearch_54": "",
      "bRegex_54": "false",
      "bSearchable_54": "true",
      "bSortable_54": "true",
      "mDataProp_55": "",
      "sSearch_55": "",
      "bRegex_55": "false",
      "bSearchable_55": "true",
      "bSortable_55": "true",
      "mDataProp_56": "",
      "sSearch_56": "",
      "bRegex_56": "false",
      "bSearchable_56": "true",
      "bSortable_56": "true",
      "mDataProp_57": "details",
      "sSearch_57": "",
      "bRegex_57": "false",
      "bSearchable_57": "true",
      "bSortable_57": "false",
      "sSearch": "",
      "bRegex": "false",
      "iSortCol_0": "2",
      "sSortDir_0": "asc",
      "iSortingCols": "1",
      "_": "1601192604982"
    });
  }

  Future<ISPResponse> login() async {
    try {
      var r = await dio
          .post(LOGIN, data: {"username": USERNAME, "password": PASSWORD});
      authorization = jsonDecode(r.data)['message'];
      String s = r.headers.value('set-cookie');
      String d = '';
      d = s.substring(s.indexOf('jazewifi_'));
      d = d.substring(0, d.indexOf(';'));
      d = s.substring(0, s.indexOf(';')) + ';' + d;
      cookie = d;
      headers['cookie'] = cookie;
      headers['authorization'] = authorization;
      return ISPResponse(true, "", headers);
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st", headers);
    }
  }

  Future<ISPResponse> getUsersCount() async {
    try {
      await checkLogin();
      var r = await dio.get(USERS_COUNT);
      return ISPResponse(true, "Got count successfully.", jsonDecode(r.data));
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  Future<ISPResponse> getUsers() async {
    try {
      await checkLogin();
      var res = await dio.get(GET_USERS, queryParameters: {
        "sEcho": "1",
        "iColumns": "58",
        "sColumns": ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
        "iDisplayStart": "0",
        "iDisplayLength": "400",
        "mDataProp_0": "id",
        "sSearch_0": "",
        "bRegex_0": "false",
        "bSearchable_0": "true",
        "bSortable_0": "false",
        "mDataProp_1": "user_id",
        "sSearch_1": "",
        "bRegex_1": "false",
        "bSearchable_1": "true",
        "bSortable_1": "true",
        "mDataProp_2": "username",
        "sSearch_2": "",
        "bRegex_2": "false",
        "bSearchable_2": "true",
        "bSortable_2": "true",
        "mDataProp_3": "circuit_id",
        "sSearch_3": "",
        "bRegex_3": "false",
        "bSearchable_3": "true",
        "bSortable_3": "true",
        "mDataProp_4": "status",
        "sSearch_4": "",
        "bRegex_4": "false",
        "bSearchable_4": "true",
        "bSortable_4": "true",
        "mDataProp_5": "suspended_time",
        "sSearch_5": "",
        "bRegex_5": "false",
        "bSearchable_5": "true",
        "bSortable_5": "true",
        "mDataProp_6": "Actions",
        "sSearch_6": "",
        "bRegex_6": "false",
        "bSearchable_6": "true",
        "bSortable_6": "false",
        "mDataProp_7": "name",
        "sSearch_7": "",
        "bRegex_7": "false",
        "bSearchable_7": "true",
        "bSortable_7": "true",
        "mDataProp_8": "last_name",
        "sSearch_8": "",
        "bRegex_8": "false",
        "bSearchable_8": "true",
        "bSortable_8": "true",
        "mDataProp_9": "phone",
        "sSearch_9": "",
        "bRegex_9": "false",
        "bSearchable_9": "true",
        "bSortable_9": "true",
        "mDataProp_10": "alt_phone",
        "sSearch_10": "",
        "bRegex_10": "false",
        "bSearchable_10": "true",
        "bSortable_10": "true",
        "mDataProp_11": "email",
        "sSearch_11": "",
        "bRegex_11": "false",
        "bSearchable_11": "true",
        "bSortable_11": "true",
        "mDataProp_12": "activation_time",
        "sSearch_12": "",
        "bRegex_12": "false",
        "bSearchable_12": "true",
        "bSortable_12": "true",
        "mDataProp_13": "created",
        "sSearch_13": "",
        "bRegex_13": "false",
        "bSearchable_13": "true",
        "bSortable_13": "true",
        "mDataProp_14": "expiration_time",
        "sSearch_14": "",
        "bRegex_14": "false",
        "bSearchable_14": "true",
        "bSortable_14": "true",
        "mDataProp_15": "installation_time",
        "sSearch_15": "",
        "bRegex_15": "false",
        "bSearchable_15": "true",
        "bSortable_15": "true",
        "mDataProp_16": "staticipmac",
        "sSearch_16": "",
        "bRegex_16": "false",
        "bSearchable_16": "true",
        "bSortable_16": "false",
        "mDataProp_17": "userNasPortId",
        "sSearch_17": "",
        "bRegex_17": "false",
        "bSearchable_17": "true",
        "bSortable_17": "true",
        "mDataProp_18": "balance",
        "sSearch_18": "",
        "bRegex_18": "false",
        "bSearchable_18": "true",
        "bSortable_18": "true",
        "mDataProp_19": "due",
        "sSearch_19": "",
        "bRegex_19": "false",
        "bSearchable_19": "true",
        "bSortable_19": "true",
        "mDataProp_20": "deposit",
        "sSearch_20": "",
        "bRegex_20": "false",
        "bSearchable_20": "true",
        "bSortable_20": "true",
        "mDataProp_21": "gstnumber",
        "sSearch_21": "",
        "bRegex_21": "false",
        "bSearchable_21": "true",
        "bSortable_21": "true",
        "mDataProp_22": "group",
        "sSearch_22": "",
        "bRegex_22": "false",
        "bSearchable_22": "true",
        "bSortable_22": "true",
        "mDataProp_23": "company_name",
        "sSearch_23": "",
        "bRegex_23": "false",
        "bSearchable_23": "true",
        "bSortable_23": "true",
        "mDataProp_24": "address",
        "sSearch_24": "",
        "bRegex_24": "false",
        "bSearchable_24": "true",
        "bSortable_24": "true",
        "mDataProp_25": "address_line1",
        "sSearch_25": "",
        "bRegex_25": "false",
        "bSearchable_25": "true",
        "bSortable_25": "true",
        "mDataProp_26": "address_line2",
        "sSearch_26": "",
        "bRegex_26": "false",
        "bSearchable_26": "true",
        "bSortable_26": "true",
        "mDataProp_27": "address_city",
        "sSearch_27": "",
        "bRegex_27": "false",
        "bSearchable_27": "true",
        "bSortable_27": "true",
        "mDataProp_28": "address_pin",
        "sSearch_28": "",
        "bRegex_28": "false",
        "bSearchable_28": "true",
        "bSortable_28": "true",
        "mDataProp_29": "address_state",
        "sSearch_29": "",
        "bRegex_29": "false",
        "bSearchable_29": "true",
        "bSortable_29": "true",
        "mDataProp_30": "userarea",
        "sSearch_30": "",
        "bRegex_30": "false",
        "bSearchable_30": "true",
        "bSortable_30": "true",
        "mDataProp_31": "userstreet",
        "sSearch_31": "",
        "bRegex_31": "false",
        "bSearchable_31": "true",
        "bSortable_31": "true",
        "mDataProp_32": "userblock",
        "sSearch_32": "",
        "bRegex_32": "false",
        "bSearchable_32": "true",
        "bSortable_32": "true",
        "mDataProp_33": "userlatitude",
        "sSearch_33": "",
        "bRegex_33": "false",
        "bSearchable_33": "true",
        "bSortable_33": "true",
        "mDataProp_34": "userlongitude",
        "sSearch_34": "",
        "bRegex_34": "false",
        "bSearchable_34": "true",
        "bSortable_34": "true",
        "mDataProp_35": "type",
        "sSearch_35": "",
        "bRegex_35": "false",
        "bSearchable_35": "true",
        "bSortable_35": "true",
        "mDataProp_36": "comments",
        "sSearch_36": "",
        "bRegex_36": "false",
        "bSearchable_36": "true",
        "bSortable_36": "true",
        "mDataProp_37": "",
        "sSearch_37": "",
        "bRegex_37": "false",
        "bSearchable_37": "true",
        "bSortable_37": "true",
        "mDataProp_38": "",
        "sSearch_38": "",
        "bRegex_38": "false",
        "bSearchable_38": "true",
        "bSortable_38": "true",
        "mDataProp_39": "",
        "sSearch_39": "",
        "bRegex_39": "false",
        "bSearchable_39": "true",
        "bSortable_39": "true",
        "mDataProp_40": "",
        "sSearch_40": "",
        "bRegex_40": "false",
        "bSearchable_40": "true",
        "bSortable_40": "true",
        "mDataProp_41": "",
        "sSearch_41": "",
        "bRegex_41": "false",
        "bSearchable_41": "true",
        "bSortable_41": "true",
        "mDataProp_42": "",
        "sSearch_42": "",
        "bRegex_42": "false",
        "bSearchable_42": "true",
        "bSortable_42": "true",
        "mDataProp_43": "",
        "sSearch_43": "",
        "bRegex_43": "false",
        "bSearchable_43": "true",
        "bSortable_43": "true",
        "mDataProp_44": "",
        "sSearch_44": "",
        "bRegex_44": "false",
        "bSearchable_44": "true",
        "bSortable_44": "true",
        "mDataProp_45": "",
        "sSearch_45": "",
        "bRegex_45": "false",
        "bSearchable_45": "true",
        "bSortable_45": "true",
        "mDataProp_46": "",
        "sSearch_46": "",
        "bRegex_46": "false",
        "bSearchable_46": "true",
        "bSortable_46": "true",
        "mDataProp_47": "",
        "sSearch_47": "",
        "bRegex_47": "false",
        "bSearchable_47": "true",
        "bSortable_47": "true",
        "mDataProp_48": "",
        "sSearch_48": "",
        "bRegex_48": "false",
        "bSearchable_48": "true",
        "bSortable_48": "true",
        "mDataProp_49": "",
        "sSearch_49": "",
        "bRegex_49": "false",
        "bSearchable_49": "true",
        "bSortable_49": "true",
        "mDataProp_50": "",
        "sSearch_50": "",
        "bRegex_50": "false",
        "bSearchable_50": "true",
        "bSortable_50": "true",
        "mDataProp_51": "",
        "sSearch_51": "",
        "bRegex_51": "false",
        "bSearchable_51": "true",
        "bSortable_51": "true",
        "mDataProp_52": "",
        "sSearch_52": "",
        "bRegex_52": "false",
        "bSearchable_52": "true",
        "bSortable_52": "true",
        "mDataProp_53": "",
        "sSearch_53": "",
        "bRegex_53": "false",
        "bSearchable_53": "true",
        "bSortable_53": "true",
        "mDataProp_54": "",
        "sSearch_54": "",
        "bRegex_54": "false",
        "bSearchable_54": "true",
        "bSortable_54": "true",
        "mDataProp_55": "",
        "sSearch_55": "",
        "bRegex_55": "false",
        "bSearchable_55": "true",
        "bSortable_55": "true",
        "mDataProp_56": "",
        "sSearch_56": "",
        "bRegex_56": "false",
        "bSearchable_56": "true",
        "bSortable_56": "true",
        "mDataProp_57": "details",
        "sSearch_57": "",
        "bRegex_57": "false",
        "bSearchable_57": "true",
        "bSortable_57": "false",
        "sSearch": "",
        "bRegex": "false",
        "iSortCol_0": "2",
        "sSortDir_0": "asc",
        "iSortingCols": "1",
        "_": "1601192604982"
      });
      List<dynamic> data = jsonDecode(res.data)['aaData'];
      Map<String, dynamic> usersdata = {};
      List<String> ids = netUsers.keys.toList();
      List<String> notIn = [];
      String username;
      await FirebaseFirestore.instance.collection(usersCollection).get().then((v) {
        v.docs.forEach((e) {
          netUsers[e.id] = e.data();
        });
      });
      for (int i = 0; i < data.length; i++) {
        var e = data[i];
        username = e['username'].substring(
            e['username'].indexOf('$ENTITY') + (ENTITY.length + 2),
            e['username'].indexOf('</' + 'a>'));
        username = username.split(' ').first;
        if (!ids.contains(e['user_id'])) {
          notIn.add(e['user_id']);
        }
        usersdata[e['user_id']] = {
          'uid': e['user_id'],
          'circuit': e['circuit_id'],
          'address': e['address_line1'],
          'activation_date': e['activation_time']
              .toString()
              .substring(
                  0,
                  e['activation_time'].toString().length >= 10
                      ? 10
                      : e['activation_time'].toString().length)
              .replaceAll('-', '/'),
          'user_id': username,
          'zone': e['account_id'],
          'expiry_date': e['expiration_time']
              .toString()
              .substring(
                  0,
                  e['expiration_time'].toString().length >= 10
                      ? 10
                      : e['expiration_time'].toString().length)
              .replaceAll('-', '/'),
          'mobile': e['phone'],
          'name': "${e['name']}${e['last_name']==""?"":" "}${e['last_name']}",
          'first_name': e['name'],
          'last_name': e['last_name'],
          'created_date': e['created'],
          'plan': e['group'],
          'group_id': e['user_group_id'],
          'email': e['email'],
          'status': e['status'],
          'circuit_id': e['circuit_id'],
          'installation_time': e['installation_time'],
          'binded_mac': "",
          'static_ip': "",
          'is_online': e['online'] == 'yes',
          'online_mac': e['mac'],
        };
        if (e['lowercasedStaticipmac'] != "") {
          String ip = e['lowercasedStaticipmac'][0];
          if (ip.indexOf("(empty)") == 0) {
            ip = ip.replaceAll("(empty)=>", "");
            usersdata[e['user_id']]["binded_mac"] = ip;
          } else {
            ip = ip.replaceAll("=>(empty)", "");
            usersdata[e['user_id']]["static_ip"] = ip;
          }
        }
      }
      var re = await http.get(Uri.parse(ACTIVE_SESSIONS), headers: headers);
      data = jsonDecode(jsonDecode(re.body)['message']);
      var uid;
      data.forEach((e) {
        e = e["UserSession"];
        uid = e['user_id'];
        usersdata[uid]['online_mac'] = e['mac'];
        usersdata[uid]['mac_vendor'] = e['mac_vendor'];
        usersdata[uid]['ip'] = "${e['ip_addr']} - ${e['nas_ip_addr']}(NAS)";
        usersdata[uid]['auth_type'] = e['authType'];
        usersdata[uid]['downloaded'] = e['download_bytes'];
        usersdata[uid]['uploaded'] = e['upload_bytes'];
        usersdata[uid]['duration'] = e['duration'];
        usersdata[uid]['start_time'] = e['start_time'];
        usersdata[uid]['user_session_id'] = e['id'];
      });
      usersMap = usersdata;
      users = usersdata.values.toList();
      usersCatCount["All"] = users.length;
      usersCatCount["Online"] =
          users.sublist(0).where((e) => (e['is_online'] ?? false)).length;
      usersCatCount["Not Online"] = users
          .sublist(0)
          .where((e) => (!(e['is_online'] ?? false) && e['status'] == 'active'))
          .length;
      usersCatCount["Active"] =
          users.sublist(0).where((e) => (e['status'] == 'active')).length;
      usersCatCount["Expired"] =
          users.sublist(0).where((e) => (e['status'] == 'expired')).length;
      Utils.createAppUser(notIn);
      return ISPResponse(true,"Got Users Successfully");
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st", headers);
    }
  }

  Future<ISPResponse> changePassword(uid, password) async {
    try {
      await checkLogin();
      var resp = await dio.post(RESET_PASSWORD, data: {
        "userId": uid,
        "currentId": "$ENTITY",
        "type": "pppoe",
        "resetType": "resetManually",
        "password": "$password",
        "sendSMS": "true",
        "sendWhatsapp": "true",
        "sendEmail": "true"
      });
      return ISPResponse(true, "Changed password of $uid to $password successfully.", resp.data);
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  Future<ISPResponse> editUser(user, name, mobile, email, address, ip) async {
    try {
      await checkLogin();
      var resp = await http.post(Uri.parse(EDIT_USER), headers: headers, body: {
        "userId": user['uid'],
        "account": "$ENTITY",
        "userName": user['user_id'],
        "password": "",
        "userGroupId": "${plans[user['plan']].groupID}",
        "userPlanId": "${plans[user['plan']].profileID}",
        "overrideAmount": "",
        "overrideAmountBasedOn": "withTax",
        "firstName": name,
        "lastName": "",
        "phoneNumber": mobile,
        "enterOTPDisplay": "no",
        "tempPhone": "",
        "altPhoneNumber": "",
        "emailId": email,
        "altEmailId": "",
        "address_line1": address,
        "address_line2": "Patancheru",
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
        "staticIpAddress[]": ip,
        "staticIpBoundMac[]": user['binded_mac'],
        "ipPoolName": "",
        "activationDate": "custom",
        "customActivationDate":
            "${user['activation_date'].replaceAll('/', '-')} 00:00:00",
        "expirationDate": "custom",
        "customExpirationDate":
            "${user['expiry_date'].replaceAll('/', '-')} 10:00:00",
        "userState": "unblock",
        "comments": "",
        "generateRandomPasswordComplexity": "n",
        "generateRandomPasswordLength": "4",
        "generateRandomUsernameComplexity": "n",
        "generateRandomUsernameLength": "8"
      });
      var r = jsonDecode(resp.body);
      print(r);
      if (r['status'] == 'success') {
        return ISPResponse(true, "User Edited Successfully.", r);
      } else {
        return ISPResponse(false, "User Editing not Successful.", r);
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  Future<ISPResponse> shiftUser(user, Plan plan) async {}

  getAddUserBody(user, plan) async {}

  Future<ISPResponse> addUser(user, plan) async {
    try {
      var userBody = await getAddUserBody(user, plan);
      print(userBody);
      var response = await http
          .post(Uri.parse(ADD_USER), body: jsonEncode(userBody), headers: {
        'cookie': cookie,
        'authorization': authorization,
        "Content-Type": "application/json"
      });
      var resp = json.decode(response.body);

      if (resp['status'] == 'success') {
        var u = {};
        String uid = resp['message']['userId'];
        u['uid'] = uid;

        user['uid'] = uid;
        user["user_id"] = user["userName"];
        user["mobile"] = user["phoneNumber"];
        user["name"] = user["firstName"];

        await uploadUser(user);

        return ISPResponse(true, "Adding user successful.", resp);
      } else {
        return ISPResponse( false, "Adding user unsuccessful.", resp);
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  Future<ISPResponse> addLatestBillToFirebase(u) async {
    var resp = await http.post(
      Uri.parse(getUserBillsByUIDLink(u["uid"])),
      headers: headers,
    );
    var r = jsonDecode(resp.body);
    if (r['status'] == 'success') {
      u["bill_id"] = jsonDecode(r['message'])[0]["FranchiseStatement"]["reference_id"];
    } else {
      return ISPResponse(false, "Getting Bill ID unsuccessful with error ${r['message']}", r);
    }

    await FirebaseFirestore.instance
        .collection('$billsCollection')
        .doc(u["bill_id"])
        .set(u)
        .catchError((e) async {
      return ISPResponse( false, "ERROR: $e", {"error": e});
    });

    return ISPResponse(true, "Adding Bill successfully.", r);

  }

  getRenewBody(user, plan) async {
    DateTime today = DateTime.now();
    String date = '${today.year}-${today.month}-${today.day<10?'0${today.day}':today.day}';
    var body = {
      "userIds": "${user['uid']}",
      "accountId": "$ENTITY",
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
    if(plan != user["plan"]) {
      body["planId"] = "${plans[plan].profileID}";
      body["groupId"] = "${plans[plan].groupID}";
    }
    return body;
  }

  Future<ISPResponse> renewUser(user, plan) async {
    /*return ISPResponse(true, "Renewal of ${user["uid"]} with plan $plan is successfull.", {
      "renewal": {
        'status': 1,
        'error': "",
      }});*/
    try {
      await checkLogin();

      var userBody = await getRenewBody(user, plan);
      print("User Body: $userBody");
      var response = await http
          .post(Uri.parse(RENEW_USER), body: jsonEncode(userBody), headers: {
        'cookie': cookie,
        'authorization': authorization,
        "Content-Type": "application/json"
      });
      print("Renew Response: ${response.body}");
      var resp = json.decode(response.body);
      // var resp = json.decode(jsonEncode({
      //   "status": "success",
      // }));

      if (resp['status'] == "success") {

        Map<String, dynamic> returnBody = {
          "renewal": {
          'status': 1,
          'error': "",
        }};

        return ISPResponse(true, "Renewal of ${user["uid"]} with plan $plan is successfull.", returnBody);

      } else {
        return ISPResponse( false, "Renewal unsuccessful.\n${resp["msg"]}", resp);
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  Future<ISPResponse> getLogs(uid) async {
    try {
      await checkLogin();
      var resp = await dio.get(getUserLogsByUIDLink(uid), queryParameters: {
        "sEcho": "1",
        "iColumns": "7",
        "sColumns": ",,,,,,",
        "iDisplayStart": "0",
        "iDisplayLength": "50",
        "mDataProp_0": "created",
        "sSearch_0": "",
        "bRegex_0": "false",
        "bSearchable_0": "true",
        "bSortable_0": "true",
        "mDataProp_1": "ip_addr",
        "sSearch_1": "",
        "bRegex_1": "false",
        "bSearchable_1": "true",
        "bSortable_1": "true",
        "mDataProp_2": "mac",
        "sSearch_2": "",
        "bRegex_2": "false",
        "bSearchable_2": "true",
        "bSortable_2": "true",
        "mDataProp_3": "mac_vendor",
        "sSearch_3": "",
        "bRegex_3": "false",
        "bSearchable_3": "true",
        "bSortable_3": "true",
        "mDataProp_4": "password",
        "sSearch_4": "",
        "bRegex_4": "false",
        "bSearchable_4": "true",
        "bSortable_4": "true",
        "mDataProp_5": "ap_mac",
        "sSearch_5": "",
        "bRegex_5": "false",
        "bSearchable_5": "true",
        "bSortable_5": "true",
        "mDataProp_6": "message",
        "sSearch_6": "",
        "bRegex_6": "false",
        "bSearchable_6": "true",
        "bSortable_6": "true",
        "sSearch": "",
        "bRegex": "false",
        "iSortCol_0": "0",
        "sSortDir_0": "desc",
        "iSortingCols": "1",
        "_": "1601297445110"
      });
      var r = jsonDecode(resp.data);
      return ISPResponse(true, "Got Logs of $uid successfully.", r['aaData']??[]);
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: Getting Logs of $uid unsuccessful.\n$e\nTRACE: $st");
    }
  }

  Future<ISPResponse> getSessions(uid) async {
    try {
      await checkLogin();
      var resp = await dio.get(getUserSessionsByUIDLink(uid));
      var r = jsonDecode(resp.data);
      return ISPResponse(true, "Got Sessions of $uid successfully.", r['aaData']??[]);
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: Getting Sessions of $uid unsuccessful.\n$e\nTRACE: $st");
    }
  }

  Future<ISPResponse> getFranchiseBalance() async {
    try {
      await checkLogin();
      var resp = await dio.get(GET_FRANCHISE_BALANCE);
      var r = jsonDecode(resp.data);
      balance = r["message"]["franchiseDetails"]["netAccountBalance"];
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      balance = "";
    }
  }

  getCircuitID() async {
    try {
      await checkLogin();
      var resp = await http.get(Uri.parse(GET_CIRCUIT_ID), headers: headers);
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        return "${r['message']['circuitId']}";
      } else {
        return "";
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return "";
    }
  }

  Future<ISPResponse> getPlanProfileID(String groupID) async {
    try {
      await checkLogin();
      var resp = await dio.post(
        GET_PLAN_PROFILE_ID,
        data: {"accountId": "$ENTITY", "userGroupId": "$groupID"},
      );
      var r = jsonDecode(resp.data);
      if (r['status'] == 'success') {
        return ISPResponse(true, "Success", {"profileID": "${r['message'][0]['BillPlan']["id"]}"});
      } else {
        return ISPResponse(
          false,
          "Profile ID setting was unsuccessful.\n${r["message"]}",
          r
    );
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(
        false,
        "Profile ID setting was unsuccessful.\n$e\nTRACE: $st",
        {"error": e}
      );
    }
  }

  Future<ISPResponse> loadPlans() async {
    try {
      await checkLogin();
      await plans_.getCollection();
      plans = plans_.map;
      var resp = await http.get(Uri.parse(GET_CIRCUIT_ID), headers: headers);
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        List groups = r["message"]["userGroupsAll"];
        List allowedGroups = r["message"]["allowedProfile"];
        planNames.clear();
        planKeys.clear();
        for (var group in groups) {
          group = group["UserGroup"];
          if (group["is_active"] && allowedGroups.contains(group["name"])) {
            if (plans_.list.indexWhere((element) => element.name == group["name"]) == -1) {
              var ersp = await getPlanProfileID(group["id"]);
              String profileID = ersp.success?ersp.response["data"]["profileID"]:"";
              Plan newPlan = Plan(
                  active: true,
                  isp: code,
                  groupID: group["id"],
                  profileID: profileID,
                  months: 1,
                  id: Utils.generateId("${code}_plan_"),
                  name: group["name"],
                  title: group["name"],
                  mrp: 0,
                  price: 0);
              await plans_.upsert(newPlan, true, false);
            } else if(plans[group["name"]].profileID == null) {
              var ersp = await getPlanProfileID(group["id"]);
              String profileID = ersp.success?ersp.response["profileID"]:0;
              plans[group["name"]].profileID = profileID;
              await plans_.upsert(plans[group["name"]], false, true);
            }
            planNames.add(plans_.map[group["name"]].title);
          }
        }
        plans = plans_.map;
        planKeys = plans.keys.toList();
        return ISPResponse(true, "Successfully loaded plans", r);
      } else {
        plans = {};
        return ISPResponse(false, "Loading plans unsuccessful.${r["message"]}", r);
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      plans = {};
      return ISPResponse(false, "ERROR: Loading plans unsuccessful.$e", {"error": "$e\n$st"});
    }
  }

  Future<ISPResponse> changeEmail(uid, email) async {
    try {
      await checkLogin();
      var resp = await dio.post(CHANGE_EMAIL, data: {
        "name": "email",
        "pk": uid,
        "accountId": ENTITY,
        "value": email
      });
      var r = jsonDecode(resp.data);
      if (r['status'] == 'success') {
        return ISPResponse(true, "Email of $uid to $email changed Successfully", r);
      } else {
        return ISPResponse(false, "Email of $uid to $email change not successful\n${r["message"]}", r);
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  Future<ISPResponse> upsertPlan(Plan plan, bool edit) async {
    try {
      await plans_.upsert(plan, true, edit);
      plans = plans_.map;
      planNames = List<String>.generate(plans_.list.length, (i) => plans_.list[i].title);
      planKeys = plans.keys.toList();
      return ISPResponse(true, "Successfully Upserted Plan",);
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  Future<ISPResponse> changeUserID(uid, String oldUserID, String newUserID) async {
    try {
      await checkLogin();
      var resp = await dio.post(CHANGE_USER_ID, data: {
        "oldUserNameValue": oldUserID,
        "newUserNameValue": newUserID,
        "changeUsernameAccountId": ENTITY,
        "changeUsernameUserId": uid
      });
      var r = jsonDecode(resp.data);
      if (r['status'] == 'success') {
        return ISPResponse(true, "User ID changed from $oldUserID to $newUserID successfully", r);
      } else {
        return ISPResponse(false, "User ID change from $oldUserID to $newUserID not successful\n${r["message"]}", r);
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  Future<ISPResponse> getBills(uid) async {
    try {
      await checkLogin();
      var resp = await dio.post(getUserBillsByUIDLink(uid));
      String data = resp.data;
      var r = jsonDecode(data);
      if (r['status'] == 'success') {
        return ISPResponse( true, "Got bills of $uid successfully.", jsonDecode(r['message']));
      } else {
        return ISPResponse( false, "Getting bills of $uid unsuccessful.\n${r["message"]}", r);
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  Future<ISPResponse> clearSession(
      id,
      mac,
      username,
      ip) async {
    try {
      var resp = await http.post(UPDATE_AUTH_USER, body: {
        'id[0]': id ?? "",
        'mac[0]': mac ?? "",
        'accountId[0]': '$ENTITY',
        'account_id': '$ENTITY',
        'usernames[0]': username,
        'ips[0]': ip ?? "",
      });
      var r = jsonDecode(resp.body);
      if (r["status"] == "success") {
        return ISPResponse(
            true,
            'Cleared session of $username successfully.',
            r);
      } else {
        return ISPResponse(
            false,
            'Clearing session of $username not successful.\n${r["message"]}',
            r);
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  Future<ISPResponse> resetAppPassword(u) async {
    try {
      String password = "${u['mobile'].length > 6 ? u['mobile'] : '12345678'}";
      password = "12345678";
      var resp = await http.post(UPDATE_AUTH_USER, body: {
        "user_id": u['user_id'],
        "password": password,
        "name": "${u['name']}",
        "uid": "${u['uid']}",
      });
      var r = jsonDecode(resp.body);
      if (r["status"] == "success") {
        return ISPResponse(
            true,
            'Password Update of ${u['user_id']} - ${u['name']} successful.}',
            r);
      } else {
        return ISPResponse(
            false,
            'Password Update of ${u['user_id']} - ${u['name']} was Not Successful.\n${r["message"]}',
            r);
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  Future<bool> checkLogin() async {
    var r;
    try {
      r = await dio.post(USERS_COUNT);
      // r = await http.post(Uri.parse(USERS_COUNT), headers: headers);
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
    }
    if (r == null ||
        r.data.toString() == '' ||
        !r.data.toString().contains('{')) {
      await login();
      return false;
    }
    return true;
  }

  // FIREBASE

  Future<ISPResponse> uploadUser(user) async {
    try {
      var resp = await http.post(CREATE_AUTH_USER, body: {
        "user_id": user['user_id'],
        "password":
            "${user['mobile'].length > 6 ? user['mobile'] : '12345678'}",
        "name": "${user['name']}",
        "uid": "${user['uid']}",
        "network": code,
        "collection": usersCollection
      });
      var jsonBody = jsonDecode(resp.body);
      if (resp.statusCode != 200) {
        return ISPResponse( false, 'Auth Creation of ${user['user_id']} - ${user['name']} was Not Successful\n${jsonBody['msg']}', jsonBody);
      } else {
        netUsers[user['uid']] = {
          'user_id': user['user_id'],
        };
        return ISPResponse( false, 'Auth Creation of ${user['user_id']} - ${user['name']} was Successful\n${jsonBody['msg']}', jsonBody);
      }
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return ISPResponse(false, "ERROR: $e\nTRACE: $st");
    }
  }

  createInvoice(bill) async {
    try {
      await FirebaseFirestore.instance
          .collection(billsCollection)
          .doc(bill["id"])
          .set(bill);
      return {
        "success": true,
        "message":
        'Invoice creation of ${bill['userid']} Successful.',
        "resp": {}
      };
    } catch (e, st) {
      print("ERROR: $e\nTRACE: $st");
      return {
        "success": false,
        "message":
            'Auth Creation of ${bill['userid']} was Not Successful\n$e',
        "resp": {"error": e}
      };
    }
  }
}

class ISPResponse extends Object{
  bool success = false;
  String message = "";
  Map<String, dynamic> response = {};

  ISPResponse([this.success, this.message, data]) {
    this.response = {
      "data": data
    };
  }

}

class Plans extends FirebaseCollection<Plan>{

  Plans(colName) {
    collectionName = colName;
    ref = FirebaseFirestore.instance.collection(collectionName).withConverter<Plan>(
        fromFirestore: (snap, _) => Plan.fromJson(snap.data()),
        toFirestore: (plan, _) => plan.toJson());
  }

}

class Plan {

  bool active;
  String  id,
   name,
   title,
    isp,
    groupID,
    profileID;
  int months,
      mrp,
      price;

  Plan({
    @required this.active,
    @required this.isp,
    @required this.groupID,
    @required this.profileID,
    @required this.months,
    @required this.id,
    @required this.name,
    @required this.title,
    @required this.mrp,
    @required this.price
  });

  factory Plan.fromJson(Map<dynamic, dynamic> i) {
    return Plan(
      id: i["id"]??"",
      isp: i["isp"]??"",
      name: i["name"]??"",
      title: i["title"]??"",
      active: i["active"]??false,
      groupID: i["groupID"],
      profileID: i["profileID"],
      months: i["months"]??1,
      mrp: i["mrp"]??0,
      price: i["price"]??0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "isp": isp,
      "name": name,
      "title": title,
      "active": active,
      "groupID": groupID,
      "profileID": profileID,
      "months": months,
      "mrp": mrp,
      "price": price,
    };
  }
}