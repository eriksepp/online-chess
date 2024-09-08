import 'package:chess/services/invitation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/players_service.dart';
import '../services/websocket_service.dart';
import '../widgets/base_bg.dart';
import '../widgets/invite_list_item.dart';
import '../widgets/invite_sent_modal.dart';
import '../widgets/invite_declined_modal.dart';
import '../constants/colors.dart';
import '../constants/ws_message_types.dart';

class InvitePlayerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayersService>(context);
    final invitationService = Provider.of<InvitationService>(context);
    final nickname = playerService.currentPlayerNickname;
    final availablePlayers = playerService.players
        .where((player) => player.state == 0)
        .toList();

    void _sendInvite(String inviteeId, String inviteeNickname) {
      final webSocketService =
          Provider.of<WebSocketService>(context, listen: false);
      final message =
          '{"type": "${WsMsgTypes.OUTGOING_INVITE_REQUEST}", "payload": {"inviteeId": "$inviteeId"}}';
      webSocketService.send(message);

      invitationService.inviteeId = inviteeId;
      invitationService.showInviteSentModal(inviteeNickname);
    }

    return BaseBackground(
        bannerText: 'INVITE A PLAYER',
        showBanner: true,
        showBackButton: true,
        child: Stack(
          children: [
            Center(
              child: availablePlayers.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),
                        FractionallySizedBox(
                            widthFactor: 0.8,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: availablePlayers
                                  .map((player) => InviteListItem(
                                        username: player.nickname,
                                        onTap: () {
                                          _sendInvite(
                                              player.id, player.nickname);
                                        },
                                      ))
                                  .toList(),
                            )),
                        const Spacer(flex: 6),
                      ],
                    )
                  : const Text('There are no players\navailable for invitation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "CreteRound",
                          fontSize: 18,
                          color: darkBrown)),
            ),

          if (invitationService.isShowingInviteSentModal)
            InviteSentModal(),
          
          if (invitationService.isShowingInviteDeclinedModal)
            InviteDeclinedModal(),
          ],
        ));
  }
}
