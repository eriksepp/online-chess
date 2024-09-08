import 'package:flutter/material.dart';
import '../constants/colors.dart';

class BaseBackground extends StatelessWidget {
  final Widget child;
  final String bannerText;
  final bool showBanner;
  final bool showBackButton;
  final VoidCallback? onBackButtonPressed;

  BaseBackground({
    required this.child,
    this.bannerText = "",
    this.showBanner = false,
    this.showBackButton = false,
    this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Image.asset(
                'assets/images/top_pattern.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 130,
              ),
              Expanded(
                child: Container(
                  color: backgroundColor,
                ),
              ),
              Image.asset(
                'assets/images/bottom_pattern.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 100,
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAppBar(
              text: bannerText,
              showBanner: showBanner,
              showBackButton: showBackButton,
              onBackButtonPressed: onBackButtonPressed,
            ),
          ),
          Column(
            children: [
              Expanded(child: child),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final String text;
  final bool showBanner;
  final bool showBackButton;
  final VoidCallback? onBackButtonPressed;

  CustomAppBar({
    this.text = "", 
    this.showBanner = false, 
    this.showBackButton = false,
    this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 90.0),
      color: Colors.transparent,
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              iconSize: 30,
              color: darkBrown,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: onBackButtonPressed ?? () => Navigator.pop(context),
            ),
          if (showBanner)
            Expanded(
                child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 9.0),
                decoration: BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.circular(
                      5.0),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 19,
                    fontFamily: 'Lato',
                    color: lightText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
          if (showBackButton) SizedBox(width: 48),
        ],
      ),
    );
  }
}
