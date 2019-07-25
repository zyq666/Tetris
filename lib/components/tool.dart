import 'package:flutter/material.dart';
import 'package:tetris/blocs/blocBase.dart';
import 'package:tetris/blocs/gamePanelBloc.dart';
import 'package:tetris/components/directionBtn.dart';
import 'package:tetris/components/gamePanel.dart';
import 'package:tetris/components/grid.dart';

class Tool extends StatelessWidget {
  Tool({Key key});


  Widget build (BuildContext context) {
    final GamePanelBloc gamePanelBloc = BlocProvider.of<GamePanelBloc>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('下一个:', style: TextStyle(color: Colors.white),),
            StreamBuilder<List<List<int>>>(
              stream: gamePanelBloc.nextSquareController.stream,
              initialData: [],
              builder: (BuildContext context, AsyncSnapshot<List<List<int>>> snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } 
                return Container(
                  height: 150,
                  width: 150,
                  margin: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    // border: Border.all(width: 5, color: Color.fromRGBO(255, 255, 255, 0.1)),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    backgroundBlendMode: BlendMode.overlay,
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: snapshot.data.asMap().keys.map((row) {
                      return Expanded(
                        child: Column(
                          children: snapshot.data[row].asMap().keys.map((column) => Expanded(child: Grid(value: snapshot.data[row][column], background: {'color': getRandomBackground(snapshot.data[row][column])['color']}))).toList(),
                        )
                      );
                    }).toList()
                  )
                );
              }
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: 
          Column(
            children: <Widget>[
              DirectionBtn(icon: Icons.arrow_drop_up, onClick: () {
                gamePanelBloc.innerChangeDirection.add('up');
              }),
              SizedBox(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    DirectionBtn(icon: Icons.arrow_left, onClick: () {
                      gamePanelBloc.innerChangeDirection.add('left');
                    }),
                    DirectionBtn(icon: Icons.arrow_right, onClick: () {
                      gamePanelBloc.innerChangeDirection.add('right');
                    }),
                  ]
                )
              ),
              DirectionBtn(icon: Icons.arrow_drop_down, onClick: () {
                gamePanelBloc.innerChangeDirection.add('down');
              }),
            ],
          )
        )
      ],
    );
  }
}