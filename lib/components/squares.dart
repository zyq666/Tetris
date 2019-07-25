import 'dart:math';

import 'package:flutter/material.dart';

class Squares {

  Squares({Key key});

  // 生成的方块类型
  static int _currentShapeType;
  static int _currentShapeIndex;
  static int _nextShapeType;
  static int _nextShapeIndex;

  // 生成俄罗斯方块
  static List<List<int>> _initSquare (int rows, int columns, {List<Map<String, int>> blank}) {
    List<List<int>> squares = List<List<int>>.generate(rows, (_) => List<int>.filled(columns, 1));
    if (blank != null) blank.forEach((point) {
      squares[point['x']][point['y']] = 0;
    });
    return squares;
  }

  // 随机生成方块
  static List<List<int>> randomGenrate ({bool current}) {
    if (current) _currentShapeType = _currentShapeType == null ? Random().nextInt(_shapes.length) : _nextShapeType;
    if (!current) _nextShapeType = Random().nextInt(_shapes.length);
    if (current) _currentShapeIndex = _currentShapeIndex == null ? Random().nextInt(_shapes[_currentShapeType].length) : _nextShapeIndex;
    if (!current) _nextShapeIndex = Random().nextInt(_shapes[_nextShapeType].length);
    return  !current ? [..._shapes[_nextShapeType][_nextShapeIndex]] : [..._shapes[_currentShapeType][_currentShapeIndex]] ;
  }

  // 切换同类型方块
  static List<List<int>> randomSameShape () {
    if (_shapes[_currentShapeType].length > 0) 
      _currentShapeIndex = _currentShapeIndex + 1 >= _shapes[_currentShapeType].length ? 0 : _currentShapeIndex + 1;
    return [..._shapes[_currentShapeType][_currentShapeIndex]];
  }

  // L型方块
  static List<List<List<int>>> _shapeL = [
    _initSquare(2, 3,
      blank: [
        {'x': 1, 'y': 1},
        {'x': 1, 'y': 2 }
      ]
    ),
    _initSquare(3, 2,
      blank: [
        {'x': 1, 'y': 0},
        {'x': 2, 'y': 0 }
      ]
    ),
    _initSquare(2, 3,
      blank: [
        {'x': 0, 'y': 0},
        {'x': 0, 'y': 1 }
      ]
    ),
    _initSquare(3, 2,
      blank: [
        {'x': 0, 'y': 1},
        {'x': 1, 'y': 1 }
      ]
    )
  ];

  // L型翻转方块
  static List<List<List<int>>> _shapeLR = [
    _initSquare(2, 3,
      blank: [
        {'x': 1, 'y': 0},
        {'x': 1, 'y': 1}
      ]
    ),
    _initSquare(3, 2,
      blank: [
        {'x': 0, 'y': 0},
        {'x': 1, 'y': 0}
      ]
    ),
    _initSquare(2, 3,
      blank: [
        {'x': 0, 'y': 1},
        {'x': 0, 'y': 2}
      ]
    ),
    _initSquare(3, 2,
      blank: [
        {'x': 1, 'y': 1},
        {'x': 2, 'y': 1}
      ]
    )
  ];

  // Z型方块
  static List<List<List<int>>> _shapeZ = [
    _initSquare(2, 3,
      blank: [
        {'x': 0, 'y': 2},
        {'x': 1, 'y': 0}
      ]
    ),
    _initSquare(3, 2,
      blank: [
        {'x': 0, 'y': 0},
        {'x': 2, 'y': 1}
      ]
    ),
  ];

  // Z型翻转方块
  static List<List<List<int>>> _shapeZR = [
    _initSquare(2, 3,
      blank: [
        {'x': 0, 'y': 0},
        {'x': 1, 'y': 2}
      ]
    ),
    _initSquare(3, 2,
      blank: [
        {'x': 2, 'y': 0},
        {'x': 0, 'y': 1}
      ]
    )
  ];

  // I型方块
  static List<List<List<int>>> _shapeI = [
    _initSquare(1, 4),
    _initSquare(4, 1)
  ];

  // O型方块
  static List<List<List<int>>> _shapeO = [
    _initSquare(2, 2)
  ];

  // T型方块
  static List<List<List<int>>> _shapeT = [
    _initSquare(2, 3,
      blank: [
        {'x': 0, 'y': 0},
        {'x': 0, 'y': 2}
      ]
    ),
    _initSquare(3, 2,
      blank: [
        {'x': 0, 'y': 1},
        {'x': 2, 'y': 1}
      ]
    ),
    _initSquare(2, 3,
      blank: [
        {'x': 1, 'y': 0},
        {'x': 1, 'y': 2}
      ]
    ),
    _initSquare(3, 2,
      blank: [
        {'x': 0, 'y': 0},
        {'x': 2, 'y': 0}
      ]
    )
  ];

  static List<List<List<List<int>>>> _shapes = [
    _shapeL,
    _shapeLR,
    _shapeZ,
    _shapeZR,
    _shapeI,
    _shapeO,
    _shapeT,
  ];
}