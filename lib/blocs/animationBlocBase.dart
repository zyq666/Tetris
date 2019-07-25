import 'package:flutter/material.dart';

// 所有 BLoCs 的通用接口
abstract class AnimationBlocBase {
  void dispose();
}

// 通用 BLoC provider
class AnimationBlocProvider<T extends AnimationBlocBase> extends StatefulWidget {
  AnimationBlocProvider({
    Key key,
    @required this.child,
    @required this.bloc,
  }): super(key: key);

  final T bloc;
  final Widget child;

  @override
  _AnimationBlocProviderState<T> createState() => _AnimationBlocProviderState<T>();

  static T of<T extends AnimationBlocBase>(BuildContext context){
    final type = _typeOf<AnimationBlocProvider<T>>();
    AnimationBlocProvider<T> provider = context.ancestorWidgetOfExactType(type);
    return provider.bloc;
  }

  static Type _typeOf<T>() => T;
}

class _AnimationBlocProviderState<T> extends State<AnimationBlocProvider<AnimationBlocBase>> with TickerProviderStateMixin{
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose(){
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return widget.child;
  }
}