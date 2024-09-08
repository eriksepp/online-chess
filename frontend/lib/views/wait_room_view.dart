import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../services/players_service.dart';
import '../services/websocket_service.dart';
import '../widgets/base_bg.dart';
import '../constants/colors.dart';
import '../constants/ws_message_types.dart';

class WaitRoomView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayersService>(context);
    final nickname = playerService.currentPlayerNickname;

    void _leaveWaitRoom() {
      final webSocketService =
          Provider.of<WebSocketService>(context, listen: false);
      const message =
          '{"type": "${WsMsgTypes.LEAVE_WAITROOM_REQUEST}"}';
      webSocketService.send(message);

      Navigator.pop(context);
    }

    return BaseBackground(
      bannerText: 'WAIT ROOM',
      showBanner: true,
      showBackButton: true,
      onBackButtonPressed: () {_leaveWaitRoom();},
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Looking for a player...',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "CreteRound", fontSize: 18, color: darkBrown)),
          ],
        ),
      ),
    );
  }
}
