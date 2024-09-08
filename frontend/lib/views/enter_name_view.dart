import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../services/players_service.dart';
import '../services/websocket_service.dart';
import '../widgets/base_bg.dart';
import '../constants/colors.dart';
import '../constants/ws_message_types.dart';

class EnterNameView extends StatefulWidget {
  @override
  _EnterNameViewState createState() => _EnterNameViewState();
}

class _EnterNameViewState extends State<EnterNameView> {
  final TextEditingController _controller = TextEditingController();
  late PlayersService playersService; 
  bool _isNicknameAvailable = true;
  bool _showErrorMessage = false;

  @override
  void initState() {
    super.initState();
    playersService = Provider.of<PlayersService>(context, listen: false); 
    playersService.setContext(context);
    _controller.addListener(_checkNicknameAvailability);
  }

  void _checkNicknameAvailability() {
    final nickname = _controller.text.trim();
    final isNicknameNotEmpty = nickname.isNotEmpty;

    final isNicknameAvailable = isNicknameNotEmpty && playersService.isNicknameAvailable(nickname);

    final shouldShowErrorMessage = isNicknameNotEmpty && !isNicknameAvailable;

    setState(() {
      _isNicknameAvailable = isNicknameAvailable;
      _showErrorMessage = shouldShowErrorMessage;
    });
  }

  void _submitNickname() {
    final nickname = _controller.text.trim();
    final webSocketService = Provider.of<WebSocketService>(context, listen: false);
    final message = '{"type": "${WsMsgTypes.SET_NICKNAME_REQUEST}", "payload": {"nickname": "$nickname"}}';
    webSocketService.send(message);
  }

  @override
  void dispose() {
    _controller.removeListener(_checkNicknameAvailability);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseBackground(
      bannerText: 'CHESS',
      showBanner: true,
      showBackButton: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 4),
            const Text('Enter nickname to start playing',
                style: TextStyle(
                    fontFamily: "CreteRound", fontSize: 18, color: darkBrown)),
            const SizedBox(
              height: 45,
            ),
            Text((_showErrorMessage == true) ? 'This nickname is taken' : ' ',
                style: TextStyle(
                    fontFamily: "CreteRound", fontSize: 18, color: primaryRed)),
            const SizedBox(
              height: 15,
            ),
            FractionallySizedBox(
                widthFactor: 0.8,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        cursorColor: Colors.black,
                        enableInteractiveSelection: false,
                        maxLength: 8,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: "Lato",
                          fontSize: 20,
                          height: 1,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: inputBackground,
                          counterText: '',
                          errorText: null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios_rounded),
                      iconSize: 40,
                      color: _isNicknameAvailable ? darkBrown : dullBeige,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: _isNicknameAvailable ? _submitNickname : () {},
                    ),
                  ],
                )),
            const Spacer(flex: 6),
          ],
        ),
      ),
    );
  }
}
