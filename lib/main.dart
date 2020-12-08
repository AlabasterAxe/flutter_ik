import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ik/view-transformation.dart';
import 'package:flutter_ik/warning-tape-painter.dart';

import 'arm_widget.dart';
import 'ik/anchor.dart';
import 'ik/bone.dart';

const double gravity = 100;
const double dragCoefficient = 0;
const double ballSize = 50;
const double ballBuffer = 50;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Anchor arm;
  Offset ballWorldLoc = Offset(0, 0);
  Offset ballWorldVelocity = Offset(0, 0);

  AnimationController controller;

  bool ballFrozen = true;
  bool armLocked = true;

  Duration lastUpdateCall = Duration();
  Offset _lastBallLoc = Offset(0, 0);
  double maxScoreY;
  double offset = 0;
  double currentScoreOpacity = 0;

  int scoreLock;

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

  _scoreToY(double score, double screenHeight, double currentY) {
    if (_yToScore(currentY, screenHeight) + 50 > screenHeight) {
      return _yToScore(currentY, screenHeight) -
          _yToScore(score, screenHeight) +
          50;
    }
    return -_yToScore(score, screenHeight) + screenHeight - ballSize / 2;
  }

  _update() {
    if (!controller.isAnimating) {
      return;
    }

    double elapsedSeconds =
        (controller.lastElapsedDuration - lastUpdateCall).inMilliseconds / 1000;

    Size screenSize = MediaQuery.of(context).size;
    if (!ballFrozen) {
      ballWorldLoc += ballWorldVelocity * elapsedSeconds;
      if (maxScoreY == null ||
          _yToScore(ballWorldLoc.dy, screenSize.height) >
              _yToScore(maxScoreY, screenSize.height)) {
        setState(() {
          maxScoreY = ballWorldLoc.dy;
        });
      }
      ballWorldVelocity *= (1 - dragCoefficient * elapsedSeconds);
      ballWorldVelocity =
          ballWorldVelocity.translate(0, gravity * elapsedSeconds);
    }

    Offset overlap = arm.overlaps(ballWorldLoc, ballSize / 2);
    if (overlap != null) {
      ballFrozen = false;
      setState(() {
        offset = .1;
        currentScoreOpacity = 1;
        scoreLock = null;
      });
      ballWorldLoc -= overlap;

      if (elapsedSeconds > 0) {
        ballWorldVelocity = (ballWorldLoc - _lastBallLoc) / elapsedSeconds;
      }
    }

    if (ballWorldLoc.dx < ballSize / 2 ||
        ballWorldLoc.dx > screenSize.width - ballSize / 2 ||
        ballWorldLoc.dy > screenSize.height + 30) {
      ballFrozen = true;
      armLocked = true;
    }

    _lastBallLoc = ballWorldLoc;
    lastUpdateCall = controller.lastElapsedDuration;
  }

  _initializeArms() {
    for (int i = 0; i < 1; i++) {
      arm = Anchor(loc: Offset(0, 0));
      Bone b = Bone(70.0, arm);
      arm.child = b;
      arm.child.angle = -pi / 2;
      Bone b2 = Bone(70.0, b);
      b.child = b2;
      arm.child.child.angle = -pi / 2;
    }
  }

  _reset() {
    Size screenSize = MediaQuery.of(context).size;

    setState(() {
      currentScoreOpacity = 0;
      offset = 0;
      scoreLock = _yToScore(ballWorldLoc.dy, screenSize.height).round();
    });
    arm.loc = Offset(screenSize.width / 2, screenSize.height / 4);
    arm.child.angle = -pi / 2;
    arm.child.child.angle = -pi / 2;
    ballWorldLoc = Offset(screenSize.width / 4, screenSize.height / 4);
    ballFrozen = true;
    armLocked = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _reset();
    Size screenSize = MediaQuery.of(context).size;

    ballWorldLoc = Offset(screenSize.width / 4, screenSize.height / 4);
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
          _reset();
        },
        child: Stack(children: [
          Positioned.fill(
              child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    double screenScalar = max(
                        (_yToScore(ballWorldLoc.dy, screenSize.height) +
                                ballBuffer) /
                            screenSize.height,
                        1);
                    Size armSize = screenSize / screenScalar;
                    ViewTransformation vt = ViewTransformation(
                        b: Rect.fromLTRB(
                            0, 0, screenSize.width, screenSize.height),
                        a: Rect.fromLTRB(
                            -(screenSize.width - armSize.width) / 2,
                            max(ballWorldLoc.dy + ballBuffer, screenSize.width),
                            screenSize.width * screenScalar,
                            0));

                    Offset ballScreenLoc = vt.aToB(ballWorldLoc);
                    List<Widget> stackChildren = [
                      Positioned(
                          bottom: 0,
                          left: (screenSize.width - armSize.width) / 2,
                          width: armSize.width,
                          height: armSize.height,
                          child: Arm(anchor: arm, vt: vt)),
                      Positioned(
                        left: ballScreenLoc.dx - (ballSize / screenScalar) / 2,
                        top: ballScreenLoc.dy - (ballSize / screenScalar) / 2,
                        child: Container(
                          width: ballSize / screenScalar,
                          height: ballSize / screenScalar,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(9999))),
                        ),
                      ),
                    ];

                    if (maxScoreY != null) {
                      stackChildren.add(Positioned(
                        left: 0,
                        top: _scoreToY(
                                maxScoreY, screenSize.width, ballWorldLoc.dy) -
                            5,
                        right: 0,
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(color: Colors.green),
                        ),
                      ));
                    }
                    stackChildren.add(Positioned(
                        left: 0,
                        width: (screenSize.width - armSize.width) / 2,
                        top: 0,
                        bottom: 0,
                        child: ClipRect(
                            clipper: WarningTapeClipper(),
                            child: CustomPaint(
                                painter: WarningTapePainter(screenScalar)))));
                    stackChildren.add(Positioned(
                        right: 0,
                        width: (screenSize.width - armSize.width) / 2,
                        top: 0,
                        bottom: 0,
                        child: ClipRect(
                            clipper: WarningTapeClipper(),
                            child: CustomPaint(
                                painter: WarningTapePainter(screenScalar)))));
                    return Stack(
                        alignment: Alignment.center, children: stackChildren);
                  })),
          AnimatedAlign(
              duration: Duration(milliseconds: 300),
              alignment: Alignment(0, -.5 - offset),
              child: Text(
                  "${maxScoreY == null ? 0 : _yToScore(maxScoreY, screenSize.height).round()}",
                  style: TextStyle(fontSize: 48))),
          AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: currentScoreOpacity,
            child: AnimatedAlign(
                duration: Duration(milliseconds: 300),
                alignment: Alignment(0, -.5 + offset),
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) => Text(
                      "${scoreLock != null ? scoreLock : _yToScore(ballWorldLoc.dy, screenSize.height).round()}",
                      style: TextStyle(fontSize: 48)),
                )),
          )
        ]),
      ),
    );
  }
}
