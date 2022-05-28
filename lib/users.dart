import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:sumanth_net_admin/edit_user.dart';
import 'package:sumanth_net_admin/otp_verification.dart';
import 'package:sumanth_net_admin/sessions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'add_user.dart';
import 'renew.dart';
import 'user_bills.dart';
import 'user_logs.dart';
import 'utils.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String search = '', viewUsers = 'Active';
  bool busy = false, loaded = true;
  List<dynamic> users = [];
  List categories = ['Active', 'Online', 'Not Online', 'Expired', 'All'],
      sortKeys = [["UserID", "user_id"], ["Name", "name"], ["Expiry Date", "expiry_date"], ["Creation", "uid"], ["Activation Date", "activation_date"]];
  int viewUser = 0;
  var body = {};
  String sortKey = "user_id";
  bool sortIn = true; // true - Ascending, false - Descending

  TextEditingController search_controller = new TextEditingController();

  TextEditingController emailFieldController = new TextEditingController();

  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  http.Response res;

  ScrollController scroll_controller = new ScrollController();

  TextStyle editStyle = TextStyle(color: Colors.blue, fontSize: 12);

  @override
  void initState() {
    super.initState();
    // getUsers();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      changeUsersCat();
    });
  }

  @override
  void dispose() {
    scroll_controller.dispose();
    super.dispose();
  }

  getUsers() async {
    setState(() {
      loaded = false;
    });
    await Utils.getUsers(context);
    setState(() {
      loaded = true;
    });
    changeUsersCat();
  }

  setPage(int i) {
    List l = ['Active', 'Online', 'Not Online', 'Expired', 'All'];
    if (i >= 0 && i < l.length) {
      setState(() {
        viewUsers = l[i];
        viewUser = i;
      });
    } else if (i < 0) {
      setState(() {
        viewUsers = l[l.length - 1];
        viewUser = l.length - 1;
      });
    } else {
      setState(() {
        viewUsers = l[0];
        viewUser = 0;
      });
    }
    changeUsersCat();
  }

  changeUsersCat() async {
    users = Utils.users.sublist(0);
    if (viewUsers != 'All') {
      if (viewUsers == 'Online') {
        users = users.where((e) {
          return (e['is_online']);
        }).toList();
      } else if (viewUsers == 'Not Online') {
        users = users.where((e) {
          return (!e['is_online'] && e['status'] == 'active');
        }).toList();
      } else {
        users = users.where((e) {
          return (e['status'] == viewUsers.toLowerCase());
        }).toList();
      }
    }
    if(["name", "user_id", "uid"].contains(sortKey)) {
      users.sort((a, b) {
        if(sortIn) {
          var t = a;
          a = b;
          b = t;
        }
        if(sortKey == "uid") {
          return int.parse(b[sortKey]) - int.parse(a[sortKey]);
        } else if(b[sortKey].runtimeType == "".runtimeType) {
          return b[sortKey].toLowerCase().compareTo(a[sortKey].toLowerCase());
        } else if(b[sortKey].runtimeType == 1.runtimeType) {
          return b[sortKey] - a[sortKey];
        } else {
          return b[sortKey].toString().compareTo(a[sortKey].toString());
        }
      },);
    } else if(["expiry_date", "activation_date"].contains(sortKey)) {
      users.sort((a, b) {
        if(sortIn) {
          var t = a;
          a = b;
          b = t;
        }
        if(b[sortKey].runtimeType == "".runtimeType) {
          List split = a[sortKey].toString().split("/");
          String atime = "${split[2]}${split[1]}${split[0]}";
          split = b[sortKey].toString().split("/");
          String btime = "${split[2]}${split[1]}${split[0]}";
          return btime.compareTo(atime);
        } else {
          return b[sortKey].toString().compareTo(a[sortKey].toString());
        }
      },);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: busy,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onVerticalDragEnd: (d) {
          if (d.primaryVelocity > 0) {
            getUsers();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            title: Text(
              'Users',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w600),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(80),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: <
                      Widget>[
                SizedBox(
                  height: 2,
                ),
                Container(
                   width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      SizedBox(width: 4,),
                      Flexible(
                        child: TextField(
                          controller: search_controller,
                          maxLines: 1,
                          textInputAction: TextInputAction.search,
                          onChanged: (s) {},
                          onSubmitted: (v) {
                            setState(() {
                              search = v;
                            });
                          },
                          decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    search_controller.text = '';
                                    search = '';
                                  });
                                },
                                child: Icon(
                                  Icons.clear,
                                  color: search == '' ? Colors.white : Colors.black,
                                  size: 16,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.black)),
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 0),
                              labelText: 'Search',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.black)),
                              fillColor: Colors.white),
                        ),
                      ),
                      InkWell(
                        onTap: () {

                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.filter_list_alt),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          sortPopUp();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.sort),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List<Widget>.generate(
                          categories.length,
                          (c) => InkWell(
                              onTap: () {
                                setState(() {
                                  viewUsers = categories[c];
                                  viewUser = c;
                                  changeUsersCat();
                                });
                              },
                              child: AnimatedContainer(
                                  duration: Duration(milliseconds: 1000),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: viewUsers == categories[c]
                                          ? Colors.black
                                          : Colors.black12),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: RichText(
                                      text: TextSpan(
                                          text: "",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                              fontSize: 12,
                                              color: viewUsers == categories[c]
                                                  ? Colors.white
                                                  : Colors.black),
                                          children: [
                                        TextSpan(
                                            text:
                                                "${Utils.usersCatCount[categories[c]]}",
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: " ${categories[c]}",)
                                      ])))),
                        )),
                  ),
                ),
              ]),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () async {
                    getUsers();
                  },
                  child: Text(
                    'Reload',
                    style: TextStyle(color: Colors.blue),
                  ))
            ],
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          backgroundColor: Colors.white,
          body: GestureDetector(
            onHorizontalDragEnd: (d) {
              if (d.primaryVelocity < 0) {
                setPage(viewUser + 1);
              } else {
                setPage(viewUser - 1);
              }
            },
            child: Container(
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Utils.users.length != 0
                          ? ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              controller: scroll_controller,
                              itemCount: users.length,
                              itemBuilder: (c, index) {
                                var user = users[index];
                                return user
                                        .toString()
                                        .toLowerCase()
                                        .contains(search.toLowerCase())
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border(
                                                left: BorderSide(
                                                    color: user['status'] ==
                                                            'active'
                                                        ? Colors
                                                            .lightGreenAccent
                                                        : Colors.redAccent[100],
                                                    width: 6))),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: ExpansionTile(
                                          title: Text(user['user_id']),
                                          subtitle: Text(
                                            user['name'],
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          leading: CircleAvatar(
                                            radius: 10,
                                            backgroundColor: Colors.white,
                                            child: CircleAvatar(
                                              radius: 8,
                                              backgroundColor: user['is_online']
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'UID: ${user['uid']}',
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                      maxLines: 1,
                                                    )),
                                                InkWell(
                                                  onTap: () {
                                                    editUser(user);
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8),
                                                    child: Text(
                                                      'Edit',
                                                      style: editStyle,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    'Created On: ${user['created_date']}',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    maxLines: 1)),
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    'Address: ${user['address']}',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    maxLines: 1)),
                                            InkWell(
                                              onTap: () {
                                                callUser(user['mobile']);
                                              },
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      'Mobile: ${user['mobile']}',
                                                      maxLines: 1,
                                                      style: editStyle)),
                                            ),
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    'Email: ${user['email']}',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    maxLines: 1)),
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    'Plan: ${user['plan']}',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    maxLines: 1)),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                  '${user['activation_date']} to ${user['expiry_date']}',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                  maxLines: 1),
                                            ),
                                            if (user['binded_mac'] != '')
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      'Mac binded to : ${user['binded_mac']}',
                                                      style: TextStyle(
                                                          fontSize: 12))),
                                            if (user['status'] == 'otppending')
                                              Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: InkWell(
                                                      onTap: () async {
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      SendOtp(
                                                                user: user,
                                                              ),
                                                            ));
                                                        getUsers();
                                                      },
                                                      child: Text(
                                                        'Verify OTP',
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                      ))),
                                            Divider(
                                              color: Colors.black,
                                              thickness: 1,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                getSessions(user);
                                              },
                                              child: Align(
                                                  alignment: user['is_online']
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                                  child: Text(
                                                    'Sessions',
                                                    style: editStyle,
                                                  )),
                                            ),
                                            if (!user['is_online'])
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      'Last Online Mac : ${user['online_mac']}',
                                                      style: TextStyle(
                                                          fontSize: 12))),
                                            if (user['is_online'])
                                              Column(
                                                children: <Widget>[
                                                  Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        'Online Mac : ${user['online_mac']}',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      )),
                                                  Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                          'Device : ${user['mac_vendor']}',
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 12))),
                                                  Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                          'Downloaded : ${(int.parse(user['downloaded']??"0")/(1024*1024*1024)).toStringAsFixed(2)} GB - Uploaded : ${(int.parse(user['uploaded']??"0")/(1024*1024*1024)).toStringAsFixed(2)} GB',
                                                          style: TextStyle(
                                                              fontSize: 12))),
                                                  Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                          'Start Time : ${user['start_time']} - Duration : ${user['duration']}',
                                                          style: TextStyle(
                                                              fontSize: 12))),
                                                ],
                                              ),
                                            Wrap(
                                              alignment: WrapAlignment.center,
                                              spacing: 8,
                                              children: <Widget>[
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    renewUser(user);
                                                  },
                                                  child: Text(
                                                    'Renew',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    changeEmail(user);
                                                  },
                                                  child: Text(
                                                    'Change Email',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.white,
                                                  ),
                                                  onPressed: () =>
                                                      resetPassword(user),
                                                  child: Text(
                                                    'Reset Password',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                if (user['binded_mac'] == '')
                                                  ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        macBind(user);
                                                      },
                                                      child: Text(
                                                        'Mac Bind',
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 10,
                                                        ),
                                                      )),
                                                if (user['binded_mac'] != '')
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      removeBind(user);
                                                    },
                                                    child: Text(
                                                      'Remove Bind',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    getLogs(user);
                                                  },
                                                  child: Text(
                                                    'Logs',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                if (user['is_online'])
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      clearSession(
                                                          user[
                                                              'user_session_id'],
                                                          user['online_mac'],
                                                          user['user_id'],
                                                          user['ip']);
                                                    },
                                                    child: Text(
                                                      'Clear Session',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    getBills(user);
                                                  },
                                                  child: Text(
                                                    'Bills',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    resetAppPassword(user);
                                                  },
                                                  child: Text(
                                                    'Reset App Password',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.white,
                                                  ),
                                                  onPressed: () async {
                                                    String text =
                                                        "App Link: bit.ly/PaymentS-nac\n\nUsername: ${user['user_id']}\nPassword: ${user['mobile']}\n\nThank you.";
                                                    await Share.share(text);
                                                  },
                                                  child: Text(
                                                    'Share App',
                                                    style: TextStyle(
                                                      color: Colors.deepOrange,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.white,
                                                  ),
                                                  onPressed: () async {
                                                    String text =
                                                        "User ID: ${user["user_id"]}\nName: ${user["name"]}\nPhone: ${user["mobile"]}\nEmail: ${user["email"]}\nAddress: ${user["address"]}\nPlan: ${user["plan"]}";
                                                    await Share.share(text);
                                                  },
                                                  child: Text(
                                                    'Share User',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container();
                              },
                            )
                          : Center(child: Text(loaded ? 'No Users' : ''))),
                  if (busy) Center(child: CircularProgressIndicator()),
                  if (!loaded) LinearProgressIndicator(),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
                      child: InkWell(
                        onTap: () {
                          scroll_controller.animateTo(0,
                              duration: Duration(microseconds: 800),
                              curve: Curves.fastLinearToSlowEaseIn);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 28.5,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.arrow_upward),
                            radius: 28,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddUser(),
                  ));
            },
            backgroundColor: Colors.white,
            child: Icon(
              Icons.add,
              size: 24,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  sortPopUp() async {
    showDialog(context: context, builder: (_) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(vertical: 128, horizontal: 64),
        child: StatefulBuilder(
          builder: (context, setDState) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: (){setDState(() {
                        sortIn = true;
                      });},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("A-Z", style: TextStyle(color: sortIn?Colors.blue:Colors.black, fontWeight: sortIn?FontWeight.w800:FontWeight.w500, fontSize: 16),),
                      ),
                    ),
                    InkWell(
                      onTap: (){setDState(() {
                        sortIn = false;
                      });},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Z-A", style: TextStyle(color: !sortIn?Colors.blue:Colors.black, fontWeight: !sortIn?FontWeight.w800:FontWeight.w500, fontSize: 16),),
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.black, thickness: 2, height: 1,)
              ]+List<Widget>.generate(sortKeys.length, (i) {
                var sk = sortKeys[i];
                return InkWell(
                  onTap: (){setDState(() {
                    sortKey = sk[1];
                  });},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${sk[0]}", style: TextStyle(color: sortKey == sk[1]?Colors.blue:Colors.black, fontWeight: sortKey == sk[1]?FontWeight.w800:FontWeight.w500, fontSize: 18),),
                  ),
                );
              })+[TextButton(onPressed: (){Navigator.pop(context);changeUsersCat();}, child: Text("Ok"))],
            ),
          ),
        ),
      );
    });
  }

  resetPassword(user) async {
    if (await showdialog('Reset Password',
        'Do you want to reset password of ${user['user_id']}')) {
      var r = await _showPasswordDialog("Enter New Password", "12345678") ??
          [false];
      if (r[0] ?? false) {
        setState(() {
          busy = true;
        });
        await Utils.checkLogin();
        var resp = await http.post(Utils.RESET_PASSWORD,
            body: {
              "userId": user['uid'],
              "currentId": "022825sumanthanetworks",
              "type": "pppoe",
              "resetType": "resetManually",
              "password": "12345678",
              "sendSMS": "true",
              "sendWhatsapp": "true",
              "sendEmail": "true"
            },
            headers: Utils.headers);
        if (jsonDecode(resp.body)['status'] == 'success') {
          _showSuccessDialog('Successful',
              'Password Reset of ${user['user_id']} - ${user['name']} Successful');
        } else {
          _showErrorDialog('Error',
              'Password Reset of ${user['user_id']} - ${user['name']} was Not Successful');
        }
        setState(() {
          busy = false;
        });
      }
    }
  }

  renewUser(user) async {
    if (await showdialog('Renew', 'Do you want to renew ${user['user_id']}?')) {
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Renew(
              user: user,
            ),
          ));
      getUsers();
    }
  }

  getLogs(user) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserLogs(
            user: user,
          ),
        ));
  }

  getBills(user) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserBills(
            user: user,
          ),
        ));
  }

  getSessions(user) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Sessions(
            user: user,
          ),
        ));
  }

  editUser(user) async {
    if (await showdialog(
        'Edit User', 'Do you want to edit ${user['user_id']}?')) {
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditUser(
              user: user,
            ),
          ));
      getUsers();
    }
  }

  callUser(mobile) async {
    if (await canLaunch('tel:${mobile}')) {
      await launch('tel:${mobile}');
    } else {
      throw 'Could not launch tel:${mobile}';
    }
  }

  changeEmail(user) async {
    if (await showdialog(
        'Change Email', 'Do you want to change email of ${user['user_id']}')) {
      if (await _showEmailDialog('Enter New Email', user['email'])) {
        setState(() {
          busy = true;
        });
        await Utils.checkLogin();
        var resp = await http.post(Utils.CHANGE_EMAIL,
            body: {
              "name": "email",
              "pk": user['uid'],
              "accountId": "022825sumanthanetworks",
              "value": emailFieldController.text
            },
            headers: Utils.headers);
        if (jsonDecode(resp.body)['status'] == 'success') {
          _showSuccessDialog('Successful',
              'Email change of ${user['user_id']} - ${user['name']} Successful');
        } else {
          _showErrorDialog('Error',
              'Email change of ${user['user_id']} - ${user['name']} was Not Successful\n${jsonDecode(resp.body)['message']}');
        }
        setState(() {
          busy = false;
        });
      }
      getUsers();
    }
  }

  macBind(user) async {
    if (await showdialog(
            'Mac Bind', 'Do you want to mac bind ${user['user_id']}') ??
        false) {
      setState(() {
        busy = true;
      });
      await Utils.checkLogin();
      var resp = await http.post(Utils.EDIT_USER,
          body: {
            "userId": user['uid'],
            "account": "022825sumanthanetworks",
            "userName": user['user_id'],
            "firstName": user['first_name'],
            "lastName": user['last_name'],
            "userGroupId": "${Utils.plans[user['plan']]['g']}",
            "userPlanId": "${Utils.plans[user['plan']]['p']}",
            "phoneNumber": user['mobile'],
            "emailId": user['email'],
            "address_line1": user['address'],
            "address_line2": "Ptc",
            "address_city": "Hyderabad",
            "address_pin": "502319",
            "address_state": "Telangana",
            "password": "",
            "overrideAmount": "",
            "overrideAmountBasedOn": "withTax",
            "enterOTPDisplay": "yes",
            "tempPhone": "",
            "altPhoneNumber": "",
            "altEmailId": "",
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
            "staticIpBoundMac[]": user['online_mac'],
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
          },
          headers: Utils.headers);
      // print(user['online_mac']);
      if (jsonDecode(resp.body)['status'] == 'success') {
        _showSuccessDialog('Successful',
            'Mac Bind of ${user['user_id']} - ${user['name']} Successful');
      } else {
        _showErrorDialog('Error',
            'Mac Bind of ${user['user_id']} - ${user['name']} was Not Successful\n${jsonDecode(resp.body)['message']}');
      }
      setState(() {
        busy = false;
      });
      getUsers();
    }
  }

  removeBind(user) async {
    if (await showdialog('Remove Mac Bind',
        'Do you want to remove mac bind of ${user['user_id']}')) {
      setState(() {
        busy = true;
      });
      await Utils.checkLogin();
      var resp = await http.post(Utils.EDIT_USER,
          body: {
            "userId": user['uid'],
            "account": "022825sumanthanetworks",
            "userName": user['user_id'],
            "firstName": user['first_name'],
            "lastName": user['last_name'],
            "userGroupId": user['group_id'],
            "phoneNumber": user['mobile'],
            "emailId": user['email'],
            "address_line1": user['address'],
            "address_line2": "Ptc",
            "address_city": "Hyderabad",
            "address_pin": "502319",
            "address_state": "Telangana",
            "staticIpBoundMac[]": ""
          },
          headers: Utils.headers);
      if (jsonDecode(resp.body)['status'] == 'success') {
        _showSuccessDialog('Successful',
            'Remove Bind of ${user['user_id']} - ${user['name']} Successful');
      } else {
        _showErrorDialog('Error',
            'Remove Bind of ${user['user_id']} - ${user['name']} was Not Successful\n${jsonDecode(resp.body)['message']}');
      }
      setState(() {
        busy = false;
      });
      getUsers();
    }
  }

  clearSession(
    id,
    mac,
    username,
    ip,
  ) async {
    setState(() {
      busy = true;
    });
    await Utils.checkLogin();
    var res =
        await http.post(Utils.REMOVE_SESSION, headers: Utils.headers??{}, body: {
      'id[0]': id??"",
      'mac[0]': mac??"",
      'accountId[0]': '022825sumanthanetworks',
      'account_id': '022825sumanthanetworks',
      'usernames[0]': username,
      'ips[0]': ip??"",
    });
    // print(res.body);
    setState(() {
      busy = false;
    });
    if (jsonDecode(res.body)['status'] == 'success') {
      getUsers();
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(
                  'Error',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                elevation: 0,
              ),
              body: WebView(
                debuggingEnabled: false,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (c) {
                  c.loadUrl(Uri.dataFromString(jsonDecode(res.body)['message'],
                          mimeType: 'text/html')
                      .toString());
                },
              ),
            ),
          ));
    }
  }

  resetAppPassword(u) async {
    Utils.showLoadingDialog(context, "Loading");
    String password = "${u['mobile'].length > 6 ? u['mobile'] : '12345678'}";
    var resp = await http.post(Utils.UPDATE_AUTH_USER, body: {
      "user_id": u['user_id'],
      "password": password,
      "name": "${u['name']}",
      "uid": "${u['uid']}",
    });
    Navigator.pop(context);
    // print(resp.body);
    if (resp.statusCode != 200) {
      Utils.showErrorDialog(context, 'Error',
          'Password Update of ${u['user_id']} - ${u['name']} was Not Successful\n${jsonDecode(resp.body)}');
    } else {
      _showSuccessDialog('Done',
          'Password Update of ${u['user_id']} was Successful with $password');
    }
  }

  Future<bool> _showEmailDialog(String title, String email) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: emailFieldController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Email"),
              validator: (v) {
                Pattern pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regex = new RegExp(pattern);
                if (v.length == 0) {
                  return 'Please enter email id';
                } else {
                  if (v == email) {
                    return 'Old email is same';
                  } else {
                    if (!regex.hasMatch(v)) {
                      return 'Enter valid email';
                    } else {
                      return null;
                    }
                  }
                }
              },
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                if (formKey.currentState.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<List> _showPasswordDialog(String title, String password) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        var passwordFieldController = new TextEditingController(text: password);
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: passwordFieldController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(labelText: "Password"),
              validator: (v) {
                if (v.length == 0) {
                  return 'Please enter password';
                } else if (v.length < 0) {
                  return 'Please enter password with 8 chars';
                } else {
                  return null;
                }
              },
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop([false, "12345678"]);
              },
            ),
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                if (formKey.currentState.validate()) {
                  Navigator.of(context)
                      .pop([true, passwordFieldController.text]);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> showdialog(String title, String message) {
    FocusScope.of(context).unfocus();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(true);
                return true;
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: Colors.green),
          ),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: Colors.red),
          ),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}