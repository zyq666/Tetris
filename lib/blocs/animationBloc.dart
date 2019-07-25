import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tetris/blocs/animationBlocBase.dart';

class AnimationBloc implements AnimationBlocBase {

  AnimationController tween;

  StreamController<Animation<double>> tweenController = StreamController<Animation<double>>.broadcast();
  StreamSink<Animation<double>> get tweenSink => tweenController.sink;

  AnimationBloc() {
    // tween = AnimationController(
    //   vsync: this,
    //   duration: 3
    // );
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
  
  
}