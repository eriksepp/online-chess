class WsMsgTypes {
  static const String PLAYERS_LIST = "playersList"; // server->client
  static const String NEW_PLAYER = "newPlayer"; // server->client

  static const String PLAYER_LEFT = "playerLeft"; // server->client
  static const String PLAYER_STATUS_CHANGE = "playerStatusChange"; // server->client

  static const String SET_NICKNAME_REQUEST = "setNicknameRequest"; // client->server
  static const String SET_NICKNAME_REPLY = "setNicknameReply"; // server->client

  static const String OUTGOING_INVITE_REQUEST = "outgoingInviteRequest"; // client->server
	static const String OUTGOING_INVITE_DECLINED = "outgoingInviteDeclined"; // server->client
	static const String CANCEL_OUTGOING_INVITE = "cancelOutgoingInvite"; // client->server

	static const String INCOMING_INVITE_REQUEST = "incomingInviteRequest"; // server->client
	static const String INCOMING_INVITE_REPLY = "incomingInviteReply"; // client->server
	static const String CANCEL_INCOMING_INVITE = "cancelIncomingInvite"; // server->client

  static const String JOIN_WAITROOM_REQUEST = "joinWaitRoomRequest"; // client->server
  static const String LEAVE_WAITROOM_REQUEST = "leaveWaitRoomRequest"; // client->server

  static const String START_GAME = "startGame"; // server -> client
  static const String MOVE_REQUEST = "moveRequest"; // client -> server
  static const String MOVE_REPLY  = "moveReply"; // server -> client
  static const String OPPONENTS_MOVE = "opponentsMove"; // server -> client
  static const String GAME_OVER = "gameOver"; // server -> client
}
