import 'dart:async';
import 'package:audioplayer/audioplayer.dart';
import 'package:tetris/blocs/blocBase.dart';
import 'package:tetris/components/squares.dart';

// 音乐地址
Map<String, String> musicUrl = {
  'bgm': 'http://pv39w6kvh.bkt.clouddn.com/bgm-update.mp3',
  'addScore': 'http://pv39w6kvh.bkt.clouddn.com/addScore-update.mp3',
  'upLevel': 'http://pv39w6kvh.bkt.clouddn.com/upLevel.mp3',
  'gameOver': 'http://pv39w6kvh.bkt.clouddn.com/fail.mp3',
  'pressTip': 'http://pv39w6kvh.bkt.clouddn.com/pressTip.mp3'
};

// 等级规则<等级，规则>
Map<int, Map<String, int>> _gameRule = {
  1: {
    'score': 0,
    'speed': 1500
  },
  2: {
    'score': 10,
    'speed': 1300
  },
  3: {
    'score': 50,
    'speed': 1000
  },
  4: {
    'score': 70,
    'speed': 800
  },
  5: {
    'score': 100,
    'speed': 600
  },
  6: {
    'score': 120,
    'speed': 400
  },
  7: {
    'score': 140,
    'speed': 200
  },
  8: {
    'score': 160,
    'speed': 100
  },
  9: {
    'score': 180,
    'speed': 80
  },
  10: {
    'score': 200,
    'speed': 50
  }
};

// 加分规则<消除行数，分值>
Map<int, int> _passRule = {
  1: 10,
  2: 30,
  3: 60,
  4: 100
};

class GamePanelBloc implements BlocBase {
  AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription _audioPlayerStateSubscription;

  GamePanelBloc(int rows, int columns) {
    // 设置音乐
    _audioPlayer.play(musicUrl['bgm']);
    // _audioPlayer.setReleaseMode(ReleaseMode.LOOP);

    // 初始化关卡行列数
    _rows = rows;
    _columns = columns;

    // 初始化场景
    _initGridList(rows, columns);

    // 生成活动方块
    _buildCurrentSquare();

    // 监听场景流
    _actionGridListController.stream.listen((_) => _handleChangeGridList()); 

    // 触发render场景
    outerGridSink.add(null);
        
    // 监听方向控制流
    _actionDirectionController.stream.listen((String data) => _handleChangeDirection(data));

    // 监听关卡信息流
    _actionCheckPointController.stream.listen((_) => _handleChangeScore());

    // 监听下一个方块形状
    _actionNextController.stream.listen((_) => _handleChangeNextSquare());
  }
 
  int _rows;                                                   // 关卡总行数
  int _columns;                                                // 关卡列行数
  Timer timer;                                                 // 定时器
  int _score = 0;                                              // 总分
  int _checkPoint = 1;                                         // 关卡数
  bool _gameOver = false;                                      // 游戏结束标识
  Map<String, int> _currentPosition = {};                      // 活动方块的当前位置
  List<List<int>> _currentSquare = [];                         // 活动方块
  List<List<int>> _nextSquare;                                 // 下一个方块
  int _currentSquareColumns;                                   // 当前活动方块所占列数
  int _currentSquareRows;                                      // 当前活动方块所占行数 
  List<List<int>> _gridList = [];                              // 场景列表
  Map<String, int> _panelOrigin = {'x': 0, 'y': 0};            // 场景中心点（生成方块的初始位置）
  Map<String, int> _prePosition = {};                          // 方块移动前的位置

  // 方向
  StreamController<String> _directionController = StreamController<String>();
  StreamController<String> _actionDirectionController = StreamController<String>();
  StreamController<List<List<int>>> _actionGridListController = StreamController<List<List<int>>>();
  StreamSink<String> get changeDirection => _directionController.sink;
  Stream<String> get directionStream => _directionController.stream;
  StreamSink<String> get innerChangeDirection => _actionDirectionController.sink;

