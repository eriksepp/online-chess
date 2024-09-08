import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'services/players_service.dart';
import 'services/websocket_service.dart';
import 'services/invitation_service.dart';
import 'services/game_service.dart';
import 'services/notification_service.dart';

import 'views/enter_name_view.dart';
import 'views/menu_view.dart';
import 'views/invite_player_view.dart';
import 'views/wait_room_view.dart';
import 'views/game_view.dart';

import 'widgets/invite_received_modal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(
            MultiProvider(
              providers: [
                Provider(create: (_) => WebSocketService()),
                ChangeNotifierProvider(
                  create: (context) => PlayersService(
                      Provider.of<WebSocketService>(context, listen: false)),
                ),
                ChangeNotifierProvider(
                  create: (context) => InvitationService(
                    Provider.of<WebSocketService>(context, listen: false),
                    Provider.of<PlayersService>(context, listen: false)),
                ),
                ChangeNotifierProvider(
                  create: (context) => GameService(
                    Provider.of<WebSocketService>(context, listen: false),
                    Provider.of<PlayersService>(context, listen: false),
                    NotificationService()),
                )
              ],
              child: MyApp(),
            ),
          ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final webSocketService = Provider.of<WebSocketService>(context);
    webSocketService.connect("ws://192.168.8.181:8080/main"); //TODO: What to do with IP for audit?

    return MaterialApp(
      title: 'Chess',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => EnterNameView());
          case '/menu':
            return NoTransitionPageRoute(builder: (_) => MenuView());
          case '/invitePlayer':
            return NoTransitionPageRoute(builder: (_) => InvitePlayerView());
          case '/waitRoom':
            return NoTransitionPageRoute(builder: (_) => WaitRoomView());
          case '/game':
            return NoTransitionPageRoute(builder: (_) => GameView());
          default:
            return MaterialPageRoute(builder: (_) => EnterNameView());
        }
      },
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            InviteReceivedModal()
          ]
        );
      }
    );
  }
}

class NoTransitionPageRoute<T> extends MaterialPageRoute<T> {
  NoTransitionPageRoute({required WidgetBuilder builder})
      : super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
