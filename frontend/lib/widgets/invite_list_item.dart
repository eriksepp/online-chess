import 'package:flutter/material.dart';

import '../constants/colors.dart';
import './small_button.dart';

class InviteListItem extends StatelessWidget {
  final String username;
  final VoidCallback onTap;

  const InviteListItem({
    Key? key,
    required this.username,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: inviteLabelBg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    username,
                    style: const TextStyle(
                      color: darkBrown,
                      fontFamily: "CreteRound",
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 11),
                child: SmallButton(
                  text: "Invite",
                  bgColor: lightGreen,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ));
  }
}
