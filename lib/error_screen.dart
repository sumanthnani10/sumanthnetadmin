import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sumanth_net_admin/isp/jaze_isp.dart';

class ErrorScreen extends StatelessWidget {

  final text;
  final bool html;
  final ISPResponse ispResponse;

  const ErrorScreen({Key key, this.text="", this.html = false, this.ispResponse}) : super(key: key);

  mapToWidget(doc) {
    var keys = doc.keys.toList();
    return Container(
      color: Colors.yellow,
      padding: const EdgeInsets.all(8),
      child: Table(
          columnWidths: const {
            0: FractionColumnWidth(1 / 4),
            1: FractionColumnWidth(3 / 4),
          },
          children: List<TableRow>.generate(
            keys.length,
                (ki) {
              var k = keys.elementAt(ki);
              var value = doc[k];
              Widget keyWidget = Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text("$k: ")),
              );
              Widget valueWidget = Container();
              if (value.runtimeType == String ||
                  value.runtimeType == bool ||
                  value.runtimeType == int ||
                  value.runtimeType == double) {
                  valueWidget = valueWidget = InkWell(
                    child: Text(
                      "$value",
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
              } else if (value.runtimeType == List) {
                if (value.length == 0) value = [""];
                if (value[0].runtimeType == String ||
                    value[0].runtimeType == int ||
                    value[0].runtimeType == List ||
                    value[0].runtimeType == double) {
                  String t = "${value[0]}";
                  for (int v = 1; v < value.length; v++) {
                    t += ", ${value[v]}";
                    valueWidget = InkWell(
                      child: Text(
                        t,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }
                } else if (value[0].runtimeType == Map) {
                  valueWidget = mapToWidget(value);
                }
              } else if (value.runtimeType == Map) {
                valueWidget = mapToWidget(value);
              }

              return TableRow(children: [
                keyWidget,
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                  child: valueWidget,
                ),
              ]);
            },
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Error',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: html?Html(
            data: text,
          ):Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                SizedBox(height: 8,),
                Text("$text\n${ispResponse.message}"),
                mapToWidget(ispResponse.response["data"]??{}),
                SizedBox(height: 8,),
              ],
            ),
          ),
        )/*Text(widget.text)*/,
      ),
    );
  }
}
