import 'dart:math';

import 'package:flutter/material.dart';
import './websocket_service.dart';
import './players_service.dart';
import './notification_service.dart';
import '../constants/game_constants.dart';
import '../constants/ws_message_types.dart';

class GameService extends ChangeNotifier {
  final WebSocketService _webSocketService;
  final PlayersService _playersService;
  final NotificationService _notificationService;

  String _gameId = "";

  String _currentUserColor = "";
  bool _currentUserTurn = false;
  String _selectedPieceName = ""; // In format eg. "Bb" - Bishop black, "Pw" - Pawn white
  String _selectedPieceStartCoord = "";
  String _selectedPieceEndCoord = "";
  bool _isCapture = false;
  String _sentNotation = "";

  String _opponentNickname = "";

  String _messageToShow = "";

  final List<List<String>> _piecesPositions = [
    // Piece's first letter marks the piece (R for rook, N for knight etc)
    // Piece's second letter marks the color (b for black, w for white)
    ["Rb", "Nb", "Bb", "Qb", "Kb", "Bb", "Nb", "Rb"],
    ["Pb", "Pb", "Pb", "Pb", "Pb", "Pb", "Pb", "Pb"],
    ["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  "],
    ["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  "],
    ["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  "],
    ["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  "],
    ["Pw", "Pw", "Pw", "Pw", "Pw", "Pw", "Pw", "Pw"],
    ["Rw", "Nw", "Bw", "Qw", "Kw", "Bw", "Nw", "Rw"],
  ];
  final List<List<String>> _highlightedTiles = [
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
  ];
  final List<List<String>> _tileCoordinates = [
    ["a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8"],
    ["a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7"],
    ["a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6"],
    ["a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5"],
    ["a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4"],
    ["a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3"],
    ["a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2"],
    ["a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1"],
  ];

  GameService(this._webSocketService, this._playersService, this._notificationService) {
    _webSocketService.onStartGame = _handleStartGame;
    _webSocketService.onMoveReply = _handleMoveReply;
    _webSocketService.onOpponentsMove = _handleOpponentsMove;
    _webSocketService.onGameOver = _handleGameOver;

    _notificationService.init();
  }

  String get messageToShow => _messageToShow;
  String get opponentNickname => _opponentNickname;
  String get currentUserColor => _currentUserColor;
  bool get currentUserTurn => _currentUserTurn;

  set opponentNickname(String name) {
    _opponentNickname = name;
  }

  // ---------------- FOR CREATING BOARD -----------------

  String getPieceAtPosition(int row, int column) {
    return _piecesPositions[row][column];
  }

  String getTileCoordinate(int row, int column) {
    return _tileCoordinates[row][column];
  }

  bool isTileHighlighted(int row, int column) {
    if (_highlightedTiles[row][column] == "x") {
      return true;
    }
    return false;
  }

  // ----------------- WS MESSAGES ------------------

  void _handleStartGame(Map<String, dynamic> message) {
    final payload = message['payload'];
    _gameId = payload['gameID'];

    final currentPlayerId = _playersService.currentPlayerId;
    if (currentPlayerId == payload['whitePlayerID']) {
      _currentUserColor = whitePlayer;
      _opponentNickname = payload['blackPlayerName'];
      _messageToShow = "You start";
      _currentUserTurn = true;
    } else if (currentPlayerId == payload['blackPlayerID']) {
      _currentUserColor = blackPlayer;
      _opponentNickname = payload['whitePlayerName'];
      _messageToShow = "Opponent starts";
    }
    notifyListeners();

    _navigateToGame();
  }

  void _sendMoveRequest() {
    final notation = _createMoveNotation();
    _sentNotation = notation;
    final message =
        '{"type": "${WsMsgTypes.MOVE_REQUEST}", "payload": {"gameID": "$_gameId", "move": "$notation"}}';
    _webSocketService.send(message);
  }

