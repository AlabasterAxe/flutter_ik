import 'package:flutter/material.dart';

import 'arm_widget.dart';
import 'ik/anchor.dart';
import 'ik/bone.dart';

const double gravity = 100;
const double dragCoefficient = 0;

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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Anchor arm;
  Offset ballLoc = Offset(0, 0);
  Offset ballVelocity = Offset(0, 0);

  AnimationController controller;

  bool ballFrozen = true;

  Duration lastUpdateCall = Duration();
  Offset lastBallLoc = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(days: 99));
    controller.forward();
    _initializeArms();
    controller.addListener(_update);
  }

  _update() {
    if (!controller.isAnimating) {
      return;
    }

    double elapsedSeconds =
        (controller.lastElapsedDuration - lastUpdateCall).inMilliseconds / 1000;

    if (!ballFrozen) {
      ballLoc += ballVelocity * elapsedSeconds;
      ballVelocity *= (1 - dragCoefficient * elapsedSeconds);
      ballVelocity = ballVelocity.translate(0, gravity * elapsedSeconds);
    }

    Offset overlap = arm.overlaps(ballLoc, 12.5);
    if (overlap != null) {
      ballFrozen = false;
      ballLoc -= overlap;

      if (elapsedSeconds > 0) {
        ballVelocity = (ballLoc - lastBallLoc) / elapsedSeconds;
      }
    }

    Size screenSize = MediaQuery.of(context).size;
    if (ballLoc.dx < -30 || ballLoc.dx > screenSize.width + 30) {
      ballLoc = Offset(screenSize.width / 4, 3 / 4 * screenSize.height);
      ballFrozen = true;
    }

    lastBallLoc = ballLoc;
    lastUpdateCall = controller.lastElapsedDuration;
  }

  _initializeArms() {
    for (int i = 0; i < 1; i++) {
      arm = Anchor(loc: Offset(0, 0));
      Bone b = Bone(70.0, arm);
      arm.child = b;
      Bone b2 = Bone(70.0, b);
      b.child = b2;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Size screenSize = MediaQuery.of(context).size;
    arm.loc = Offset(screenSize.width / 2, 3 / 4 * screenSize.height);

    ballLoc = Offset(screenSize.width / 4, 3 / 4 * screenSize.height);
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
        onPanStart: (DragStartDetails deets) {
          setState(() {
            arm.solve(deets.globalPosition);
          });
        },
        child: Stack(children: [
          Positioned.fill(child: Arm(anchor: arm)),
          Positioned.fill(
              child: Stack(alignment: Alignment.center, children: [
            AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return Positioned(
                    left: ballLoc.dx - 25 / 2,
                    top: ballLoc.dy - 25 / 2,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                              BorderRadius.all(Radius.circular(9999))),
                    ),
                  );
                }),
          ])),
        ]),
      ),
    );
  }
}
