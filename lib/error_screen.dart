import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ErrorScreen extends StatefulWidget {

  final error;
  final bool html;

  const ErrorScreen({Key key, this.error, this.html}) : super(key: key);

  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
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
          child: widget.html?Html(
            data: widget.error,
          ):Text("${widget.error}"),
        )/*Text(widget.error)*/,
      ),
    );
  }
}
