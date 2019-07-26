import 'package:flutter/material.dart';
import 'package:tetris/blocs/blocBase.dart';
import 'package:tetris/blocs/gamePanelBloc.dart';

class ScoreBar extends StatefulWidget {
  ScoreBar({Key key});
  ScoreBarState createState() => ScoreBarState();
}

class ScoreBarState extends State<ScoreBar> with TickerProviderStateMixin{
  ScoreBarState({Key key});

  TextStyle basicTextStyle = TextStyle(color: Colors.white, fontSize: 18, decoration: TextDecoration.none);
  int _score = 0;

  AnimationController _scoreTweenController;
  Animation<double> _scoreTween;

  double int2Double (int num) {
    return num.floorToDouble();
  }

  @override
  void initState() { 
    super.initState();
  }

  // 播放加分动画
  void _playAddScoreAnimation (double begin, double end) async {
     _scoreTweenController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200)
    );
    _scoreTween =
      Tween(begin: begin, end: end)
      .animate(_scoreTweenController)
      ..addListener(() {
        this.setState(() {});
      }
    );
    await _scoreTweenController.forward();
  }

  Widget build (BuildContext context) {
    final GamePanelBloc gamePanelBloc = BlocProvider.of<GamePanelBloc>(context);
    return StreamBuilder<Map<String, int>>(
      stream: gamePanelBloc.checkPointStream,
      initialData: {'checkPoint': 1, 'speed': 1500, 'score': 0, 'gameOver': 0},
      builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
      if (snapshot.data['gameOver'] == 1) {
        Future.microtask(() => showDialog(
          context: context,
          barrierDismissible: false,
          builder: ((_) {
            return WillPopScope(
              onWillPop: () async {
                return Future.value(false);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 50, vertical: 220),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('游戏结束', style: basicTextStyle, ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Image.asset('assets/imgs/fd${snapshot.data['checkPoint'] > 6 ? 0 : snapshot.data['checkPoint']}-deep.png'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text('当前得分 ${_scoreTween == null ? snapshot.data['score'] : _scoreTween.value.floor()}', style: basicTextStyle),
                        Text('当前关卡 ${snapshot.data['checkPoint']}', style: basicTextStyle)
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 0),
                      child: RaisedButton(
                        child: Text('重新开始'),
                        color: Colors.green,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop();
                          gamePanelBloc.onRestart();
                          _playAddScoreAnimation(_scoreTween.value, 0);
                        },
                      ),
                    )
                  ],
                )
              )
            );
          })
        ));
      }
      if (snapshot.data['score'] > _score) {
        _playAddScoreAnimation(int2Double(_score), int2Double(snapshot.data['score']));
      }
      _score = snapshot.data['score'];
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('第${snapshot.data['checkPoint']}关', style: TextStyle(color: Colors.white)),
          Text('速度 ${snapshot.data['speed']}', style: TextStyle(color: Colors.white)),
          Text('得分：${_scoreTween == null ? _score : _scoreTween.value.floor()}', style: TextStyle(color: Colors.white)),
        ],
      );
    });
  }
}