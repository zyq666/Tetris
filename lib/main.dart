import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tetris/blocs/gamePanelBloc.dart';
import 'package:tetris/components/gamePanel.dart';
import 'package:tetris/components/scoreBar.dart';
import 'package:tetris/components/tool.dart';
import 'blocs/blocBase.dart';

void main() => runApp(Tetris());

class Tetris extends StatelessWidget {
  // This widget is the root of your application.
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: '俄罗斯方块',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.grey,
      ),
      home: BlocProvider<GamePanelBloc>(
        bloc: GamePanelBloc(10, 15),
        child: Main(title: '俄罗斯方块')
      )
    );
  }
}

class Main extends StatefulWidget {
  final String title;
  Main({Key key, this.title}) : super(key: key);
  MainState createState() => MainState();
}

class MainState extends State<Main> with TickerProviderStateMixin {
  int _currentLevel = 1;
  int _score = 0;
  AnimationStatus _positionStatus;
  Animation<RelativeRect> _positionTween;
  AnimationController _positionTweenController;
  
  @override
  void initState() {
    // TODO: implement initState
    _positionTweenController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500)
    );
    _positionTween = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0, -600, 0, 0),
      end: RelativeRect.fromLTRB(0, -500, 0, 0)
    ).animate(
      CurvedAnimation(parent: _positionTweenController, curve: Curves.easeInOutBack)
    );
    _positionTweenController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        this.setState(() {
          _positionStatus = status;
        });
      }
    });
    super.initState();
  }

  // 播放加分/升级动画
  void _playPositionTween () {
    _positionTweenController.forward();
    Future.delayed(Duration(seconds: 3), () {
      _positionTweenController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final GamePanelBloc gamePanelBloc = BlocProvider.of<GamePanelBloc>(context);

    return StreamBuilder<Map<String, int>>(
      stream: gamePanelBloc.checkPointStream,
      initialData: {'checkPoint': 1, 'score': 0, 'gameOver': 0},
      builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
        String tips = "";
        if (snapshot.data['checkPoint'] > _currentLevel) {
          // todo 升级动画
          tips = '难度升级!';
          _playPositionTween();
        } else if (snapshot.data['score'] > _score) {
          // todo 加分动画
          tips = '+${snapshot.data['score'] - _score}';
          _playPositionTween();
        }
        _currentLevel = snapshot.data['checkPoint'];
        _score = snapshot.data['score'];
        return Scaffold(
          backgroundColor: Colors.grey[700],
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 70),
            child: Column(
              children: <Widget>[
                ScoreBar(),
                Expanded(
                  child: Stack(
                    children: <Widget> [
                      GamePanel(),
                      PositionedTransition(
                        rect: _positionTween,
                        child: UnconstrainedBox(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                            decoration: BoxDecoration(
                              color: Color(0xFFfac945),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            child: Text(tips, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Color(0xff5a5854), fontWeight: FontWeight.bold)),
                          ),
                        )
                      )
                    ]
                  )
                ),
                Tool()
              ],
            )
          ),
        );
      }
    );
  }
}