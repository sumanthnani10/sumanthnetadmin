import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import 'isp/jaze_isp.dart';
import 'utils.dart';

class PdfGeneration {

  static List amounts = [
    {
      "key": "internet",
      "title": "Internet Charges",
    },
    {
      "key": "ip",
      "title": "Public IP",
    },
    {
      "key": "installation",
      "title": "Installation",
    },
    {
      "key": "router",
      "title": "Router",
    },
    {
      "key": "other",
      "title": "Others",
    },
  ];

  static generateBill(user, bill) async {
    var pdf = Document();
    var content = await getPDF(user, bill);
    pdf.addPage(Page(
        margin: const EdgeInsets.all(0),
        pageFormat: PdfPageFormat.a4,
        build: (c) => content));

    final op = await getExternalStorageDirectory();
    print(op.path);
    final file = File('${op.path}/${bill["bill_id"]}.pdf');
    file.writeAsBytesSync(await pdf.save());
    await FlutterEmailSender.send(Email(
        body: 'Please find the attachment of your Invoice.\nThank you.\n-Sumanth Net',
        // recipients: ['sumanthnani10@gmail.com'],
        recipients: ['${user["email"]}'],
        subject: 'Internet Bill',
        attachmentPaths: ['${op.path}/${bill["bill_id"]}.pdf']));
    return;
  }

