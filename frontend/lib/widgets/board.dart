import 'package:chess/constants/colors.dart';
import 'package:chess/constants/game_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/game_service.dart';
import './board_tile.dart';

class Board extends StatelessWidget {
  final double boardSize;
  final String currentUserColor;

  const Board({
    required this.boardSize,
    required this.currentUserColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameService = Provider.of<GameService>(context);
    final tileSize = boardSize / 8;

    return Container(
      height: boardSize,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset.zero,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: 64,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          int row, column;

          if (currentUserColor == blackPlayer) { 
            row = 7 - (index ~/ 8); // Rotate indexing for black player to position black pieces on the bottom
            column = 7 - (index % 8);
          } else {
            row = index ~/ 8;
            column = index % 8;
          }
          bool isDarkTile = (row + column) % 2 == 1;

          String piece = gameService.getPieceAtPosition(row, column).trim();
          String tileCoordinate = gameService.getTileCoordinate(row, column);
          bool isHighlighted = gameService.isTileHighlighted(row, column);

          return BoardTile(
            coordinate: tileCoordinate,
            isDark: isDarkTile,
            isHighlighted: isHighlighted,
            tileSize: tileSize,
            piece: piece,
            handleTap: gameService.handleTap,
          );
        },
      ),
    );
  }
}
