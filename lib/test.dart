import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Test extends StatefulWidget {
  Test({Key key});
  createState() => TestState();
}

class TestState extends State<Test> with SingleTickerProviderStateMixin {
  TestState({Key key});

  Animation<RelativeRect> _numCurve;
  AnimationController _numCurveController;

  @override
  void initState() { 
    super.initState();
    _numCurveController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
      animationBehavior: AnimationBehavior.preserve
    );
    _numCurve = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0, 50, 0, 0),
      end: RelativeRect.fromLTRB(0, 300, 0, 0),
    ).animate(
      CurvedAnimation(parent: _numCurveController, curve: Curves.easeInOutBack)
    );
  }

  void _handlePlayAnimation () {
    _numCurveController.forward();
    Timer(Duration(milliseconds: 2000), () {
      _numCurveController.reverse();
    });
  }


  Widget build (BuildContext context) {
    return Stack(
        children: <Widget> [
          RaisedButton(child: Text('开始动画'), onPressed: () {
            _handlePlayAnimation();
          }),
          PositionedTransition(
            rect: _numCurve,
            child: Text('float', style: TextStyle(fontSize: 30, color: Colors.white),)
          )
    ]);
  }
}