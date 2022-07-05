import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sumanth_net_admin/utils.dart';

class NetPlans extends StatefulWidget {
  @override
  _NetPlansState createState() => _NetPlansState();
}

class _NetPlansState extends State<NetPlans> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic> plans;
  List keys;
  bool busy = false;
  String viewPlans = "Active";
  int viewPlan = 0;

  @override
  void initState() {
    plans = Utils.isp.plans.map((key, value) => MapEntry(key, value));
    keys = plans.keys.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    keys = plans.map((key, value) => MapEntry(key, value)).keys.toList();
    switch (viewPlan) {
      case 0:
        keys.removeWhere((key) => !(plans[key]['a']??false));
        break;
      case 1:
        keys.removeWhere((key) => (plans[key]['a']??false));
        break;
    }
    return AbsorbPointer(
      absorbing: busy,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Net Plans',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          elevation: 4,
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            setState(() {
                              viewPlans = 'Active';
                              viewPlan = 0;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 1000),
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: viewPlans == 'Active'
                                    ? Colors.black
                                    : Colors.black12),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Active',
                              style: TextStyle(
                                  color: viewPlans == 'Active'
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              viewPlans = 'Inactive';
                              viewPlan = 1;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 1000),
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: viewPlans == 'Inactive'
                                    ? Colors.black
                                    : Colors.black12),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                  color: viewPlans == 'Inactive'
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              viewPlans = 'All';
                              viewPlan = 2;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 1000),
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: viewPlans == 'All'
                                    ? Colors.black
                                    : Colors.black12),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'All',
                              style: TextStyle(
                                  color: viewPlans == 'All'
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: List<Widget>.generate(
                keys.length,
                (i) => Container(
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              horizontal:
                                  BorderSide(color: Colors.black26, width: 1))),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          radius: 8,
                          backgroundColor: plans[keys[i]]['a']
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(
                          '${plans[keys[i]]['n']}',
                          style: TextStyle(
                              fontSize: 14, decoration: TextDecoration.underline),
                        ),
                        subtitle: RichText(text: TextSpan(
                          text: '${plans[keys[i]]['m']} ${plans[keys[i]]['m'] == 1 ? "Month" : "Months"} - ',
                          style: TextStyle(fontSize: 12,color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Rs.${plans[keys[i]]['r']}, ',
                              style: TextStyle(decoration: TextDecoration.lineThrough,decorationColor: Colors.red,),
                            ),
                            TextSpan(
                              text: 'Rs.${plans[keys[i]]['sr']}, ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ]
                        )),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Wrap(
                              spacing: 5,
                              direction: Axis.horizontal,
                              children: [
                                FlatButton(
                                  color: Colors.lightBlue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8)),
                                  onPressed: () {
                                    changePrice(plans[keys[i]]);
                                  },
                                  child: Text(
                                    'Edit Price',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  splashColor: Colors.black12,
                                ),
                                FlatButton(
                                  color: plans[keys[i]]['a']?Colors.redAccent[100]:Colors.lightGreenAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8)),
                                  onPressed: () {
                                    changeAvailability(plans[keys[i]]);
                                  },
                                  child: Text(
                                    plans[keys[i]]['a']?'Deactivate':'Activate',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  splashColor: Colors.black12,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
          ),
        ),
      ),
    );
  }

  changePrice(plan) async {
    if (await showdialog(
        'Change Price', 'Do you want to change price of ${plan['n']}')??false) {
      var r = await _showPriceDialog('New Price',plan['r'],plan['sr'])??[false];
      if (r[0]??false) {
        setState(() {
          busy = true;
        });
        Utils.showLoadingDialog(context, 'Loading');
        await FirebaseFirestore.instance.collection('data').doc('net').update({
          'plans.${plan['n']}.r': int.parse(r[1]),
          'plans.${plan['n']}.sr': int.parse(r[2]),
        }).then((value) {
          Utils.isp.plans[plan['n']]['r'] = int.parse(r[1]);
          Utils.isp.plans[plan['n']]['sr'] = int.parse(r[2]);
          plans[plan['n']]['r'] = int.parse(r[1]);
          plans[plan['n']]['sr'] = int.parse(r[2]);
          Navigator.pop(context);
        }).catchError((_){
          Navigator.pop(context);
        });
        setState(() {
          busy = false;
        });
      }
    }
  }

  changeAvailability(plan) async {
    setState(() {
      busy = true;
    });
    Utils.showLoadingDialog(context, 'Loading');
    await FirebaseFirestore.instance.collection('data').doc('net').update({
      'plans.${plan['n']}.a': !plan['a']
    }).then((value) {
      Utils.isp.plans[plan['n']]['a'] = !plan['a'];
      plans = Utils.isp.plans.map((key, value) => MapEntry(key, value));
      keys = plans.keys.toList();
      Navigator.pop(context);
    }).catchError((e){
      print("ERROR: $e");
      Navigator.pop(context);
    });
    setState(() {
      busy = false;
    });
  }

  Future<List> _showPriceDialog(String title, mrp, price) {
    TextEditingController priceFieldController = new TextEditingController(text: "$price");
    TextEditingController mrpFieldController = new TextEditingController(text: "$mrp");
    GlobalKey<FormState> formKey = new GlobalKey<FormState>();
    String newPrice = "$price";
    String newMrp = "$mrp";
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: mrpFieldController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "MRP"),
                  onChanged: (v){
                    newMrp = v;
                  },
                  validator: (v) {
                    if (v.length == 0) {
                      return 'Please enter mrp';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 8,),
                TextFormField(
                  controller: priceFieldController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  onChanged: (v){
                    newPrice = v;
                  },
                  decoration: InputDecoration(labelText: "Price"),
                  validator: (v) {
                    if (v.length == 0) {
                      return 'Please enter price';
                    } else if(int.parse(newPrice)>int.parse(newMrp)){
                      return 'Price must be greater than or equal to MRP';
                    }else {
                      return null;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop([false, "${mrp}", "${price}"]);
              },
            ),
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                if (formKey.currentState.validate()) {
                  Navigator.of(context).pop([true, "${newMrp}", "${newPrice}"]);
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
}
