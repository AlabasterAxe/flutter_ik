import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RobotAnim(),
    );
  }
}

class RobotAnim extends StatefulWidget {
  RobotAnim({Key key}) : super(key: key);

  @override
  _RobotAnimState createState() => _RobotAnimState();
}

class _RobotAnimState extends State<RobotAnim> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FlareActor("assets/robot.flr",
          artboard: "Artboard", animation: "Untitled", fit: BoxFit.contain),
    );
  }
}
