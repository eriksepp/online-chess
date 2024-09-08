import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/invitation_service.dart';
import '../widgets/small_button.dart';
import '../constants/colors.dart';

class InviteDeclinedModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Consumer<InvitationService>(
      builder: (context, notifier, child) {
        if (!notifier.isShowingInviteDeclinedModal) return SizedBox.shrink();

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
                      '${notifier.inviteeNickname} declined invite',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: "CreteRound",
                      ),
                    ),
                    SizedBox(height: 30),
                    SmallButton(
                      text: "Close",
                      bgColor: primaryRed,
                      onTap: () {
                        notifier.hideInviteDeclinedModal();
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
