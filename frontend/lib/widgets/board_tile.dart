import 'package:chess/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BoardTile extends StatelessWidget {
  final String coordinate;
  final bool isDark;
  final bool isHighlighted;
  final double tileSize;
  final String piece;
  final Function handleTap;

  const BoardTile(
      {required this.coordinate,
      required this.isDark,
      required this.isHighlighted,
      required this.tileSize,
      required this.piece,
      required this.handleTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

   Color tileColor;

   if (isDark) {
    tileColor = isHighlighted ? darkGreenHighlighted : darkGreen;
   } else {
    tileColor = isHighlighted? lightGreenHighlighted : lightGreen;
   }

    return GestureDetector(
        onTap: () {handleTap(coordinate, piece);},
        child: Container(
          decoration: BoxDecoration(
            color: tileColor,
          ),
          child: Center(
            child: piece.isNotEmpty
                ? SvgPicture.asset(
                    'assets/images/$piece.svg',
                    width: tileSize * 0.72,
                    height: tileSize * 0.72,
                    fit: BoxFit.contain,
                  )
                : null,
          ),
        ));
  }
}
