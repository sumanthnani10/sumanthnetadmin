import 'dart:io';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import 'utils.dart';

class PdfGeneration {
  static generateBill(
      bool isGst,
      String userID,
      String userName,
      String address,
      String mobile,
      String email,
      String plan,
      String id,
      String date,
      String internetCharges,
      String gst,
      String total) async {
    var pdf = Document();
    pdf.addPage(Page(
        margin: const EdgeInsets.all(0),
        pageFormat: PdfPageFormat.a5,
        build: (c) => Column(children: <Widget>[
              Container(color: PdfColors.orange600, height: 20, child: Row()),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Sumanth Net (RVR NET)',
                            style: TextStyle(
                                color: PdfColors.blue900, fontSize: 18)),
                        if (isGst)
                          Text('GST: 36AGLPB6730FIZL',
                              style: TextStyle(
                                  color: PdfColor.fromHex('#000000'),
                                  fontSize: 8)),
                        SizedBox(height: 2),
                        Text(
                            '12-83/1, Srinagar Colony\nPatancheru, Sangareddy, Telangana\n8801707182',
                            style: TextStyle(
                                color: PdfColor.fromHex('#000000'),
                                fontSize: 10)),
                        SizedBox(height: 16),
                        Text('Invoice',
                            style: TextStyle(
                                color: PdfColors.purple,
                                fontSize: 30,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                                child: Container(
                              decoration: BoxDecoration(
                                  border: Border(left: BorderSide())),
                              padding: const EdgeInsets.only(left: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer Details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${userID}',
                                    style: TextStyle(fontSize: 9),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${userName}',
                                    style: TextStyle(fontSize: 9),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${address.length > 25 ? address.substring(0, 25) : address}',
                                    style: TextStyle(
                                      fontSize: 9,
                                    ),
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${mobile}',
                                    style: TextStyle(fontSize: 9),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${email}',
                                    style: TextStyle(fontSize: 9),
                                  ),
                                ],
                              ),
                            )),
                            Flexible(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 2),
                                  decoration: BoxDecoration(
                                      border: Border(left: BorderSide())),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Plan',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9),
                                      ),
                                      Text(
                                        '${plan}',
                                        style: TextStyle(fontSize: 9),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.only(left: 2),
                                  decoration: BoxDecoration(
                                      border: Border(left: BorderSide())),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Expires In',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9),
                                      ),
                                      Text(
                                        '${Utils.plans[plan]['m']} ${Utils.plans[plan]['m'] == 1 ? "Month" : "Months"}',
                                        style: TextStyle(fontSize: 9),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                            Flexible(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 2),
                                  decoration: BoxDecoration(
                                      border: Border(left: BorderSide())),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Invoice#',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9),
                                      ),
                                      Text(
                                        '${id}',
                                        style: TextStyle(fontSize: 9),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 2),
                                  decoration: BoxDecoration(
                                      border: Border(left: BorderSide())),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9),
                                      ),
                                      Text(
                                        '${date}',
                                        style: TextStyle(fontSize: 9),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ))
                          ],
                        ),
                        Container(
                            padding: const EdgeInsets.only(top: 16, bottom: 20),
                            margin: const EdgeInsets.only(top: 64, bottom: 16),
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(), bottom: BorderSide())),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Description',
                                            style: TextStyle(
                                                color: PdfColors.blue800,
                                                fontWeight: FontWeight.bold)),
                                        Text('Price',
                                            style: TextStyle(
                                                color: PdfColors.blue800,
                                                fontWeight: FontWeight.bold)),
                                      ]),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    color: PdfColors.grey300,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Internet Charges', style: TextStyle(fontSize: 10)),
                                          Text('Rs.${internetCharges}.00', style: TextStyle(fontSize: 10)),
                                        ]),
                                  ),
                                  SizedBox(height: 4),
                                  if (isGst)
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text('GST (18%)', style: TextStyle(fontSize: 10)),
                                              Text('Rs.${gst}.00', style: TextStyle(fontSize: 10)),
                                            ])),
                                  if (!isGst) SizedBox(height: 12),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    color: PdfColors.grey300,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[]),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    color: PdfColors.grey300,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[]),
                                  ),
                                ])),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('In Words:',
                                        style: TextStyle(
                                            color: PdfColors.black,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold)),
                                    Text('${getPriceInWords("${total}")}',
                                        style: TextStyle(
                                            color: PdfColors.black,
                                            fontSize: 8)),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text('Total',
                                        style: TextStyle(
                                            color: PdfColors.black,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold)),
                                    Text('Rs.${total}.00',
                                        style: TextStyle(
                                            color: PdfColors.orange900,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold))
                                  ]),
                            ])
                      ]))
            ])));

    final op = await getExternalStorageDirectory();
    final file = File('${op.path}/${id}.pdf');
    // print(op.path);
    file.writeAsBytesSync(await pdf.save());
    await FlutterEmailSender.send(Email(
        body: 'Here is your Invoice. Thank you\n-Sumanth Net',
        recipients: ['${email}'],
        subject: 'RVR BILL',
        attachmentPaths: ['${op.path}/${id}.pdf']));
    return;
  }

  static getPriceInWords(String price) {
    var ones = {};
    ones['0'] = '';
    ones['1'] = 'One ';
    ones['2'] = 'Two ';
    ones['3'] = 'Three ';
    ones['4'] = 'Four ';
    ones['5'] = 'Five ';
    ones['6'] = 'Six ';
    ones['7'] = 'Seven ';
    ones['8'] = 'Eight ';
    ones['9'] = 'Nine ';
    var tens = {};
    tens['0'] = '';
    tens['10'] = 'Ten ';
    tens['11'] = 'Eleven ';
    tens['12'] = 'Twelve ';
    tens['13'] = 'Thirteen ';
    tens['14'] = 'Fourteen ';
    tens['15'] = 'Fifteen ';
    tens['16'] = 'Sixteen ';
    tens['17'] = 'Seventeen ';
    tens['18'] = 'Eighteen ';
    tens['19'] = 'Nineteen ';
    tens['2'] = 'Twenty ';
    tens['3'] = 'Thirty ';
    tens['4'] = 'Forty ';
    tens['5'] = 'Fifty ';
    tens['6'] = 'Sixty ';
    tens['7'] = 'Seventy ';
    tens['8'] = 'Eighty ';
    tens['9'] = 'Ninety ';

    String w = ''
            '',
        rev = price.split('').reversed.join();

    for (int i = 0; i < rev.length; i++) {
      if (i == 0) {
        if (rev.length > 1) {
          if (rev[1] == '1') {
            w = '${tens['${rev[1]}${rev[0]}']}' + w;
            i += 1;
          } else {
            w = '${ones[rev[i]]}' + w;
          }
        } else {
          w = '${ones[rev[i]]}' + w;
        }
      } else if (i == 1) {
        w = '${tens[rev[i]]}' + w;
      } else if (i == 2) {
        w = '${ones[rev[i]]}${rev[i] != '0' ? 'hundred ' : ''}' + w;
      } else if (i == 3) {
        if (rev.length > 4) {
          if (rev[4] == '1') {
            w = '${tens['${rev[i + 1]}${rev[i]}']}thousand ' + w;
            i += 1;
          } else {
            w = '${ones[rev[i]]}${(rev[i] == '0' && rev[i + 1] == '0') ? '' : 'thousand '}' +
                w;
          }
        } else {
          w = '${ones[rev[i]]}${(rev[i] == '0' && rev[i + 1] == '0') ? '' : 'thousand '}' +
              w;
        }
      } else if (i == 4) {
        w = '${tens[rev[i]]}' + w;
      } else if (i == 5) {
        if (rev.length > i + 1) {
          if (rev[i + 1] == '1') {
            w = '${tens['${rev[i + 1]}${rev[i]}']}lakhs ' + w;
            i += 1;
          } else {
            w = '${ones[rev[i]]}${(rev[i] == '0' && rev[i + 1] == '0') ? '' : rev[i] == '1' ? 'lakh ' : 'lakhs '}' +
                w;
          }
        } else {
          w = '${ones[rev[i]]}${(rev[i] == '0' && rev[i + 1] == '0') ? '' : rev[i] == '1' ? 'lakh ' : 'lakhs '}' +
              w;
        }
      } else if (i == 6) {
        w = '${tens[rev[i]]}' + w;
      } else if (i == 7) {
        if (rev.length > i + 1) {
          if (rev[i + 1] == '1') {
            w = '${tens['${rev[i + 1]}${rev[i]}']}crores ' + w;
            i += 1;
          } else {
            w = '${ones[rev[i]]}${rev[i] == '1' ? 'crore' : 'crores'} ' + w;
          }
        } else {
          w = '${ones[rev[i]]}${rev[i] == '1' ? 'crore' : 'crores'} ' + w;
        }
      } else if (i == 8) {
        w = '${tens[rev[i]]}' + w;
      } else if (i == 9) {
        w = '${ones[rev[i]]}${rev[i] != '0' ? 'hundred ' : ''}' + w;
      }
      // print('$i $w');
    }
    w = w + 'rupees only';
    return w;
  }
}