  void _handleMoveReply(Map<String, dynamic> message) {
    final status = message['status'];
    if (status == "error") {
      _deselectPiece();
      _removeAllHighlights();
      _messageToShow = "Invalid move, try again";
    } else if (status == "success") {
      
      if (_sentNotation == "O-O") {
        _handleKingsideCastling();
      } else if (_sentNotation == "O-O-O") {
        _handleQueensideCastling();
      } else {
        _highlightTile(_selectedPieceEndCoord);
        _movePiece(_selectedPieceStartCoord, _selectedPieceEndCoord);
      }

      _deselectPiece();
      _messageToShow = "Opponents turn";
      _currentUserTurn = false;
    }
    notifyListeners();
  }

  void _handleOpponentsMove(Map<String, dynamic> message) {
    String startCoord;
    String endCoord;

    _removeAllHighlights();
    final notation = message['payload'];
    if (notation == "O-O") {
      _handleKingsideCastling();
    } else if (notation == "O-O-O") {
      _handleQueensideCastling();
    } else {
      (startCoord, endCoord) = _getCoordsFromNotation(notation);
      _highlightTile(startCoord);
      _highlightTile(endCoord);
      _movePiece(startCoord, endCoord);
    }
    
    _messageToShow = "Your turn";
    _currentUserTurn = true;

    _notificationService.showNotification(
      "Your turn",
      "Opponent has made their move"
    );

    notifyListeners();
  }

  void _handleGameOver(Map<String, dynamic> message) {
    final messageToShow = message['payload'];
    _messageToShow = messageToShow;
    _currentUserTurn = false;
    notifyListeners();
  }

  // ------------------- MOVES --------------------

  void handleTap(String coordinate, String piece) {
    if (!_currentUserTurn) return;
    
    if (_selectedPieceStartCoord.isNotEmpty) {
      if (piece.isNotEmpty && !_isOpponentsPiece(piece)) { // If second tap is on own piece
        if(coordinate == _selectedPieceStartCoord) return; // If taps on same piece twice do nothing
        _handleSelectPiece(coordinate, piece);
      } else {
        if (_isOpponentsPiece(piece)) _isCapture = true;
        _selectedPieceEndCoord = coordinate;
        _sendMoveRequest();
      }

    } else {
      if (piece.isEmpty) return;
      if (_isOpponentsPiece(piece)) return;
       _handleSelectPiece(coordinate, piece);
    }

    notifyListeners();
  }

  void _movePiece(String startCoord, String endCoord) {
    int startRow;
    int startColumn;
    int endRow;
    int endColumn;

    // Convert coords to row and column
    (startRow, startColumn) = _getRowAndColumnFromCoord(startCoord);
    (endRow, endColumn) = _getRowAndColumnFromCoord(endCoord);

    // Get piece
    String piece = _piecesPositions[startRow][startColumn];

    // Move piece in array
    _piecesPositions[startRow][startColumn] = "  ";
    _piecesPositions[endRow][endColumn] = piece;
  }

  void _handleKingsideCastling() {
    bool castleWhiteSide = false;
    if (currentUserTurn && currentUserColor == whitePlayer) castleWhiteSide = true;
    if (currentUserTurn && currentUserColor == blackPlayer) castleWhiteSide = false;
    if (!currentUserTurn && currentUserColor == whitePlayer) castleWhiteSide = false;
    if (!currentUserTurn && currentUserColor == blackPlayer) castleWhiteSide = true;

    if (castleWhiteSide) {
      _highlightTile("e1");
      _highlightTile("g1");
      _highlightTile("h1");
      _highlightTile("f1");
      _movePiece("e1", "g1");
      _movePiece("h1", "f1");
    } else {
      _highlightTile("e8");
      _highlightTile("g8");
      _highlightTile("h8");
      _highlightTile("f8");
      _movePiece("e8", "g8");
      _movePiece("h8", "f8");
    }
  }