  // 布局
  StreamController<List<List<int>>> _gridListController = StreamController<List<List<int>>>();
  StreamSink<List<List<int>>> get changeGridSink => _gridListController.sink;
  Stream<List<List<int>>> get gridListStream => _gridListController.stream;
  StreamSink<List<List<int>>> get outerGridSink => _actionGridListController.sink;

  // 关卡信息
  StreamController<Map<String, int>> checkPointController = StreamController<Map<String, int>>.broadcast();
  Stream <Map<String, int>> get checkPointStream => checkPointController.stream;
  StreamSink <Map<String, int>> get _outerCheckPointSink => checkPointController.sink;
  StreamController<Map<String, int>> _actionCheckPointController = StreamController<Map<String, int>>.broadcast();
  StreamSink <Map<String, int>> get _changeCheckoutPoint => _actionCheckPointController.sink;

  // 下一个方块流
  StreamController<List<List<int>>> nextSquareController = StreamController<List<List<int>>>();
  StreamSink<List<List<int>>> get _changeSquareSink => nextSquareController.sink;
  StreamController<List<List<int>>> _actionNextController = StreamController<List<List<int>>>();

  // 初始化游戏场景
  List<List<int>> _initGridList (int rows, int columns) => _gridList = List<List<int>>.generate(rows, (_) => List<int>.filled(columns, 0));

  // 设置分数关卡
  void _handleChangeScore () {
    _outerCheckPointSink.add({
      'score': _score,
      'checkPoint': _checkPoint,
      'gameOver': _gameOver ? 1 : 0,
      'speed': _gameRule[_checkPoint]['speed']
    });
  }
  
  // 设置方块定时下落
  void _setTimeInterval (Duration time) {
    if (null != timer && timer.isActive) timer.cancel();
    timer = Timer.periodic(time, (_) {
      // 触发下落事件
      innerChangeDirection.add('down');
    });
  }

  // 获取下一个方块形状
  void _handleChangeNextSquare () {
    List<List<int>> nextSquare = Squares.randomGenrate(current: false);
    _nextSquare = List<List<int>>.generate(4, (int index) => List<int>.filled(4, 0));
    Map<String, int> nextOrigin = {
      'x': (4-nextSquare.length)~/2,
      'y': (4-nextSquare[0].length)~/2
    };
    for(int row = 0; row < nextSquare.length; row++) {
      for(int column = 0; column < nextSquare[row].length; column++) {
        _nextSquare[row + nextOrigin['x']][column + nextOrigin['y']] = nextSquare[row][column];
      }
    }
    _changeSquareSink.add(_nextSquare);
  }

  // 判断当前位置是否允许变形
  bool _isCanTransform (List<List<int>> squares) {
    List<bool> canTransform = List<bool>.filled(squares.length * squares[0].length, false);
    int index = 0;
    for(int row = 0; row < squares.length; row++) {
      for (int column = 0; column < squares[row].length; column++) {
        canTransform[index] = _currentPosition['x'] + row < _rows && _currentPosition['y'] + column < _columns && _gridList[_currentPosition['x'] + row][_currentPosition['y']+column] != 2;
        index++;
      }
    }
    return canTransform.every((result) => result);
  } 

  // 检查有满行则消除
  void _checkFullRow () async {
    List<List<int>> newList = List<List<int>>.generate(_columns, (row) {
      return List<int>.generate(_rows, (column) {
        return _gridList[column][row];
      });
    });
    List<int> fullRow = [];
    int allEmptyRow;
    for(int row = 0; row < newList.length; row++) {
      if (newList[row].every((value) => value == 2)) fullRow.add(row);
      if (newList[row].every((value) => value == 0)) allEmptyRow = row; 
    }
    if (null != fullRow && fullRow.length > 0) {
      fullRow.forEach((full) {
        for(int moveRow = full; moveRow > allEmptyRow; moveRow--) {
          _gridList.forEach((row) {
            row[moveRow] = row[moveRow - 1];
          });
        }
      });
      _score+=_passRule[fullRow.length];
      _gameRule.keys.toList().where((key) =>_score >= _gameRule[key]['score']).forEach((currentPoint) async{
        if (currentPoint > _checkPoint) {
          AudioPlayer _upLevelPlayer = AudioPlayer();
          await _upLevelPlayer.play(musicUrl['upLevel']);
          _checkPoint = currentPoint;
        } else {
          AudioPlayer _passAudio = AudioPlayer();
          await _passAudio.play(musicUrl['addScore']);
        }
        _handleChangeScore();
      });
    }
  }
  
