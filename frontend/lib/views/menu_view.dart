import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../services/players_service.dart';
import '../services/game_service.dart';
import '../services/websocket_service.dart';
import '../widgets/base_bg.dart';
import '../constants/colors.dart';
import '../constants/ws_message_types.dart';

class MenuView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayersService>(context);
    final gameService = Provider.of<GameService>(context);
    gameService.setContext(context);

    final nickname = playerService.currentPlayerNickname;

    void _joinWaitRoom() {
      final webSocketService =
          Provider.of<WebSocketService>(context, listen: false);
      const message =
          '{"type": "${WsMsgTypes.JOIN_WAITROOM_REQUEST}"}';
      webSocketService.send(message);

      Navigator.pushNamed(context, '/waitRoom');
    }

    return BaseBackground(
      bannerText: 'MAIN MENU',
      showBanner: true,
      showBackButton: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 4),
            Text('Hello, $nickname',
                style: const TextStyle(
                    fontFamily: "CreteRound", fontSize: 18, color: darkBrown)),
            const SizedBox(
              height: 18,
            ),
            const Text('With whom would you like to play?',
                style: TextStyle(
                    fontFamily: "CreteRound", fontSize: 18, color: darkBrown)),
            const SizedBox(
              height: 70,
            ),
            FractionallySizedBox(
                widthFactor: 0.8,
                child: Column(children: [
                  GestureDetector(
                      onTap: () {Navigator.pushNamed(context, '/invitePlayer');},
                      child: Container(
                        color: darkBrown,
                        width: double.infinity,
                        height: 60,
                        child: const Center(
                            child: Text("Invite a player to a match",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: lightText,
                                  fontFamily: "CreteRound",
                                  fontSize: 20,
                                ))),
                      )),
                  const SizedBox(
              height: 20,
            ),
                  GestureDetector(
                      onTap: () {_joinWaitRoom();},
                      child: Container(
                        color: darkBrown,
                        width: double.infinity,
                        height: 60,
                        child: const Center(
                            child: Text("Play with random player",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: lightText,
                                  fontFamily: "CreteRound",
                                  fontSize: 20,
                                ))),
                      ))
                ])),
            const Spacer(flex: 6),
          ],
        ),
      ),
    );
  }
}
