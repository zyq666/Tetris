import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/blocs/blocBase.dart';
import 'package:tetris/blocs/gamePanelBloc.dart';
import 'package:tetris/components/grid.dart';

List<Map<String, dynamic>> _backgroundMap = [
  {'color': Color(0xFF4febb2), 'image': AssetImage('assets/imgs/fd1.png')},
  {'color': Color(0xFF3dc0f5), 'image': AssetImage('assets/imgs/fd2.png')},
  {'color': Color(0xFFff745d), 'image': AssetImage('assets/imgs/fd3.png')},
  {'color': Color(0xFFf6c854), 'image': AssetImage('assets/imgs/fd4.png')},
  {'color': Color(0xFF849cff), 'image': AssetImage('assets/imgs/fd5.png')},
  {'color': Color(0xFFffb32d), 'image': AssetImage('assets/imgs/fd6.png')},
];

Map<String, dynamic> _bottomRandomMap = _backgroundMap[Random().nextInt(_backgroundMap.length)];

Map<String, dynamic> getRandomBackground (value) {
  int randomValue = Random().nextInt(_backgroundMap.length);
  switch (value) {
    case 0: return {
      'color': Colors.black12,
    };
    case 1: 
      randomValue = randomValue > _backgroundMap.length ? 0 : randomValue++;
      return _backgroundMap[randomValue];
    case 2: return {
      'color': Color.fromRGBO(255, 255, 255, 0.5),
      'image': _bottomRandomMap['image']
    };
  }
}

class GamePanel extends StatelessWidget {
  String direction;
  GamePanel({Key key, this.direction});

  Widget build (BuildContext context) {
    final GamePanelBloc gamePanelBloc = BlocProvider.of<GamePanelBloc>(context);
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
      child: StreamBuilder<List<List<int>>>(
        stream: gamePanelBloc.gridListStream,
        initialData: [],
        builder: (BuildContext context, AsyncSnapshot<List<List<int>>> snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } 
          return Row(
            children: snapshot.data.asMap().keys.map((row) {
              return Expanded(
                child: Column(
                  children: snapshot.data[row].asMap().keys.map((column) => Expanded(child: Grid(hasImg: snapshot.data[row][column] != 0, value: snapshot.data[row][column], background: getRandomBackground(snapshot.data[row][column])))).toList(),
                )
              );
            }).toList()
          );
        }
      ),
    );
  }
}