  // 生成活动方块
  void _buildCurrentSquare ({bool isTransform: false}) {
    // 是否为方块变形
    if (isTransform) {
      // 在同类型的方块中变换形状
      List<List<int>> newSquare = Squares.randomSameShape();
      if (_isCanTransform(newSquare)) {
        _currentSquare.clear();
        _removePrePosition(position: _currentPosition);
        _currentSquare = List<List<int>>.generate(newSquare.length, (index) => newSquare[index]);
      }
    } else {
      // 设置中心点
      _panelOrigin = {'x': (_rows~/2)-1, 'y': 0};
      // 初始化活动方块的位置
      _currentPosition = {..._panelOrigin};
      // 随机生成方块
      _currentSquare = Squares.randomGenrate(current: true);
      _actionNextController.sink.add(null);
    }
    _currentSquareRows = _currentSquare.length;
    _currentSquareColumns = _currentSquare[0].length;

    for(int row = 0; row < _currentSquare.length; row++) {
      for(int column = 0; column < _currentSquare[row].length; column++) {
        if (_gridList[_panelOrigin['x'] + column][_panelOrigin['y'] + row] == 2) {
          _gameOver = true;
          _changeCheckoutPoint.add(null);
        }
      }
    }

    if (_gameOver) {
      _audioPlayer.stop();
      AudioPlayer _gameOverPlayer = AudioPlayer();
      _gameOverPlayer.play(musicUrl['gameOver']);
    }
    // 开启定时器
    if(!_gameOver && !isTransform) _setTimeInterval(Duration(milliseconds: _gameRule[_checkPoint]['speed']));
  }

  // 根据方向当前方块底部缺口处
  List<int> _squareBottomEmpty (String direction, Map<String, int> position) {
    List<int> lastOne = List();
    switch (direction) {
      case 'down': 
        lastOne = List<int>.filled(_currentSquareRows, 0);
        for(int row = 0; row < _currentSquareRows; row++) {
          for(int column = 0; column < _currentSquareColumns; column++) {
            if (_gridList[position['x'] + row][position['y'] + column] == 1) {
              lastOne[row] = column;
            }
          }
        }
        break;
      case 'left':
        lastOne = List<int>.filled(_currentSquareColumns, 0);
        if (position['x'] - 1 >= 0 && position['x'] + 1 < _rows)
        for(int column = 0; column < _currentSquareColumns; column++) {
          if (_gridList[position['x']][position['y'] + column] == 1) {
            lastOne[column] = 1;
          }
        }
        break;
      case 'right':
        lastOne = List<int>.filled(_currentSquareColumns, 0);
        if (position['x'] - 1 >= 0 && position['x'] + 1 < _rows)
        for(int column = 0; column < _currentSquareColumns; column++) {
          if (_gridList[position['x'] + _currentSquareRows - 1][position['y'] + column] == 1) {
            lastOne[column] = 1;
          }
        }
        break;
    }
    return lastOne;
  }

