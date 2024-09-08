import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../services/players_service.dart';
import '../services/game_service.dart';
import '../widgets/base_bg.dart';
import '../widgets/board.dart';
import '../constants/colors.dart';

class GameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayersService>(context, listen: false);
    final gameService = Provider.of<GameService>(context);
    final messageToShow = gameService.messageToShow;
    final currentNickname = playerService.currentPlayerNickname;
    final opponentNickname = gameService.opponentNickname;
    final currentUserColor = gameService.currentUserColor;

    return BaseBackground(
      showBanner: false,
      showBackButton: false,
      child: Center(
          child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.185),
          Text(
            messageToShow,
            style: const TextStyle(
              color: darkBrown,
              fontFamily: 'CreteRound',
              fontSize: 15,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipPath(
                clipper: AngledEdgeClipper(),
                child: Container(
                  color: darkBrown,
                  height: MediaQuery.of(context).size.width * 1.16,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        opponentNickname,
                        style: const TextStyle(
                          color: dullBeige,
                          fontFamily: 'CreteRound',
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Board(
                      boardSize: MediaQuery.of(context).size.width * 0.90,
                      currentUserColor: currentUserColor,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currentNickname,
                        style: const TextStyle(
                          color: dullBeige,
                          fontFamily: 'CreteRound',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      )),
    );
  }
}

class AngledEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height); // Bottom left
    path.lineTo(size.width, size.height * 0.96); // Bottom right
    path.lineTo(size.width, 0.0); // Top right
    path.lineTo(0.0, 0.0 + size.height * 0.04); // Top left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