/*

  generateBill() async {
    // print(Utils.plans[bill['package_name']]);

      // Navigator.push(context, MaterialPageRoute(builder: (context) => Bill(gst: gst,price: price,),));
      var pdf = Document();
      pdf.addPage(Page(
          margin: const EdgeInsets.all(0),
          pageFormat: PdfPageFormat.a5,
          build: (c) =>
              Column(children:<Widget>[
                Container(color:PdfColors.orange600,height: 2,child: Row()),
                Container(color:PdfColors.green300,height: 2,child: Row()),
                Container(color:PdfColors.orange600,height: 16,child: Row()),
                Padding(padding: const EdgeInsets.all(16),child:Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Sumanth Net (RVR NET)',
                          style: TextStyle(
                              color: PdfColors.blue900, fontSize: 18)),
                      if (gst)
                        Text('GST: 36AGLPB6730FIZL',
                            style: TextStyle(
                                color: PdfColor.fromHex('#000000'), fontSize: 8)),
                      SizedBox(height: 2),
                      Text(
                          '12-83/1, Srinagar Colony\nPatancheru, Sangareddy, Telangana\n8801707182',
                          style: TextStyle(
                              color: PdfColor.fromHex('#000000'), fontSize: 10)),
                      SizedBox(height: 16),
                      Text('Invoice',
                          style: TextStyle(
                              color: PdfColors.purple,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child:Container(
                            decoration: BoxDecoration(
                                border: Border(left: BorderSide())),
                            padding: const EdgeInsets.only(left: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Customer Details',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9),
                                ),
                                Text(
                                  '${widget.user['user_id']}',
                                  style: TextStyle(fontSize: 9),
                                ),
                                Text(
                                  '${name}',
                                  style: TextStyle(fontSize: 9),
                                ),
                                Text(
                                  '${widget.user['address'].length>25?widget.user['address'].substring(0,25):widget.user['address']}',
                                  style: TextStyle(fontSize: 9,),
                                ),
                                Text(
                                  '${widget.user['mobile']}',
                                  style: TextStyle(fontSize: 9),
                                ),
                                Text(
                                  '${widget.user['email']}',
                                  style: TextStyle(fontSize: 9),
                                ),
                              ],
                            ),
                          )),
                          Flexible(child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 2),
                                decoration: BoxDecoration(
                                    border: Border(left: BorderSide())),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Plan',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9),
                                    ),
                                    Text(
                                      '${selected_plan}',
                                      style: TextStyle(fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.only(left: 2),
                                decoration: BoxDecoration(
                                    border: Border(left: BorderSide())),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expires In',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9),
                                    ),
                                    Text(
                                      '${Utils
                                          .plans[selected_plan]['m']} ${Utils.plans[selected_plan]['m']==1?"Month":"Months"}',
                                      style: TextStyle(fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                              /*Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 2),
                                  decoration: BoxDecoration(
                                      border: Border(left: BorderSide())),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Activation date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9),
                                      ),
                                      Text(
                                        '${bill['create_timestamp'].substring(
                                            0, 10)}',
                                        style: TextStyle(fontSize: 9),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.only(left: 2),
                                  decoration: BoxDecoration(
                                      border: Border(left: BorderSide())),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Expires In',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9),
                                      ),
                                      Text(
                                        '${Storage
                                            .plans[bill['package_name']][3]}',
                                        style: TextStyle(fontSize: 9),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),*/
                            ],
                          )),
                          Flexible(child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 2),
                                decoration: BoxDecoration(
                                    border: Border(left: BorderSide())),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Invoice#',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9),
                                    ),
                                    Text(
                                      '${bill['id']}',
                                      style: TextStyle(fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 2),
                                decoration: BoxDecoration(
                                    border: Border(left: BorderSide())),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9),
                                    ),
                                    Text(
                                      '${bill['create_timestamp'].substring(
                                          0, 10)}',
                                      style: TextStyle(fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ))
                        ],
                      ),
                      Container(
                          padding: const EdgeInsets.only(top: 16, bottom: 20),
                          margin: const EdgeInsets.only(top: 64, bottom: 16),
                          decoration: BoxDecoration(
                              border: Border(top: BorderSide(),bottom: BorderSide())
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('Description',
                                          style: TextStyle(
                                              color: PdfColors.blue800,
                                              fontWeight: FontWeight.bold)),
                                      Text('Price',
                                          style: TextStyle(
                                              color: PdfColors.blue800,
                                              fontWeight: FontWeight.bold)),
                                    ]),
                                SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  color: PdfColors.grey300,
                                  child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Internet Charges'),
                                        Text('Rs.${ic}.00'),
                                      ]),
                                ),
                                SizedBox(height: 4),
                                if(gst)
                                  Padding(
                                      padding: const EdgeInsets.symmetric(horizontal:4),
                                      child:Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text('GST (18%)'),
                                            Text('Rs.${gstc}.00'),
                                          ])),
                                if(!gst)
                                  SizedBox(height: 12),
                                SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  color: PdfColors.grey300,
                                  child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                      ]),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  color: PdfColors.grey300,
                                  child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                      ]),
                                ),
                              ])),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('In Words:', style: TextStyle(
                                      color: PdfColors.black, fontSize: 8,fontWeight: FontWeight.bold)),
                                  Text('${getPriceInWords(total)}',
                                      style: TextStyle(
                                          color: PdfColors.black, fontSize: 8)),
                                ]
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text('Total', style: TextStyle(
                                      color: PdfColors.black, fontSize: 8,fontWeight: FontWeight.bold)),
                                  Text('Rs.${total}.00', style: TextStyle(
                                      color: PdfColors.orange900,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))
                                ]
                            ),
                          ]
                      )
                    ]))])));

      final op = await getExternalStorageDirectory();
      final file = File('${op.path}/Invoice.pdf');
      file.writeAsBytesSync(await pdf.save());
      await FlutterEmailSender.send(Email(
          body: 'Here is your Invoice. Thank you\n-Sumanth Net',
          recipients: ['${user['email']}'],
          subject: 'RVR BILL',
          attachmentPaths: ['${op.path}/Invoice.pdf']
      ));

  }
*/