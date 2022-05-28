import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumanth_net_admin/utils.dart';

class Coupons extends StatefulWidget {
  @override
  _CouponsState createState() => _CouponsState();
}

class _CouponsState extends State<Coupons> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  bool busy = false;
  List keys;
  int viewCoupon = 0;
  List<dynamic> coupons, viewCoupons;

  @override
  void initState() {
    coupons = Utils.coupons;
    viewCoupons = coupons.where((e) => e['a']).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: busy,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Coupons',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  reload();
                },
                child: Text("Reload"))
          ],
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
                              viewCoupon = 0;
                              viewCoupons =
                                  coupons.where((e) => e['a']).toList();
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 1000),
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: viewCoupon == 0
                                    ? Colors.black
                                    : Colors.black12),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Active',
                              style: TextStyle(
                                  color: viewCoupon == 0
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              viewCoupon = 1;
                              viewCoupons =
                                  coupons.where((e) => !e['a']).toList();
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 1000),
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: viewCoupon == 1
                                    ? Colors.black
                                    : Colors.black12),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                  color: viewCoupon == 1
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              viewCoupon = 2;
                              viewCoupons = coupons.sublist(0);
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 1000),
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: viewCoupon == 2
                                    ? Colors.black
                                    : Colors.black12),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'All',
                              style: TextStyle(
                                  color: viewCoupon == 2
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
                viewCoupons.length,
                (i) => Container(
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              horizontal:
                                  BorderSide(color: Colors.black26, width: 1))),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 8,
                          backgroundColor:
                              viewCoupons[i]['a'] ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          '${viewCoupons[i]['c']}',
                          style: TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          '${viewCoupons[i]['u'].length} users - ${viewCoupons[i]['p'].length} plans',
                          style: TextStyle(fontSize: 14),
                        ),
                        onTap: () async {
                          await Navigator.push(context, Utils.createRoute(AddCoupon(coupon: viewCoupons[i], viewOnly: true,), Utils.DTU));
                          reload();
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.control_point_duplicate_rounded,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                                onPressed: () async {
                                  Utils.showLoadingDialog(context, "Loading");
                                  var newCoup = {};
                                  newCoup.addAll(viewCoupons[i]);
                                  newCoup['id'] = Utils.generateId("coup_");
                                  await FirebaseFirestore.instance.collection("data").doc("net").update(
                                      {"viewCoupons.${newCoup['id']}":newCoup}).catchError((e){});
                                  Navigator.pop(context);
                                  reload();
                                }),
                            IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                                onPressed: () async {
                                  print(1);
                                  await Navigator.push(
                                      context,
                                      Utils.createRoute(
                                          AddCoupon(
                                            coupon: viewCoupons[i],
                                          ),
                                          Utils.RTL));
                                  reload();
                                }),
                          ],
                        ),
                      ),
                    )),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCoupon(),
                ));
            reload();
          },
          backgroundColor: Colors.amber,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  reload() async {
    Utils.showLoadingDialog(context, "Loading");
    var r =
        await FirebaseFirestore.instance.collection("data").doc("net").get();
    coupons = r.data()['coupons'].values.toList();
    Utils.coupons = coupons.sublist(0);
    if(viewCoupon == 0){
      viewCoupons = coupons.where((e) => e['a']).toList();
    } else if(viewCoupon==1){
      viewCoupons = coupons.where((e) => !e['a']).toList();
    } else {
      viewCoupons = coupons.sublist(0);
    }
    setState(() {});
    Navigator.pop(context);
  }
}

class AddCoupon extends StatefulWidget {
  final Map coupon;
  final bool viewOnly;

  const AddCoupon({Key key, this.coupon, this.viewOnly}) : super(key: key);

  @override
  _AddCouponState createState() => _AddCouponState(this.coupon, this.viewOnly??false);
}

class _AddCouponState extends State<AddCoupon> {
  bool busy = false;
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  Map coupon;
  final bool viewOnly;

  TextEditingController codeFieldController,
      descriptionFieldController,
      priceFieldController;

  _AddCouponState(this.coupon, this.viewOnly);

