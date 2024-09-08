import 'package:flutter/material.dart';

import './websocket_service.dart';
import './players_service.dart';

class InvitationService extends ChangeNotifier {
  final WebSocketService _webSocketService;
  final PlayersService _playersService;
  bool _isShowingInviteReceivedModal = false;
  bool _isShowingInviteSentModal = false;
  bool _isShowingInviteDeclinedModal = false;
  String _inviterNickname = "";
  String _inviterId = "";
  String _inviteeNickname = "";
  String _inviteeId = "";

  InvitationService(this._webSocketService, this._playersService) {
    _webSocketService.hideAllModals = hideAllModals;
    _webSocketService.onIncomingInvitation = _handleIncomingInvitation;
    _webSocketService.onCancelIncomingInvite = hideInviteReceivedModal;
    _webSocketService.onOutgoingInvitationDeclined = _handleOutgoingInvitationDeclined;
  }

  bool get isShowingInviteReceivedModal => _isShowingInviteReceivedModal;
  bool get isShowingInviteSentModal => _isShowingInviteSentModal;
  bool get isShowingInviteDeclinedModal => _isShowingInviteDeclinedModal;
  String get inviterNickname => _inviterNickname;
  String get inviterId => _inviterId;
  String get inviteeNickname => _inviteeNickname;
  String get inviteeId => _inviteeId;

  set inviterId(String value) {
    _inviterId = value;
  }

  set inviteeId(String value) {
    _inviteeId = value;
  }

  void showInviteReceivedModal(String nickname) {
    _inviterNickname = nickname;
    _isShowingInviteReceivedModal = true;
    notifyListeners();
  }

  void hideInviteReceivedModal() {
    _inviterNickname = "";
    _inviterId = "";
    _isShowingInviteReceivedModal = false;
    notifyListeners();
  }

  void showInviteSentModal(String nickname) {
    _inviteeNickname = nickname;
    _isShowingInviteSentModal = true;
    notifyListeners();
  }

  void hideInviteSentModal() {
    _isShowingInviteSentModal = false;
    notifyListeners();
  }

  void showInviteDeclinedModal() {
    _isShowingInviteDeclinedModal = true;
    notifyListeners();
  }

  void hideInviteDeclinedModal() {
    _isShowingInviteDeclinedModal = false;
    notifyListeners();
  }

  void hideAllModals() {
    _isShowingInviteReceivedModal = false;
    _isShowingInviteSentModal = false;
    _isShowingInviteDeclinedModal = false;
    notifyListeners();
  }

  // ------------ RECEIVING WS MESSAGES ------------
  void _handleIncomingInvitation(String newInviterId) {
    final inviterNickname = _playersService.getNicknameById(newInviterId);
    inviterId = newInviterId;
    showInviteReceivedModal(inviterNickname);
  }

  void _handleOutgoingInvitationDeclined() {
    hideInviteSentModal();
    showInviteDeclinedModal();
  }
}