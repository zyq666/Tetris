import 'package:flutter/material.dart';

class Grid extends StatelessWidget {
  final int value;
  final bool hasImg;
  final Map<String, dynamic> background;
  Grid ({Key key, this.hasImg = false, this.value = 0, this.background});

  Widget build (BuildContext context) {
    return Container(
      margin: EdgeInsets.all(2),
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: background['color'],
        image: 
          hasImg ? DecorationImage(
            image: background['image'],
          )
        : null,
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
      // child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
    );
  }
}