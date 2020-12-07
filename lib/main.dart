import 'dart:math';

import 'package:flutter/material.dart';

import 'arm_widget.dart';
import 'ik/anchor.dart';
import 'ik/bone.dart';

const double gravity = 100;
const double dragCoefficient = 0;
const double ballSize = 50;

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
  bool armLocked = true;

  Duration lastUpdateCall = Duration();
  Offset lastBallLoc = Offset(0, 0);
  double maxScore = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(days: 99));
    controller.forward();
    _initializeArms();
    controller.addListener(_update);
  }

  _yToScore(double y, double screenHeight) {
    return -(y - screenHeight);
  }

  _scoreToY(double score, double screenHeight) {
    return -score + screenHeight;
  }

  _update() {
    if (!controller.isAnimating) {
      return;
    }

    double elapsedSeconds =
        (controller.lastElapsedDuration - lastUpdateCall).inMilliseconds / 1000;

    Size screenSize = MediaQuery.of(context).size;
    if (!ballFrozen) {
      ballLoc += ballVelocity * elapsedSeconds;
      double score = _yToScore(ballLoc.dy, screenSize.height);
      if (score > maxScore) {
        setState(() {
          maxScore = score;
        });
      }
      ballVelocity *= (1 - dragCoefficient * elapsedSeconds);
      ballVelocity = ballVelocity.translate(0, gravity * elapsedSeconds);
    }

    Offset overlap = arm.overlaps(ballLoc, ballSize / 2);
    if (overlap != null) {
      ballFrozen = false;
      ballLoc -= overlap;

      if (elapsedSeconds > 0) {
        ballVelocity = (ballLoc - lastBallLoc) / elapsedSeconds;
      }
    }

    if (ballLoc.dx < ballSize / 3 ||
        ballLoc.dx > screenSize.width - ballSize / 3 ||
        ballLoc.dy > screenSize.height + 30) {
      ballLoc = Offset(screenSize.width / 4, 3 / 4 * screenSize.height);
      ballFrozen = true;
      arm.child.angle = -pi / 2;
      arm.child.child.angle = -pi / 2;
      armLocked = true;
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
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (DragUpdateDetails deets) {
          setState(() {
            if (!armLocked) {
              arm.solve(deets.globalPosition);
            }
          });
        },
        onPanStart: (DragStartDetails deets) {
          setState(() {
            if (!armLocked) {
              arm.solve(deets.globalPosition);
            }
          });
        },
        onTap: () {
          armLocked = false;
        },
        child: Stack(children: [
          AnimatedBuilder(
              animation: controller,
              builder: (context, snapshot) {
                double screenScalar = max(
                    _yToScore(ballLoc.dy, screenSize.height) /
                        screenSize.height,
                    1);
                Size armSize = screenSize / screenScalar;
                return Positioned(
                    bottom: 0,
                    left: (screenSize.width - armSize.width) / 2,
                    width: armSize.width,
                    height: armSize.height,
                    child: Arm(anchor: arm, scaleFactor: 1 / screenScalar));
              }),
          Positioned.fill(
              child: Stack(alignment: Alignment.center, children: [
            AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  double screenScalar = max(
                      _yToScore(ballLoc.dy, screenSize.height) /
                          screenSize.height,
                      1);
                  Size armSize = screenSize / screenScalar;
                  return Positioned(
                    left: (screenSize.width - armSize.width) / 2 +
                        (ballLoc.dx / screenScalar) -
                        (ballSize / screenScalar) / 2,
                    top: max(ballLoc.dy - ballSize / 2, 0),
                    child: Container(
                      width: ballSize / screenScalar,
                      height: ballSize / screenScalar,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                              BorderRadius.all(Radius.circular(9999))),
                    ),
                  );
                }),
            // AnimatedBuilder(
            //     animation: controller,
            //     builder: (context, _) {
            //       return Positioned(
            //         left: 0,
            //         top: _scoreToY(maxScore, screenSize.height),
            //         right: 0,
            //         child: Container(
            //           height: 5,
            //           decoration: BoxDecoration(color: Colors.green),
            //         ),
            //       );
            //     }),
          ])),
          Align(
              alignment: Alignment(0, -.5),
              child:
                  Text("${maxScore.round()}", style: TextStyle(fontSize: 48)))
        ]),
      ),
    );
  }
}