  static getPriceInWords(String price) {
    if(price == "0") {
      return "Zero Rupees Only";
    }
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
        rev = price
            .split('')
            .reversed
            .join();

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
        w = '${ones[rev[i]]}${rev[i] != '0' ? 'Hundred ' : ''}' + w;
      } else if (i == 3) {
        if (rev.length > 4) {
          if (rev[4] == '1') {
            w = '${tens['${rev[i + 1]}${rev[i]}']}Thousand ' + w;
            i += 1;
          } else {
            w = '${ones[rev[i]]}${(rev[i] == '0' && rev[i + 1] == '0')
                ? ''
                : 'Thousand '}' +
                w;
          }
        } else {
          w = '${ones[rev[i]]}${(rev[i] == '0' && rev[i + 1] == '0')
              ? ''
              : 'Thousand '}' +
              w;
        }
      } else if (i == 4) {
        w = '${tens[rev[i]]}' + w;
      } else if (i == 5) {
        if (rev.length > i + 1) {
          if (rev[i + 1] == '1') {
            w = '${tens['${rev[i + 1]}${rev[i]}']}Lakhs ' + w;
            i += 1;
          } else {
            w = '${ones[rev[i]]}${(rev[i] == '0' && rev[i + 1] == '0')
                ? ''
                : rev[i] == '1' ? 'Lakh ' : 'Lakhs '}' +
                w;
          }
        } else {
          w = '${ones[rev[i]]}${(rev[i] == '0' && rev[i + 1] == '0')
              ? ''
              : rev[i] == '1' ? 'Lakh ' : 'Lakhs '}' +
              w;
        }
      } else if (i == 6) {
        w = '${tens[rev[i]]}' + w;
      } else if (i == 7) {
        if (rev.length > i + 1) {
          if (rev[i + 1] == '1') {
            w = '${tens['${rev[i + 1]}${rev[i]}']}Crores ' + w;
            i += 1;
          } else {
            w = '${ones[rev[i]]}${rev[i] == '1' ? 'Crore' : 'Crores'} ' + w;
          }
        } else {
          w = '${ones[rev[i]]}${rev[i] == '1' ? 'Crore' : 'Crores'} ' + w;
        }
      } else if (i == 8) {
        w = '${tens[rev[i]]}' + w;
      } else if (i == 9) {
        w = '${ones[rev[i]]}${rev[i] != '0' ? 'Hundred ' : ''}' + w;
      }
    }
    w = w + 'Rupees Only';
    return w;
  }

  static getPDF(user, bill) async {
    final poppins = await PdfGoogleFonts.poppinsRegular();
    final poppinsBold = await PdfGoogleFonts.poppinsBold();
    int accepted = -1;
    bool isGst = bill["bill"]["gst"] != 0;
    Plan plan = Utils.isp.plans[bill["plan"]];
    return Theme(
      data: ThemeData(
        defaultTextStyle: TextStyle(font: poppins)
      )
    ,child: Column(children: <Widget>[
      Container(color: PdfColors.orange600, height: 20, child: Row()),
      Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Sumanth Net',
                    style: TextStyle(
                        color: PdfColors.blue900, fontSize: 24, fontWeight: FontWeight.bold, font: poppinsBold)),
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
                        fontWeight: FontWeight.bold, font: poppinsBold)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    fontWeight: FontWeight.bold, font: poppinsBold,
                                    fontSize: 9),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${user["user_id"]}',
                                style: TextStyle(fontSize: 9),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${user["name"]}',
                                style: TextStyle(fontSize: 9),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${user["address"]}',
                                style: TextStyle(
                                  fontSize: 9,
                                ),
                                maxLines: 2,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${user["mobile"]}',
                                style: TextStyle(fontSize: 9),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${user["email"]}',
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
                                        fontWeight: FontWeight.bold, font: poppinsBold,
                                        fontSize: 9),
                                  ),
                                  Text(
                                    '${plan.title}',
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
                                    'Expiry Date',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, font: poppinsBold,
                                        fontSize: 9),
                                  ),
                                  Text(
                                    '${bill["expiry"]}',
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
                                        fontWeight: FontWeight.bold, font: poppinsBold,
                                        fontSize: 9),
                                  ),
                                  Text(
                                    '${bill["bill_id"]}',
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
                                        fontWeight: FontWeight.bold, font: poppinsBold,
                                        fontSize: 9),
                                  ),
                                  Text(
                                    '${bill["date"]}',
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
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    margin: const EdgeInsets.only(top: 32, bottom: 16),
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
                                        fontWeight: FontWeight.bold, font: poppinsBold)),
                                Text('Price',
                                    style: TextStyle(
                                        color: PdfColors.blue800,
                                        fontWeight: FontWeight.bold, font: poppinsBold)),
                              ]),
                          SizedBox(height: 4),
                        ] +
                            List.generate(amounts.length, (i) {
                              var amount = amounts[i];
                              if(bill["bill"][amount["key"]] == null || bill["bill"][amount["key"]] == 0){
                                return Container();
                              }
                              accepted += 1;
                              return Container(
                                padding: const EdgeInsets.all(4),
                                color: accepted%2==0?PdfColors.grey300:PdfColors.white,
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('${amount["title"]} ${(amount["key"]==amounts[0]["key"] && isGst)?"(Incl. 18% GST)":""}',
                                          style: TextStyle(fontSize: 10)),
                                      Text('Rs.${bill["bill"][amount["key"]]+(amount["key"]==amounts[0]["key"]?bill["bill"]["gst"]:0)}.00',
                                          style: TextStyle(fontSize: 10)),
                                    ]),
                              );
                            }) +
                            List.generate(amounts.length - accepted, (i) {
                              accepted+=1;
                              return Container(
                                padding: const EdgeInsets.all(4),
                                color: accepted%2==0?PdfColors.grey300:PdfColors.white,
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('0',
                                          style: TextStyle(fontSize: 10, color: accepted%2==0?PdfColors.grey300:PdfColors.white)),
                                    ]),
                              );
                            }))),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('In Words:',
                                style: TextStyle(
                                    color: PdfColors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold, font: poppinsBold)),
                            Text('${getPriceInWords("${bill["total"]}")}',
                                style: TextStyle(
                                    color: PdfColors.black,
                                    fontSize: 10)),
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
                                    fontWeight: FontWeight.bold, font: poppinsBold)),
                            Text('Rs.${bill["total"]}.00',
                                style: TextStyle(
                                    color: PdfColors.orange900,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, font: poppinsBold))
                          ]),
                    ])
              ]))
    ]));
  }

}