  @override
  void initState() {
    if (coupon == null) {
      coupon = {
        "id": Utils.generateId("coup_"),
        "a": true,
        "c": "",
        "d": "",
        "di": 0,
        "f": true,
        "p": [],
        "u": []
      };
    }
    codeFieldController = new TextEditingController(text: "${coupon['c']}");
    descriptionFieldController =
        new TextEditingController(text: "${coupon['d']}");
    priceFieldController = new TextEditingController(text: "${coupon['di']}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: busy,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Add Coupon',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          actions: [
            if(!viewOnly)
            TextButton(
                onPressed: () async {
                  if (formKey.currentState.validate()) {
                    Utils.showLoadingDialog(context, "Loading");
                    await FirebaseFirestore.instance
                        .collection("data")
                        .doc("net")
                        .update({"coupons.${coupon['id']}": coupon});
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
                child: Text("Save")),
            if(viewOnly)
            TextButton(
                onPressed: () async {
                  await Navigator.push(context, Utils.createRoute(AddCoupon(coupon: coupon,), Utils.RTL));
                  Navigator.pop(context);
                },
                child: Text("Edit"))
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: codeFieldController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          enabled: !viewOnly,
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.white)),
                          labelStyle: TextStyle(color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          labelText: 'Coupon Code',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          fillColor: Colors.white),
                      onChanged: (v) {
                        coupon['c'] = v.toUpperCase();
                      },
                      validator: (v) {
                        if (v.isEmpty) {
                          return 'Cant be empty';
                        }
                        coupon['c'] = v.toUpperCase();
                        return null;
                      },
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  InkWell(
                    onTap: () async {
                        coupon['p'] = await Navigator.push(
                                context,
                                Utils.createRoute(
                                    SelectPlans(
                                        selectedPlans:
                                            coupon['p'].toList().sublist(0),viewOnly: viewOnly,),
                                    Utils.DTU)) ??
                            coupon['p'];
                        setState(() {});
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      margin: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Plans',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${coupon['p'].length}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 24,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List<Widget>.generate(
                                    coupon['p'].length, (i) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.lightBlue,
                                        borderRadius:
                                            BorderRadius.circular(3000)),
                                    child: Text(
                                      "${coupon['p'][i]}",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                        coupon['u'] = await Navigator.push(
                                context,
                                Utils.createRoute(
                                    SelectUsers(
                                        selectedUsers:
                                            coupon['u'].toList().sublist(0),viewOnly: viewOnly,),
                                    Utils.DTU)) ??
                            coupon['u'];
                        setState(() {});
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Users',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${coupon['u'].length}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 24,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List<Widget>.generate(
                                    coupon['u'].length, (i) {
                                  var user = Utils.usersMap[coupon['u'][i]];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.lightBlue,
                                        borderRadius:
                                            BorderRadius.circular(3000)),
                                    child: Text(
                                      "${user['user_id']}",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          )
                        ],
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
                            if (!viewOnly) {
                              setState(() {
                                coupon['f'] = !coupon['f'];
                              });
                            }
                          },
                          child: Text(
                            "Flat",
                            style: TextStyle(
                                color:
                                    coupon['f'] ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                              primary:
                                  !coupon['f'] ? Colors.black : Colors.white),
                        )),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () async {
                            if (!viewOnly) {
                              setState(() {
                                coupon['f'] = !coupon['f'];
                              });
                            }
                          },
                          child: Text(
                            "Percentage",
                            style: TextStyle(
                                color:
                                    !coupon['f'] ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                              primary:
                                  coupon['f'] ? Colors.black : Colors.white),
                        )),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      controller: priceFieldController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        if (v.length != 0) coupon['di'] = int.parse(v);
                      },
                      validator: (v) {
                        if (v.isEmpty) {
                          return 'Cant be empty';
                        }
                        coupon['di'] = int.parse(v);
                        return null;
                      },
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          labelStyle: TextStyle(color: Colors.black),
                          enabled: !viewOnly,
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.white)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          labelText: 'Discount',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          fillColor: Colors.white),
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      controller: descriptionFieldController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) {
                        coupon['d'] = v;
                      },
                      validator: (v) {
                        coupon['d'] = v;
                        return null;
                      },
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          enabled: !viewOnly,
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.white)),
                          labelStyle: TextStyle(color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          labelText: 'Description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          fillColor: Colors.white),
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectPlans extends StatefulWidget {
  final List<dynamic> selectedPlans;
  final bool viewOnly;

  SelectPlans({Key key, @required this.selectedPlans, this.viewOnly}) : super(key: key);

  @override
  _SelectPlans createState() => _SelectPlans(this.selectedPlans, this.viewOnly??false);
}

class _SelectPlans extends State<SelectPlans>
    with SingleTickerProviderStateMixin {
  List<dynamic> plans = [], selectedPlans;
  ScrollController cardScrollController = new ScrollController();
  final bool viewOnly;

  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectPlans(this.selectedPlans, this.viewOnly);

  @override
  void initState() {
    if(!viewOnly){
      plans = Utils.plans.keys
          .toList()
          .where((element) => Utils.plans[element]['a'])
          .toList();
    } else {
      plans = Utils.plans.keys
          .toList()
          .where((element) => selectedPlans.contains(element))
          .toList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showPlans = plans
        .where((e) => e.toString().toLowerCase().contains(search.toLowerCase()))
        .toList();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black26,
        body: Center(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              height: MediaQuery.of(context).size.height - (48 * 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back_rounded),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      Text(
                        "Plans",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context, selectedPlans);
                        },
                        label: Text(
                          "Done",
                          style: TextStyle(color: Colors.indigo),
                          textAlign: TextAlign.right,
                        ),
                        icon: Icon(
                          Icons.done,
                          size: 18,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: searchController,
                    maxLines: 1,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) {
                      setState(() {
                        search = v;
                      });
                    },
                    decoration: InputDecoration(
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              searchController.text = '';
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
                            vertical: 0, horizontal: 8),
                        labelText: 'Search Plan',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.white),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Wrap(
                          direction: Axis.horizontal,
                          children:
                              List<Widget>.generate(showPlans.length, (i) {
                            String plan = plans[i];
                            return InkWell(
                              onTap: () {
                                if (!viewOnly) {
                                  setState(() {
                                    if (selectedPlans.contains(showPlans[i])) {
                                      selectedPlans.remove(showPlans[i]);
                                    } else {
                                      selectedPlans.add(showPlans[i]);
                                    }
                                  });
                                }
                              },
                              splashColor: Colors.black.withOpacity(0.2),
                              child: Container(
                                //color: color,
                                margin: EdgeInsets.all(2),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: selectedPlans.contains(showPlans[i])
                                        ? Colors.lightBlue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(300),
                                    border: Border.all(
                                      color: Colors.lightBlue,
                                    )),
                                child:
                                    FittedBox(child: Text('${showPlans[i]}')),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectUsers extends StatefulWidget {
  final List<dynamic> selectedUsers;
  final bool viewOnly;

  SelectUsers({Key key, @required this.selectedUsers, this.viewOnly}) : super(key: key);

  @override
  _SelectUsers createState() => _SelectUsers(this.selectedUsers, this.viewOnly??false);
}

class _SelectUsers extends State<SelectUsers>
    with SingleTickerProviderStateMixin {
  List<dynamic> users = [], selectedUsers;
  ScrollController cardScrollController = new ScrollController();
  final bool viewOnly;
  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectUsers(this.selectedUsers, this.viewOnly);

  @override
  void initState() {
    if(!viewOnly){
      users = Utils.users.toList();
    } else {
      users = Utils.users.toList()
          .where((element) => selectedUsers.contains(element['uid']))
          .toList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showUsers = users
        .where((e) => e.toString().toLowerCase().contains(search.toLowerCase()))
        .toList();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black26,
        body: Center(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              height: MediaQuery.of(context).size.height - (48 * 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back_rounded),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      Text(
                        "Users",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context, selectedUsers);
                        },
                        label: Text(
                          "Done",
                          style: TextStyle(color: Colors.indigo),
                          textAlign: TextAlign.right,
                        ),
                        icon: Icon(
                          Icons.done,
                          size: 18,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: searchController,
                    maxLines: 1,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) {
                      setState(() {
                        search = v;
                      });
                    },
                    decoration: InputDecoration(
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              searchController.text = '';
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
                            vertical: 0, horizontal: 8),
                        labelText: 'Search User',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.white),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Wrap(
                          direction: Axis.horizontal,
                          children:
                              List<Widget>.generate(showUsers.length, (i) {
                            var user = showUsers[i];
                            return InkWell(
                              onTap: () {
                                if (!viewOnly) {
                                  setState(() {
                                    if (selectedUsers.contains(user["uid"])) {
                                      selectedUsers.remove(user["uid"]);
                                    } else {
                                      selectedUsers.add(user["uid"]);
                                    }
                                  });
                                }
                              },
                              splashColor: Colors.black.withOpacity(0.2),
                              child: Container(
                                //color: color,
                                margin: EdgeInsets.all(2),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: selectedUsers.contains(user['uid'])
                                        ? Colors.lightBlue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(300),
                                    border: Border.all(
                                      color: Colors.lightBlue,
                                    )),
                                child: Text(
                                    '${user['user_id']} ${user['name']}',
                                    style: const TextStyle(fontSize: 10)),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
