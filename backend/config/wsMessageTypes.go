package config

type wsMsgTypes struct {
	PLAYERS_LIST             string
	NEW_PLAYER               string
	PLAYER_LEFT              string
	PLAYER_STATUS_CHANGE     string
	SET_NICKNAME_REQUEST     string
	SET_NICKNAME_REPLY       string
	OUTGOING_INVITE_REQUEST  string
	OUTGOING_INVITE_DECLINED string
	CANCEL_OUTGOING_INVITE   string
	INCOMING_INVITE_REQUEST  string
	INCOMING_INVITE_REPLY    string
	CANCEL_INCOMING_INVITE   string
	JOIN_WAITROOM_REQUEST    string
	LEAVE_WAITROOM_REQUEST   string
	START_GAME               string
	MOVE_REQUEST             string
	MOVE_REPLY               string
	OPPONENTS_MOVE           string
	GAME_OVER                string
}

var WsMsgTypes = wsMsgTypes{
	PLAYERS_LIST:             "playersList",
	NEW_PLAYER:               "newPlayer",
	PLAYER_LEFT:              "playerLeft",
	PLAYER_STATUS_CHANGE:     "playerStatusChange",
	SET_NICKNAME_REQUEST:     "setNicknameRequest",
	SET_NICKNAME_REPLY:       "setNicknameReply",
	OUTGOING_INVITE_REQUEST:  "outgoingInviteRequest",
	OUTGOING_INVITE_DECLINED: "outgoingInviteDeclined",
	CANCEL_OUTGOING_INVITE:   "cancelOutgoingInvite",
	INCOMING_INVITE_REQUEST:  "incomingInviteRequest",
	INCOMING_INVITE_REPLY:    "incomingInviteReply",
	CANCEL_INCOMING_INVITE:   "cancelIncomingInvite",
	JOIN_WAITROOM_REQUEST:    "joinWaitRoomRequest",
	LEAVE_WAITROOM_REQUEST:   "leaveWaitRoomRequest",
	START_GAME:               "startGame",
	MOVE_REQUEST:             "moveRequest",
	MOVE_REPLY:               "moveReply",
	OPPONENTS_MOVE:           "opponentsMove",
	GAME_OVER:                "gameOver",
}