  // 判断是否可移动
  bool _isCanMove (String direction, Map<String, int> position) {
    List<int> lastOne = _squareBottomEmpty(direction, position);
    List<bool> allCanMove = List<bool>.filled(lastOne.length, false);
    for(int column = 0; column < lastOne.length; column++) {
      switch (direction) {
        case 'down':
          allCanMove[column] = position['y'] + lastOne[column] + 2 > _columns ? false : _gridList[position['x']+column][position['y'] + lastOne[column] + 1] == 0;
          break;
        case 'left':
          int firstColumn = 0;
          if (lastOne[column] == 0) 
            for(int row = 0; row < _currentSquareColumns; row++) {
              if (position['x']+row < _rows) {
                if (_gridList[position['x']+row][position['y']+column] == 1) firstColumn = row;
              }
            }
          allCanMove[column] =  position['x'] > 0 && _gridList[position['x'] + firstColumn - 1][position['y'] + column] == 0;
          break;
        case 'right': 
          int firstColumn = 0;
          if (lastOne[column] == 0) {
            for(int row = 0; row < _currentSquareRows; row++) {
              if (_gridList[position['x'] + row][position['y']+column] == 1) firstColumn = row + 1;
            }
          } else if (lastOne[column] == 1) {
            firstColumn = _currentSquareRows;
          }
          allCanMove[column] =  position['x'] + firstColumn < _rows && _gridList[position['x'] + firstColumn][position['y'] + column] == 0;
      }
    }
    return allCanMove.every((result) => result == true);
  }

  // 清除上一次移动位置
  void _removePrePosition ({Map<String, int> position}) {
    Map<String, int> newPrePosition = {..._prePosition};
    if (null != position) newPrePosition = position;
    for (int row = 0; row < _currentSquareRows; row++) {
      for (int column = 0; column < _currentSquareColumns; column++) {
        if (_gridList[newPrePosition['x'] + row][newPrePosition['y'] + column] == 1) _gridList[newPrePosition['x'] + row][newPrePosition['y'] + column] = 0;
      }
    }
  }

  // 将已经落地的方块的值置为2
  void _hadDownFall (Map<String, int> position) {
    for(int row = 0; row < _currentSquare.length; row++) {
      for( int column = 0; column < _currentSquare[row].length; column++) {
        if (_gridList[position['x'] + row][position['y'] + column] == 1)
          _gridList[position['x'] + row][position['y'] + column] = 2;
      }
    }
  }

  // 重新渲染布局
  void _handleChangeGridList () {
    Map<String, int> currentPosition = {..._currentPosition};
    for(int row = 0; row < _currentSquareRows; row++) {
      for(int column = 0; column < _currentSquareColumns; column++) {
        if (_currentSquare[row][column] == 1) {
          _gridList[currentPosition['x']+row][currentPosition['y']+column] = _currentSquare[row][column];
        }
      }
    }
    changeGridSink.add(_gridList);
  }

  // 重新开始游戏
  void onRestart () {
    _initGridList(_rows, _columns);
    _audioPlayer.play(musicUrl['bgm']);
    _gameOver = false;
    _checkPoint = 1;
    _score = 0;
    _buildCurrentSquare();
    changeGridSink.add(_gridList);
    _handleChangeScore();
  }

  // 改变方向
  void _handleChangeDirection (String direction) {
    _prePosition = {..._currentPosition};
    switch (direction) {
      case 'up':
        _buildCurrentSquare(isTransform: true);
        outerGridSink.add(null);
        break;
      case 'down':
        if (_isCanMove(direction, _currentPosition)) {
          _currentPosition['y'] = _currentPosition['y'] + 1;
          _removePrePosition();
        } else {
          if (_gameOver) {
            timer.cancel();
            return;
          } else {
            _hadDownFall(_currentPosition);
            _checkFullRow();
            _buildCurrentSquare();
          }
        }
        break;
      case 'left':   
        if (_isCanMove(direction, _currentPosition)) {
          _currentPosition['x'] = _currentPosition['x'] - 1;
          _removePrePosition();
        }
        break;
      case 'right': 
        if (_isCanMove(direction, _currentPosition)) {
          _currentPosition['x'] = _currentPosition['x'] + 1;
          _removePrePosition();
        }
        break;
    }
    changeDirection.add(direction);
    outerGridSink.add(null);
  }

  void dispose() {
    _gridListController.close();
    _actionGridListController.close();
    _directionController.close();
    _actionDirectionController.close();
    checkPointController.close();
    _actionCheckPointController.close();
    _actionNextController.close();
    nextSquareController.close();
  }
}