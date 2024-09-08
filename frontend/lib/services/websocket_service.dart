import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/ws_message_types.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? onNicknameReplyReceived;
  Function(Map<String, dynamic>)? onPlayersListReceived;
  Function(Map<String, dynamic>)? onNewPlayerReceived;
  Function(Map<String, dynamic>)? onPlayerLeftReceived;
  Function(Map<String, dynamic>)? onPlayerStatusChangeReceived;
  Function(String)? onIncomingInvitation;
  Function()? onCancelIncomingInvite;
  Function()? onOutgoingInvitationDeclined;
  Function(Map<String, dynamic>)? onStartGame;
  Function()? hideAllModals;
  Function(Map<String, dynamic>)? onMoveReply;
  Function(Map<String, dynamic>)? onOpponentsMove;
  Function(Map<String, dynamic>)? onGameOver;

  void connect(String url) {
    _channel = IOWebSocketChannel.connect(url);

    _channel!.stream.listen((message) {
      print("Received: $message");
      final decodedMessage = jsonDecode(message);
      _handleIncomingMessage(decodedMessage);
    }, onError: (error) {
      print("WebSocket Error: $error");
    }, onDone: () {
      print("WebSocket closed");
    });
  }

  void _handleIncomingMessage(Map<String, dynamic> message) {
    if (message['type'] == WsMsgTypes.SET_NICKNAME_REPLY) {
      if (onNicknameReplyReceived != null) {
        onNicknameReplyReceived!(message);
      }
    } else if (message['type'] == WsMsgTypes.PLAYERS_LIST) {
      if (onPlayersListReceived != null) {
        onPlayersListReceived!(message);
      }
    } else if (message['type'] == WsMsgTypes.NEW_PLAYER) {
      if (onNewPlayerReceived != null) {
        onNewPlayerReceived!(message);
      }
    } else if (message['type'] == WsMsgTypes.PLAYER_LEFT) {
      if (onPlayerLeftReceived != null) {
        onPlayerLeftReceived!(message);
      }
    } else if (message['type'] == WsMsgTypes.PLAYER_STATUS_CHANGE) {
      if (onPlayerStatusChangeReceived != null) {
        onPlayerStatusChangeReceived!(message);
      }
    } else if (message['type'] == WsMsgTypes.INCOMING_INVITE_REQUEST) {
      final inviterId = message['payload'] as String;
      if (onIncomingInvitation != null) {
        onIncomingInvitation!(inviterId);
      }
    } else if (message['type'] == WsMsgTypes.CANCEL_INCOMING_INVITE) {
      if (onCancelIncomingInvite != null) {
        onCancelIncomingInvite!();
      }
    } else if (message['type'] == WsMsgTypes.OUTGOING_INVITE_DECLINED) {
      if (onOutgoingInvitationDeclined != null) {
        onOutgoingInvitationDeclined!();
      }
    } else if (message['type'] == WsMsgTypes.START_GAME) {
      if (hideAllModals != null) {
        hideAllModals!();
      }
      if (onStartGame != null) {
        onStartGame!(message);
      }
    } else if (message['type'] == WsMsgTypes.MOVE_REPLY) {
      if (onMoveReply != null) {
        onMoveReply!(message);
      }
    } else if (message['type'] == WsMsgTypes.OPPONENTS_MOVE) {
      if (onOpponentsMove != null) {
        onOpponentsMove!(message);
      }
    } else if (message['type'] == WsMsgTypes.GAME_OVER) {
      if (onGameOver != null) {
        onGameOver!(message);
      }
    }
  }

  void send(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}