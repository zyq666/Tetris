import 'package:flutter/material.dart';

class ColorTween extends StatefulWidget {
  ColorTween({Key key});
  createState() => ColorTweenState();
}

class ColorTweenState extends State<ColorTween> with SingleTickerProviderStateMixin {
  ColorTweenState({Key key});

  AnimationController colorTweenController; 

  @override
  void initState() { 
    super.initState();
    colorTweenController = new AnimationController(
      vsync: this, duration: new Duration(seconds: 3));
  }

  Widget build (BuildContext context) {
    return Text('animation');
  }
}

class NumTween extends StatefulWidget {
  final double begin;
  final double end;
  NumTween({Key key, this.begin, this.end});
  createState() => NumTweenState();
}

class NumTweenState extends State<NumTween> with SingleTickerProviderStateMixin {
  NumTweenState({Key key});
  Animation<double> numTween;
  AnimationController numTweenController; 

  @override
  void initState() { 
    super.initState();
    numTweenController = AnimationController(
      vsync: this, duration: Duration(seconds: 3));
    numTween = Tween(begin: widget.begin, end: widget.end).animate(numTweenController)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
  }

  Widget build (BuildContext context) {
    return Text('animation');
  }
}