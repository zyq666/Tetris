import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:tetris/blocs/gamePanelBloc.dart';
import 'package:tetris/components/gamePanel.dart';

class DirectionBtn extends StatelessWidget {
  final IconData icon;
  final Function onClick;
  AudioPlayer _pressTipsPlayer = AudioPlayer();
  DirectionBtn({Key key, this.icon, this.onClick});

  Widget build (BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      onTap: () {
        _pressTipsPlayer.play(musicUrl['pressTip']);
        onClick();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: getRandomBackground(1)['color']
        ),
        child: Icon(icon, color: Colors.white, size: 45)
      )
    );
  }
}