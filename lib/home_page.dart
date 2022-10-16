// import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'isp/jaze_isp.dart';
import 'main.dart';
import 'utils.dart';

class HomePage extends StatefulWidget {

  final List<Widget> widgets;
  final List<List> widgetsDetails;
  final Function(int) _onItemTapped;

  const HomePage(this.widgets, this.widgetsDetails, this._onItemTapped, {Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState(this.widgets, this.widgetsDetails, this._onItemTapped);
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{

  final List<Widget> _widgetOptions;
  final List<List> _widgetDetails;
  final Function(int) _onItemTapped;

  int activeUsers = 0, onlineUsers = 0;
  bool gettingCount = false;

  _HomePageState(this._widgetOptions, this._widgetDetails, this._onItemTapped);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {getCount();});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ));
              },
              child: Text(
                'Sign Out',
                style: TextStyle(color: Colors.blue),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Active : $activeUsers'),
                    Text('Online : $onlineUsers'),
                    Text('Balance : \u20b9${Utils.isp.balance}'),
                    if(gettingCount)
                      Container(width: 10, height: 10, child: CircularProgressIndicator()),
                    if(!gettingCount)
                      InkWell(onTap: () {
                        getCount();
                      },child: Container(child: Icon(Icons.refresh, size: 18,))),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                margin:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                              Utils.changeISP("rvr");
                              getCount();
                            });
                          },
                          child: Text(
                            "RVR",
                            style: TextStyle(
                                color:
                                Utils.ispCode == "rvr" ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                              primary:Utils.ispCode != "rvr" ? Colors.black : Colors.white),
                        )),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              Utils.changeISP("ssc");
                              getCount();
                            });
                          },
                          child: Text(
                            "SSC",
                            style: TextStyle(
                                color:
                                Utils.ispCode == "ssc" ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                              primary:Utils.ispCode != "ssc" ? Colors.black : Colors.white),
                        )),
                  ],
                ),
              ),
            ] +
                List.generate(_widgetDetails.length - 1, (i) {
                  i += 1;
                  return InkWell(
                    onTap: () {
                      _onItemTapped(i);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        '${_widgetDetails[i][2]}',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                })),
      )
    );
  }

  getCount() async {
    setState(() {
      gettingCount = true;
    });
    ISPResponse ispResponse = await Utils.isp.getUsersCount();
    var resp = ispResponse.response["data"];
    if(ispResponse.success) {
      activeUsers = resp["res"]['active'];
      onlineUsers = resp["res"]['online'];
    }
    await Utils.isp.getFranchiseBalance();
    setState(() {
      gettingCount = false;
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
