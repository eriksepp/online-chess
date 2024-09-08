import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/invitation_service.dart';
import '../services/websocket_service.dart';
import '../widgets/small_button.dart';
import '../constants/colors.dart';
import '../constants/ws_message_types.dart';

class InviteReceivedModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _sendDecision(String inviterId, bool agreesToPlay) {
      if (!agreesToPlay) {
        final invitationService =
            Provider.of<InvitationService>(context, listen: false);
        invitationService.hideInviteReceivedModal();
      }

      final webSocketService =
          Provider.of<WebSocketService>(context, listen: false);
      final message =
          '{"type": "${WsMsgTypes.INCOMING_INVITE_REPLY}", "payload": {"inviterId": "$inviterId", "agreesToPlay": "$agreesToPlay"}}';
      webSocketService.send(message);
    }

    return Consumer<InvitationService>(
      builder: (context, notifier, child) {
        if (!notifier.isShowingInviteReceivedModal) return SizedBox.shrink();

        return Positioned.fill(
          child: Material(
            color: overlayColor,
            child: Center(
              child: Container(
                padding: EdgeInsets.fromLTRB(34, 28, 34, 23),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: modalBackground,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${notifier.inviterNickname} is inviting\nyou to play',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: "CreteRound",
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      SmallButton(
                        text: "Decline",
                        bgColor: primaryRed,
                        onTap: () {
                          _sendDecision(notifier.inviterId, false);
                        },
                      ),
                      SizedBox(width: 24),
                      SmallButton(
                        text: "Accept",
                        bgColor: lightGreen,
                        onTap: () {
                          _sendDecision(notifier.inviterId, true);
                        },
                      )
                    ])
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
