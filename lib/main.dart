import 'dart:math';

import 'package:flutter/material.dart';

import 'arm_widget.dart';
import 'ik/anchor.dart';
import 'ik/bone.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Anchor arm = Anchor();

  @override
  void initState() {
    super.initState();

    arm = Anchor(loc: Offset(0, 0));
    Bone b = Bone(Random().nextInt(30) + 70.0, arm);
    arm.setChild(b);
    Bone b2 = Bone(Random().nextInt(30) + 70.0, b);
    b.setChild(b2);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    arm.loc = (Offset(0, 0) & MediaQuery.of(context).size).bottomRight / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (DragUpdateDetails deets) {
          setState(() {
            arm.solve(deets.globalPosition);
          });
        },
        child: Stack(children: [Positioned.fill(child: Arm(anchor: arm))]),
      ),
    );
  }
}
