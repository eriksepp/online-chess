import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/invitation_service.dart';
import '../services/websocket_service.dart';
import '../widgets/small_button.dart';
import '../constants/colors.dart';
import '../constants/ws_message_types.dart';

class InviteSentModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _cancelInvite(String inviteeId) {
      final invitationService = Provider.of<InvitationService>(context, listen: false);
      invitationService.hideInviteSentModal();

      final webSocketService = Provider.of<WebSocketService>(context, listen: false);
      final message =
          '{"type": "${WsMsgTypes.CANCEL_OUTGOING_INVITE}", "payload": {"inviteeId": "$inviteeId"}}';
      webSocketService.send(message);
    }

    return Consumer<InvitationService>(
      builder: (context, notifier, child) {
        if (!notifier.isShowingInviteSentModal) return SizedBox.shrink();

        return Positioned.fill(
          child: Material(
            color: overlayColor,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.fromLTRB(34, 28, 34, 23),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: modalBackground,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Waiting for reply\nfrom ${notifier.inviteeNickname}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: "CreteRound",
                      ),
                    ),
                    const SizedBox(height: 30),
                    SmallButton(
                      text: "Cancel",
                      bgColor: primaryRed,
                      onTap: () {
                        _cancelInvite(notifier.inviteeId);
                      },
                    ),
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
