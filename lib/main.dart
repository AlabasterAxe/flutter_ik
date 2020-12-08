import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ik/view-transformation.dart';
import 'package:flutter_ik/warning-tape-painter.dart';

import 'arm_widget.dart';
import 'ik/anchor.dart';
import 'ik/bone.dart';

const double gravity = -100;
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

  AnimationController _controller;

  bool _ballFrozen = true;
  bool _armLocked = true;

  Duration _lastUpdateCall = Duration();
  Offset _lastBallLoc = Offset(0, 0);
  double _maxScoreY;
  double _scoreOffsets = 0;
  double _currentScoreOpacity = 0;

  int _scoreLock;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(days: 99));
    _controller.forward();
    _initializeArms();
    _controller.addListener(_update);
  }

  _update() {
    if (!_controller.isAnimating) {
      return;
    }

    double elapsedSeconds =
        (_controller.lastElapsedDuration - _lastUpdateCall).inMilliseconds /
            1000;

    Size screenSize = MediaQuery.of(context).size;
    if (!_ballFrozen) {
      ballWorldLoc += ballWorldVelocity * elapsedSeconds;
      if (_maxScoreY == null || ballWorldLoc.dy > _maxScoreY) {
        setState(() {
          _maxScoreY = ballWorldLoc.dy;
        });
      }
      ballWorldVelocity =
          ballWorldVelocity.translate(0, gravity * elapsedSeconds);
    }

    Offset overlap = arm.overlaps(ballWorldLoc, ballSize / 2);
    if (overlap != null) {
      _ballFrozen = false;
      setState(() {
        _scoreOffsets = .1;
        _currentScoreOpacity = 1;
        _scoreLock = null;
      });
      ballWorldLoc -= overlap;

      if (elapsedSeconds > 0) {
        ballWorldVelocity = (ballWorldLoc - _lastBallLoc) / elapsedSeconds;
      }
    }

    if (ballWorldLoc.dx < ballSize / 2 ||
        ballWorldLoc.dx > screenSize.width - ballSize / 2 ||
        ballWorldLoc.dy < -ballSize / 2) {
      _ballFrozen = true;
      _armLocked = true;
    }

    _lastBallLoc = ballWorldLoc;
    _lastUpdateCall = _controller.lastElapsedDuration;
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
      _currentScoreOpacity = 0;
      _scoreOffsets = 0;
      _scoreLock = ballWorldLoc.dy.round();
    });
    arm.loc = Offset(screenSize.width / 2, screenSize.height / 4);
    arm.child.angle = -pi / 2;
    arm.child.child.angle = -pi / 2;
    ballWorldLoc = Offset(screenSize.width / 4, screenSize.height / 4);
    _ballFrozen = true;
    _armLocked = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _reset();
  }

  Rect _getWorldViewRect(Size screenSize) {
    double screenScalar =
        max((ballWorldLoc.dy + ballBuffer) / screenSize.height, 1);
    Size viewSize = screenSize * screenScalar;
    return Rect.fromLTRB(
        -(viewSize.width - screenSize.width) / 2,
        screenSize.height * screenScalar,
        screenSize.width * screenScalar -
            (viewSize.width - screenSize.width) / 2,
        0);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (DragUpdateDetails deets) {
          setState(() {
            if (!_armLocked) {
              ViewTransformation vt = ViewTransformation(
                  from:
                      Rect.fromLTRB(0, 0, screenSize.width, screenSize.height),
                  to: _getWorldViewRect(screenSize));
              arm.solve(vt.forward(deets.globalPosition));
            }
          });
        },
        onPanStart: (DragStartDetails deets) {
          setState(() {
            if (!_armLocked) {
              ViewTransformation vt = ViewTransformation(
                  from:
                      Rect.fromLTRB(0, 0, screenSize.width, screenSize.height),
                  to: _getWorldViewRect(screenSize));
              arm.solve(vt.forward(deets.globalPosition));
            }
          });
        },
        onTap: () {
          _reset();
        },
        child: Stack(children: [
          Positioned.fill(
              child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    double screenScalar = max(
                        (ballWorldLoc.dy + ballBuffer) / screenSize.height, 1);
                    ViewTransformation vt = ViewTransformation(
                        to: Rect.fromLTRB(
                            0, 0, screenSize.width, screenSize.height),
                        from: _getWorldViewRect(screenSize));

                    Offset ballScreenLoc = vt.forward(ballWorldLoc);
                    List<Widget> stackChildren = [
                      Positioned.fill(child: Arm(anchor: arm, vt: vt)),
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

                    if (_maxScoreY != null) {
                      stackChildren.add(Positioned(
                        left: 0,
                        top: vt.forward(Offset(0, _maxScoreY)).dy -
                            ballSize / screenScalar / 2 -
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
                        width: (screenSize.width -
                                vt.scaleForwards(screenSize.width)) /
                            2,
                        top: 0,
                        bottom: 0,
                        child: ClipRect(
                            clipper: WarningTapeClipper(),
                            child: CustomPaint(
                                painter: WarningTapePainter(screenScalar)))));
                    stackChildren.add(Positioned(
                        right: 0,
                        width: (screenSize.width -
                                vt.scaleForwards(screenSize.width)) /
                            2,
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
              alignment: Alignment(0, -.5 - _scoreOffsets),
              child: Text("${_maxScoreY == null ? 0 : _maxScoreY.round()}",
                  style: TextStyle(fontSize: 48))),
          AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: _currentScoreOpacity,
            child: AnimatedAlign(
                duration: Duration(milliseconds: 300),
                alignment: Alignment(0, -.5 + _scoreOffsets),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Text(
                      "${_scoreLock != null ? _scoreLock : ballWorldLoc.dy.round()}",
                      style: TextStyle(fontSize: 48)),
                )),
          )
        ]),
      ),
    );
  }
}
