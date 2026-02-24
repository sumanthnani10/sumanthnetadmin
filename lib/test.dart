import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Webb extends StatefulWidget {
  const Webb({Key key}) : super(key: key);

  @override
  _WebbState createState() => _WebbState();
}

class _WebbState extends State<Webb> {

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Web View"),
      ),
      body: SafeArea(
        child: WebView(
          initialUrl: "http://jobs.rohtechnologies.net",
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
