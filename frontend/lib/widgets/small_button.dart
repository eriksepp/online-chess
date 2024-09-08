import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SmallButton extends StatelessWidget {
  final String text;
  final Color bgColor;
  final VoidCallback onTap;

  const SmallButton({
    Key? key,
    required this.text,
    required this.bgColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: bgColor,
        width: 116,
        height: 33,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: lightText, // You can customize or make this a parameter if needed
              fontFamily: "Lato",
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}