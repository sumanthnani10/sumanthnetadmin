import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sumanth_net_admin/isp/jaze_isp.dart';
import 'package:sumanth_net_admin/utils.dart';

class NetPlans extends StatefulWidget {
  @override
  _NetPlansState createState() => _NetPlansState();
}

class _NetPlansState extends State<NetPlans> {

  List<Plan> plans;
  bool busy = false;

  @override
  void initState() {
    reloadPlans();
    super.initState();
  }

  reloadPlans() {
    plans = Utils.isp.plans_.list;
    plans.sort(
      (a, b) => a.title.compareTo(b.title),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          elevation: 0,
          backgroundColor: Colors.white,
          actions: [
            TextButton.icon(
                onPressed: () async {
                  Utils.showLoadingDialog(context, "Reloading...");
                  ISPResponse ispResponse = await Utils.isp.loadPlans();
                  Map resp = ispResponse.response["data"];
                  if (!ispResponse.success) {
                    await Utils.showErrorDialog(
                        context, "Error", ispResponse.message);
                  } else {
                    setState(() {
                      reloadPlans();
                    });
                  }
                  Navigator.pop(context);
                },
                icon: Icon(Icons.refresh),
                label: Text("Reload"))
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: List<Widget>.generate(plans.length, (i) {
              Plan plan = plans[i];
              return Container(
                decoration: BoxDecoration(
                    border: Border.symmetric(
                        horizontal:
                            BorderSide(color: Colors.black26, width: 1))),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 8,
                    backgroundColor: plan.active ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    '${plan.title}',
                    style: TextStyle(
                        fontSize: 14, decoration: TextDecoration.underline),
                  ),
                  subtitle: RichText(
                      text: TextSpan(
                          text:
                              '${plan.months} ${plan.months == 1 ? "Month" : "Months"} - ',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontFamily: "Poppins"),
                          children: [
                        TextSpan(
                          text: 'Rs.${plan.mrp}, ',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.red,
                          ),
                        ),
                        TextSpan(
                          text: 'Rs.${plan.price}, ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ])),
                  trailing: IconButton(
                      onPressed: () {
                        editPlan(plan);
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.blue,
                      )),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  editPlan(Plan plan) async {
    var r =
        await _showEditPlanDialog("${plan.mrp}", "${plan.price}", plan.title, plan .months) ??
            [false];
    if (r[0] ?? false) {
      setState(() {
        busy = true;
      });
      Utils.showLoadingDialog(context, 'Loading');
      plan.mrp = int.parse(r[1]);
      plan.price = int.parse(r[2]);
      plan.title = r[3];
      plan.months = r[4];
      ISPResponse resp = await Utils.isp.upsertPlan(plan, true);
      if (!resp.success) {
        await Utils.showErrorDialog(context, "Error", resp.message);
      } else {
        setState(() {
          reloadPlans();
        });
      }
      Navigator.pop(context);
      setState(() {
        busy = false;
      });
    }
  }

  Future<List> _showEditPlanDialog(String mrp, String price, String planTitle, int times) {
    TextEditingController priceFieldController =
        new TextEditingController(text: "$price");
    TextEditingController mrpFieldController =
        new TextEditingController(text: "$mrp");
    TextEditingController titleFieldController =
        new TextEditingController(text: "$planTitle");
    GlobalKey<FormState> formKey = new GlobalKey<FormState>();
    String newPrice = "$price";
    String newMrp = "$mrp";
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Plan"),
          content: StatefulBuilder(
            builder: (_, setDState) => Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleFieldController,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.characters,
                    keyboardType: TextInputType.text,
                    onChanged: (v) {
                      planTitle = v;
                    },
                    decoration: InputDecoration(labelText: "New Title"),
                    validator: (v) {
                      if (v.length == 0) {
                        return 'Please enter new title';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: mrpFieldController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: "MRP"),
                          onChanged: (v) {
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
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: TextFormField(
                          controller: priceFieldController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            newPrice = v;
                          },
                          decoration: InputDecoration(labelText: "Price"),
                          validator: (v) {
                            if (v.length == 0) {
                              return 'Please enter price';
                            } else if (int.parse(newPrice) > int.parse(newMrp)) {
                              return 'Price must be greater than or equal to MRP';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                            onTap: () {
                              if (times != 1) times -= 1;
                              setDState(() {
                              });
                            },
                            child: Icon(CupertinoIcons.minus)),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "$times months",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        InkWell(
                            onTap: () {
                              if (times < 12) times += 1;
                              setDState(() {
                              });
                            },
                            child: Icon(CupertinoIcons.plus)),
                      ]),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context)
                    .pop([false, "$mrp", "$price", "$planTitle", times]);
              },
            ),
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                if (formKey.currentState.validate()) {
                  Navigator.of(context)
                      .pop([true, "$newMrp", "$newPrice", "$planTitle", times]);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
