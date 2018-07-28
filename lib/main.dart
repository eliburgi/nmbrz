import 'package:flutter/material.dart';
import 'package:nmbrz/page_home.dart';
import 'constants.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      home: HomePage(),
      theme: ThemeData(
        primaryColor: primaryColor,
        accentColor: accentColor,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