  void _handleQueensideCastling() {
    bool castleWhiteSide = false;
    if (currentUserTurn && currentUserColor == whitePlayer) castleWhiteSide = true;
    if (currentUserTurn && currentUserColor == blackPlayer) castleWhiteSide = false;
    if (!currentUserTurn && currentUserColor == whitePlayer) castleWhiteSide = false;
    if (!currentUserTurn && currentUserColor == blackPlayer) castleWhiteSide = true;

    if (castleWhiteSide) {
      _highlightTile("e1");
      _highlightTile("c1");
      _highlightTile("a1");
      _highlightTile("d1");
      _movePiece("e1", "c1");
      _movePiece("a1", "d1");
    } else {
      _highlightTile("e8");
      _highlightTile("c8");
      _highlightTile("a8");
      _highlightTile("d8");
      _movePiece("e8", "c8");
      _movePiece("a8", "d8");
    }
  }

  // ---------------- HELPER FUNCS ----------------

  void _highlightTile(String coordinate) {
    int row;
    int column;
    (row, column) = _getRowAndColumnFromCoord(coordinate);
    _highlightedTiles[row][column] = "x";
  }

  void _handleSelectPiece(String coordinate, String piece) {
    _removeAllHighlights();
    _highlightTile(coordinate);
    _selectedPieceName = piece;
    _selectedPieceStartCoord = coordinate;
  }

  void _removeAllHighlights() {
    for (var i = 0; i < 8; i++) {
      for (var j = 0; j < 8; j++) {
        _highlightedTiles[i][j] = "";
      }
    }
  }

  void _deselectPiece() {
    _selectedPieceName = "";
    _selectedPieceStartCoord = "";
    _selectedPieceEndCoord = "";
    _isCapture = false;
    _sentNotation = "";
  }

  String _createMoveNotation() {
    String pieceType = _selectedPieceName.substring(0, 1);
    if (pieceType == "P") pieceType = ""; // No piece name for pawn

    if (pieceType == "K" && _isKingsideCastlingAttempt()) return "O-O";
    if (pieceType == "K" && _isQueensideCastlingAttempt()) return "O-O-O";

    String captureMark = _isCapture ? "x" : "";

    return "$pieceType$_selectedPieceStartCoord$captureMark$_selectedPieceEndCoord";
  }

  bool _isOpponentsPiece(String piece) {
    if (piece.isEmpty) return false;
    String pieceColor = piece.substring(1);
    if (pieceColor == "b" && _currentUserColor == whitePlayer) return true;
    if (pieceColor == "w" && _currentUserColor == blackPlayer) return true;
    return false;
  }

  bool _isKingsideCastlingAttempt() {
    if (_currentUserColor == whitePlayer && _selectedPieceEndCoord == "g1") return true;
    if (_currentUserColor == blackPlayer && _selectedPieceEndCoord == "g8") return true;
    return false;
  }

  bool _isQueensideCastlingAttempt() {
    if (_currentUserColor == whitePlayer && _selectedPieceEndCoord == "c1") return true;
    if (_currentUserColor == blackPlayer && _selectedPieceEndCoord == "c8") return true;
    return false;
  }
 
  (int, int) _getRowAndColumnFromCoord(String coordinate) {
    for (var i = 0; i < 8; i++) {
      for (var j = 0; j < 8; j++) {
        if (_tileCoordinates[i][j] == coordinate) {
          return (i, j);
        }
      }
    }
    throw RangeError("Invalid coordinate: $coordinate");
  }

  (String, String) _getCoordsFromNotation(String notation) {
    notation = notation.replaceAll("x", ""); // Remove capture mark if there is one
    if (notation.length == 5) { // In case move is not for pawn
      notation = notation.substring(1);
    }
    String startCoord = notation.substring(0, 2);
    String endCoord = notation.substring(2);
    return (startCoord, endCoord);
  }

  // ----------------- NAVIGATION -----------------

  void _navigateToGame() {
    if (_currentContext != null) {
      Navigator.pushNamed(_currentContext!, '/game');
    }
  }

  // Provide the context for navigation
  BuildContext? _currentContext;
  void setContext(BuildContext context) {
    _currentContext = context;
  }
}
