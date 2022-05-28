import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class NetUser {
  String uid, userId, address, activationDate, expiryDate, mobile, name, firstName, lastName, createdDate, plan, groupId, email, status, bindedMac, onlineMac, circuitId, installationTime;
  bool isOnline, staticIP;
  Timestamp lastEdit;

  NetUser({
    @required this.uid,
    @required this.userId, @required this.address, @required this.activationDate, @required this.expiryDate, @required this.mobile, @required this.name, @required this.firstName, @required this.lastName, @required this.createdDate, @required this.plan, @required this.groupId, @required this.email, @required this.status, @required this.bindedMac, @required this.onlineMac, @required this.isOnline, @required this.staticIP, @required this.lastEdit, @required this.circuitId, @required this.installationTime});

  factory NetUser.fromJson(Map<dynamic, dynamic> i) {
    return NetUser(
        uid: i['uid'],
        userId: i['user_id'],
        address: i['address'],
        circuitId: i['circuit_id'],
        installationTime: i['installation_time'],
        activationDate: i['activation_time'],
        expiryDate: i['expiry_time'],
        mobile: i['mobile'],
        name: i['name'],
        firstName: i['first_name'],
        lastName: i['last_name'],
        createdDate: i['created_date'],
        plan: i['plan'],
        groupId: i['group_id'],
        email: i['email'],
        status: i['status'],
        bindedMac: i['binded_mac'],
        onlineMac: i['online_mac'],
        isOnline: i['is_online'],
        staticIP: i['static_ip']??false,
        lastEdit: i['last_edit'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "uid": this.uid,
      "user_id": this.userId,
      "address": this.address,
      "activation_date": this.activationDate,
      "expiry_date": this.expiryDate,
      "mobile": this.mobile,
      "name": this.name,
      "first_name": this.firstName,
      "last_name": this.lastName,
      "created_date": this.createdDate,
      "plan": this.plan,
      "group_id": this.groupId,
      "email": this.email,
      "status": this.status,
      "binded_mac": this.bindedMac,
      "online_mac": this.onlineMac,
      "is_online": this.isOnline,
      "static_ip": this.staticIP,
      'last_edit': this.lastEdit,
    };
  }

}
