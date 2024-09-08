import 'package:flutter/material.dart';
import './websocket_service.dart';
import '../constants/ws_message_types.dart';
import '../models/player.dart';

class PlayersService extends ChangeNotifier {
  final WebSocketService _webSocketService;
  String _currentPlayerId = "";
  String _currentPlayerNickname = "";
  List<PlayerModel> _players = [];

  PlayersService(this._webSocketService) {
    _webSocketService.onNicknameReplyReceived = _handleNicknameReply;
    _webSocketService.onPlayersListReceived = _handlePlayersList;
    _webSocketService.onNewPlayerReceived = _handleNewPlayer;
    _webSocketService.onPlayerLeftReceived = _handlePlayerLeft;
    _webSocketService.onPlayerStatusChangeReceived = _handlePlayerStatusChange;
  }

  // -------------- SERVICE FUNCTIONS --------------
  String get currentPlayerNickname => _currentPlayerNickname;
  String get currentPlayerId => _currentPlayerId;
  List<PlayerModel> get players => _players;

  bool isNicknameAvailable(String nickname) {
    return !_players.any((player) => player.nickname == nickname);
  }

  String getNicknameById(String playerId) {
    try {
      final player = _players.firstWhere((player) => player.id == playerId);
      return player.nickname;
    } catch (e) {
      return "";
    }
  }

  // ------------- SENDING WS MESSAGES -------------

  void _sendNicknameToServer(String nickname) {
    final message =
        '{"type": "${WsMsgTypes.SET_NICKNAME_REQUEST}", "payload": {"nickname": "$nickname"}}';
    _webSocketService.send(message);
  }

  // ------------ RECEIVING WS MESSAGES ------------

  // After receiving SetNicknameReply from server set current
  // user id and nickname and navigate to main menu
  void _handleNicknameReply(Map<String, dynamic> message) {
    final payload = message['payload'];
    _currentPlayerId = payload['ID'];
    _currentPlayerNickname = payload['Nickname'];
    notifyListeners();

    _navigateToMenu();
  }

  void _handlePlayersList(Map<String, dynamic> message) {
    final List<dynamic> playersJson = message['payload'];
    _players = playersJson
        .map((player) => PlayerModel.fromMap(player))
        .where((player) => player.id != _currentPlayerId)
        .toList();
    notifyListeners();
  }

  void _handleNewPlayer(Map<String, dynamic> message) {
    final newPlayerJson = message['payload'];
    final newPlayer = PlayerModel.fromMap(newPlayerJson);

    // Check if player doesn't exist in list yet
    final bool isNotCurrentPlayer = newPlayer.id != _currentPlayerId;
    final bool playerExists =
        _players.any((player) => player.id == newPlayer.id);

    if (isNotCurrentPlayer && !playerExists) {
      _players.add(newPlayer);
      notifyListeners();
    }
  }

  void _handlePlayerLeft(Map<String, dynamic> message) {
    final removePlayerJson = message['payload'];
    final playerIdToRemove = removePlayerJson['ID'];

    final bool playerExists =
        _players.any((player) => player.id == playerIdToRemove);

    if (playerExists) {
      _players.removeWhere((player) => player.id == playerIdToRemove);
      notifyListeners();
    }
  }

  void _handlePlayerStatusChange(Map<String, dynamic> message) {
    final playerStatusChangeJson = message['payload'];
    final playerId = playerStatusChangeJson['ID'];
    final newState = playerStatusChangeJson['status'];

    final playerIndex = _players.indexWhere((player) => player.id == playerId);

    if (playerIndex != -1) {
      _players[playerIndex] = PlayerModel(
        id: _players[playerIndex].id,
        nickname: _players[playerIndex].nickname,
        state: newState,
      );

      notifyListeners();
    }
  }

  // ----------------- NAVIGATION -----------------

  void _navigateToMenu() {
    if (_currentContext != null) {
      Navigator.pushNamed(_currentContext!, '/menu');
    }
  }

  // Provide the context for navigation
  BuildContext? _currentContext;
  void setContext(BuildContext context) {
    _currentContext = context;
  }
}
