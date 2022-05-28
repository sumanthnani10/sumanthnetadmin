import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'utils.dart';

class CablePayments extends StatefulWidget {

  final String id;

  const CablePayments({Key key, this.id=''}) : super(key: key);

  @override
  _CablePaymentsState createState() => _CablePaymentsState();
}

class _CablePaymentsState extends State<CablePayments> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  bool gettingPayments = true;

  ScrollController scroll_controller = new ScrollController();

  int viewItems = 20;

  TextStyle sStyle = TextStyle(color: Colors.green[800]);
  TextStyle pStyle = TextStyle(color: Colors.amber[800]);
  TextStyle fStyle = TextStyle(color: Colors.red);

  BoxDecoration contDec = BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Colors.black,width: 0.4))
  );

  TextStyle buttonTextStyle = new TextStyle(color: Colors.blue);

  TextStyle buttonTextStyle2 = TextStyle(
    color: Colors.white,
    fontSize: 12,
  );

  int selected = 1;

  @override
  void initState() {
    super.initState();
    getCablePayments();
  }

  setListener(){
    scroll_controller..addListener(() {
      if (scroll_controller.offset >=
          scroll_controller.position.maxScrollExtent &&
          !scroll_controller.position.outOfRange) {
        viewItems += 20;
        setState(() {});
      }
      else if(scroll_controller.offset==scroll_controller.position.minScrollExtent){
        setState(() {
          viewItems = 20;
        });
      }
    });
  }

  @override
  void dispose() {
    scroll_controller.dispose();
    super.dispose();
  }

  getCablePayments() async {
    setState(() {
      gettingPayments=true;
    });
    await FirebaseFirestore.instance.collection('cpay').get().then((pays) {
      Utils.cablePayments.clear();
      pays.docs.forEach((e) {
        var r = e.data();
        r.addAll({"id":e.id});
        Utils.cablePayments.add(r);
      });
      setState(() {
        gettingPayments=false;
      });
    });
    setListener();
  }

  copy(context,text){
    Clipboard.setData(ClipboardData(text: text)).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied.'),duration: Duration(milliseconds: 300),));
    });
  }

  callUser(mobile) async {
    if (await canLaunch(
        'tel:${mobile}')) {
      await launch(
          'tel:${mobile}');
    } else {
      throw 'Could not launch tel:${mobile}';
    }
  }

  showReceipt(context,pay){
    var rem;
    double h8 = 8;
    if(pay['stat']!='failed'){
      var s = pay['resp'].toString();
      s= s.replaceAll(': ', '": "');
      s= s.replaceAll(', ', '", "');
      s=s.replaceAll('{', '{"');
      s=s.replaceAll('}', '"}');
      var r;
      r = jsonDecode(s);
      rem = <Widget>[
        SizedBox(height: h8,),
        Text('Date: ${r['TXNDATE']}'),
        SizedBox(height: h8,),
        InkWell(
            onTap: (){
              copy(context,'${r['TXNID']}');
            },
            child: Text('Transaction Id: ${r['TXNID']}')
        ),
        SizedBox(height: h8,),
        InkWell(
            onTap: (){
              copy(context,'${r['BANKTXNID']}');
            },
            child: Text('Bank Transaction Id: ${r['BANKTXNID']}')
        ),
        SizedBox(height: h8,),
        Text('Payment Mode: ${r['PAYMENTMODE']} - ${r['GATEWAYNAME']}'),
        SizedBox(height: h8,),
        InkWell(
            onTap: (){
              copy(context,'${r['STATUS']} - ${r['RESPMSG']}');
            },
            child: Text('Status: ${r['STATUS']} - ${r['RESPMSG']}')
        ),
        if(pay['msg']!=null)
        SizedBox(height: h8,),
        if(pay['msg']!=null)
          InkWell(
            onTap: (){
              copy(context,'${pay['msg']}');
            },
            child: Text('Message: ${pay['msg']}')
        ),
        SizedBox(height: h8,),
        InkWell(
            onTap: (){
              copy(context,'${r['CHECKSUMHASH']}');
            },
            child: Text('CSH: ${r['CHECKSUMHASH']}',style: TextStyle(fontSize: 6),)
        ),
      ];
    }
    else if(pay['msg']!=null){
      var s = pay['resp'].toString();
      s= s.replaceAll(': ', '": "');
      s= s.replaceAll(', ', '", "');
      s=s.replaceAll('{', '{"');
      s=s.replaceAll('}', '"}');
      var r;
      r = jsonDecode(s);
      rem = <Widget>[
        SizedBox(height: h8,),
        Text('Date: ${r['TXNDATE']}'),
        SizedBox(height: h8,),
        InkWell(
            onTap: (){
              copy(context,'${r['TXNID']}');
            },
            child: Text('Transaction Id: ${r['TXNID']}')
        ),
        SizedBox(height: h8,),
        InkWell(
            onTap: (){
              copy(context,'${r['BANKTXNID']}');
            },
            child: Text('Bank Transaction Id: ${r['BANKTXNID']}')
        ),
        SizedBox(height: h8,),
        Text('Payment Mode: ${r['PAYMENTMODE']} - ${r['GATEWAYNAME']}'),
        SizedBox(height: h8,),
        Text('Message: ${pay['msg']}'),
        SizedBox(height: h8,),
        InkWell(
            onTap: (){
              copy(context,'${r['CHECKSUMHASH']}');
            },
            child: Text('CSH: ${r['CHECKSUMHASH']}',style: TextStyle(fontSize: 6),)
        ),
      ];
    }

    showDialog(context: context,builder: (contex) {
      return SimpleDialog(
        title: Text('Receipt'),
        contentPadding: const EdgeInsets.all(8),
        titlePadding: const EdgeInsets.symmetric(horizontal: 8),
        children: <Widget>[
          Align(alignment: Alignment.centerRight,child: Text('Rs. ${pay['amo']}   ',style: TextStyle(fontSize: 24,fontWeight: FontWeight.w800),)),
          InkWell(
              onTap: (){
                copy(context,'${pay['bn']}');
              },
              child:Text('${pay['bn']}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600))
          ),
          SizedBox(height: h8,),
          InkWell(
              onTap: (){
                callUser('${pay['mob']}');
              },
              onLongPress: (){
                copy(context,'${pay['bn']}');
              },
              child:Text('${pay['mob']}',style: buttonTextStyle,)
          ),
          SizedBox(height: h8,),
          Text('Details: ${pay['det']}'),
          SizedBox(height: h8,),
          InkWell(
              onTap: (){
                copy(context,'${pay['id']}');
              },
              child:Text('Order Id: ${pay['id']}')
          ),
        ]+rem,
      );
    },);
  }
  
  updatePending(pay,t)async{
    setState(() {
      gettingPayments=true;
    });
    if(t=='failed'){
      await FirebaseFirestore.instance.collection('cpay').doc(pay['id']).update(
          {
            'pd.stat':t,
            'pd.msg': 'failed after pending',
          });
    }else{
      await FirebaseFirestore.instance.collection('cpay').doc(pay['id']).update(
          {
            'pd.stat':t,
            'pd.msg': 'success after pending',
          });
      var amount = pay['amo'];
      var orderID = pay['id'];
      var mnth = DateTime.now();
      DocumentReference documentReference =
      FirebaseFirestore.instance.collection('data').doc('cable');
      var batch = FirebaseFirestore.instance.batch();
      await FirebaseFirestore.instance.runTransaction((t) {
        return t.get<Map>(documentReference).then((doc) {

          var year = doc.data()['pays'][mnth.year.toString()];

          String mnt = '${mnth.year.toString()}_';
          if (mnth.month <= 9) {
            mnt += '0${mnth.month}';
          } else {
            mnt += '${mnth.month}';
          }

          if (year == null) {
            // print('no year');
            batch.update(documentReference, {
              'pays.${mnth.year.toString()}': {
                '__ytot': double.parse(amount),
                '${mnt}': {
                  '${orderID}': double.parse(amount),
                  '__mtot': double.parse(amount)
                }
              }
            });
          }
          else {
            batch.update(documentReference, {
              'pays.${mnth.year.toString()}.__ytot': double.parse(amount)+year['__ytot']
            });

            var month = doc.data()['pays'][mnth.year.toString()][mnt];
            // print(month);
            if (month == null) {
              // print('no month');
              batch.update(documentReference, {
                'pays.${mnth.year.toString()}.${mnt}': {
                  '${orderID}': double.parse(amount),
                  '__mtot': double.parse(amount)
                }
              });
            } else {
              batch.update(documentReference, {
                'pays.${mnth.year.toString()}.${mnt}.${orderID}': double.parse(amount),
                'pays.${mnth.year.toString()}.${mnt}.__mtot': month['__mtot'] + double.parse(amount)
              });
            }

          }
        });
      });
      batch.commit();
    }
    getCablePayments();
  }

  @override
  Widget build(BuildContext context) {
    var payms = [];
    if(selected==0){
      payms = Utils.cablePayments;
    } else if(selected==1){
      payms = Utils.cablePayments.where((e) => e['pd']['stat']=='success').toList();
    }else{
      payms = Utils.cablePayments.where((e) => e['pd']['stat']!='success').toList();
    }
    return AbsorbPointer(
      absorbing: gettingPayments,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Cable Payments',
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(28),
            child: Padding(
              padding: const EdgeInsets.only(bottom:8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          selected = 0;
                        });
                      },
                      child: Container(
                        width: 113,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color(0xfffff700),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                topLeft: Radius.circular(8)),
                          border: Border.all(color: Colors.yellow,width: selected==0?3:0)
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'All',
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selected = 1;
                        });
                      },
                      child: Container(
                        width: 113,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color(0xff00fd5d),
                            border: Border.all(color: Color(0xff00fd5d),width: selected==1?3:0)
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Success',
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          selected = 2;
                        });
                      },
                      child: Container(
                        width: 113,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color(0xffffaf00),
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(8),
                                topRight: Radius.circular(8)),
                            border: Border.all(color: Color(0xffffaf00),width: selected==2?3:0)),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Pending/Failed',
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: () async {
                  getCablePayments();
                },
                child: Text(
                  'Reload',
                  style: TextStyle(color: Colors.blue),
                ))
          ],
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Builder(
          builder:(context) => SingleChildScrollView(
            controller: scroll_controller,
            child: Column(
              children: <Widget>[if(gettingPayments)LinearProgressIndicator()]+
                  List<Widget>.generate(min(viewItems, payms.length), (index){
                    var pay = payms[index]['pd'];
                    pay['id'] = payms[index]['id'];
                    int td = pay['stat']!='failed'?pay['resp'].indexOf('TXNDATE'):0;
                    String date = pay['stat']!='failed' ? '${pay['resp'].toString().substring(td+9,td+28)}':'';
                return InkWell(
                  splashColor: Colors.black,
                  onLongPress: (){
                    copy(context,'${pay['bn']}');
                  },
                  onDoubleTap: (){
                    callUser('${pay['mob']}');
                  },
                  child: Container(
                    decoration: contDec,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 2),
                    child: ExpansionTile(
                      title: Text('${pay['bn']}',style: pay['stat'] == 'success'
                          ? sStyle
                          : pay['stat'] == 'failed'? fStyle:pStyle,),
                      subtitle: Text('${pay['mob'].substring(3)} | Rs.${pay['amo']} | $date',style: pay['stat'] == 'success'
                          ? sStyle
                          : pay['stat'] == 'failed'? fStyle:pStyle,),
                      expandedAlignment: Alignment.centerLeft,
                      initiallyExpanded: widget.id==pay['id'],
                      children: [
                        Text('${pay['det']}'),
                        if(pay['note']!=null)
                        Text('${pay['note']}'),
                        if(pay['stat']=='pending')
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            FlatButton(
                              color: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8)),
                              onPressed: () {
                                updatePending(pay,'failed');
                              },
                              child: Text(
                                'Failed',
                                style: buttonTextStyle2,
                              ),
                              splashColor: Colors.black26,
                            ),
                            FlatButton(
                              color: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8)),
                              onPressed: () {
                                updatePending(pay,'success');
                              },
                              child: Text(
                                'Success',
                                style: buttonTextStyle2,
                              ),
                              splashColor: Colors.black26,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            FlatButton(
                              color: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8)),
                              onPressed: () {
                                showReceipt(context,pay);
                              },
                              child: Text(
                                'View',
                                style: buttonTextStyle2,
                              ),
                              splashColor: Colors.green[100],
                            ),
                            FlatButton(
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8)),
                              onPressed: () {
                                callUser('${pay['mob']}');
                              },
                              child: Text(
                                'Call',
                                style: buttonTextStyle2,
                              ),
                              splashColor: Colors.green[100],
                            ),
                            FlatButton(
                              color: Colors.orange,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8)),
                              onPressed: () =>
                                  copy(context,'${pay['bn']}'),
                              child: Text(
                                'Copy',
                                style: buttonTextStyle2,
                              ),
                              splashColor: Colors.green[100],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
