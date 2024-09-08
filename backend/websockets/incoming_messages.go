package websockets

import (
	"log"
	"strconv"

	"chess/config"
)

// -------------- INCOMING MESSAGES --------------

func (c *Client) handleIncomingMessage(msg map[string]interface{}) {
	switch msg["type"] {
	case config.WsMsgTypes.SET_NICKNAME_REQUEST:
		c.handleSetNicknameRequest(msg)
	case config.WsMsgTypes.OUTGOING_INVITE_REQUEST:
		c.handleOutgoingInviteRequest(msg)
	case config.WsMsgTypes.CANCEL_OUTGOING_INVITE:
		c.handleCancelOutgoingInvite(msg)
	case config.WsMsgTypes.INCOMING_INVITE_REPLY:
		c.handleIncomingInviteReply(msg)
	case config.WsMsgTypes.JOIN_WAITROOM_REQUEST:
		c.handleJoinWaitRoomRequest()
	case config.WsMsgTypes.LEAVE_WAITROOM_REQUEST:
		c.handleLeaveWaitRoomRequest()
	case config.WsMsgTypes.MOVE_REQUEST:
		c.handleMoveRequest(msg)
	}
}

func (c *Client) handleSetNicknameRequest(msg map[string]interface{}) {
	payload, ok := msg["payload"].(map[string]interface{})
	if !ok {
		log.Println("Invalid payload")
		return
	}
	nickname, ok := payload["nickname"].(string)
	if !ok {
		log.Println("Invalid nickname")
		return
	}
	player := c.PlayerService.AddPlayer(nickname)
	c.PlayerID = player.ID
	c.Hub.AssignPlayerID(c, player.ID)

	c.sendNicknameReply(player, "success")
	c.broadcastNewPlayer(player)
}

func (c *Client) handleOutgoingInviteRequest(msg map[string]interface{}) {
	payload, ok := msg["payload"].(map[string]interface{})
	if !ok {
		log.Println("Invalid payload")
		return
	}
	inviteeId, ok := payload["inviteeId"].(string)
	if !ok {
		log.Println("Invalid invitee ID")
		return
	}

	c.changePlayerStatus(inviteeId, 1)
	c.changePlayerStatus(c.PlayerID, 1)

	// Send invite to invitee
	inviteeClient := c.Hub.FindClientByID(inviteeId)
	if inviteeClient == nil {
		log.Println("Unable to get invitee client from hub to send invite")
		return
	}

	inviteeClient.sendIncomingInvitationRequest(c.PlayerID)
}

func (c *Client) handleCancelOutgoingInvite(msg map[string]interface{}) {
	payload, ok := msg["payload"].(map[string]interface{})
	if !ok {
		log.Println("Invalid payload")
		return
	}
	inviteeId, ok := payload["inviteeId"].(string)
	if !ok {
		log.Println("Invalid invitee ID")
		return
	}

	c.changePlayerStatus(inviteeId, 0)
	c.changePlayerStatus(c.PlayerID, 0)

	// Send invite to invitee
	inviteeClient := c.Hub.FindClientByID(inviteeId)
	if inviteeClient == nil {
		log.Println("Unable to get invitee client from hub to send invite")
		return
	}

	inviteeClient.sendCancelIncomingInvitation()
}

func (c *Client) handleIncomingInviteReply(msg map[string]interface{}) {
	payload, ok := msg["payload"].(map[string]interface{})
	if !ok {
		log.Println("Invalid payload")
		return
	}
	inviterId, ok := payload["inviterId"].(string)
	if !ok {
		log.Println("Invalid inviter ID")
		return
	}
	agreesToPlayStr, ok := payload["agreesToPlay"].(string)
	if !ok {
		log.Println("Invalid agreesToPlay value")
		return
	}
	agreesToPlay, err := strconv.ParseBool(agreesToPlayStr)
	if err != nil {
		log.Println("Error converting agreesToPlay to bool:", err)
		return
	}

	var newStatus int
	if agreesToPlay {
		newStatus = 3
	} else {
		newStatus = 0
	}

	c.changePlayerStatus(inviterId, newStatus)
	c.changePlayerStatus(c.PlayerID, newStatus)

	// Send reply to inviter
	inviterClient := c.Hub.FindClientByID(inviterId)
	if inviterClient == nil {
		log.Println("Unable to get inviter client from hub to send incoming invitation reply")
		return
	}

	if newStatus == 0 {
		inviterClient.sendOutgoingInvitationDeclined()
	} else if newStatus == 3 {
		game := c.GameService.CreateGame(inviterId, c.PlayerID)
		inviterClient.sendStartGame(game)
		c.sendStartGame(game)
	}
}

func (c *Client) handleJoinWaitRoomRequest() {
	c.changePlayerStatus(c.PlayerID, 2)

	opponent := c.PlayerService.FindFirstOtherPlayerWithStatus(c.PlayerID, 2)
	if opponent == nil {
		return
	}

	opponentClient := c.Hub.FindClientByID(opponent.ID)
	if opponentClient == nil {
		log.Println("Unable to get opponent client from hub to send incoming invitation reply")
		return
	}

	c.changePlayerStatus(c.PlayerID, 3)
	c.changePlayerStatus(opponent.ID, 3)

	game := c.GameService.CreateGame(opponent.ID, c.PlayerID)
	opponentClient.sendStartGame(game)
	c.sendStartGame(game)
}

func (c *Client) handleLeaveWaitRoomRequest() {
	c.changePlayerStatus(c.PlayerID, 0)
}

func (c *Client) handleMoveRequest(msg map[string]interface{}) {
	payload, ok := msg["payload"].(map[string]interface{})
	if !ok {
		log.Println("Invalid payload")
		return
	}
	gameID, ok := payload["gameID"].(string)
	if !ok {
		log.Println("Invalid gameID")
		return
	}
	move, ok := payload["move"].(string)
	if !ok {
		log.Println("Invalid move string in payload")
		return
	}

	var opponentClient *Client
	err := c.GameService.HandleMoveRequest(gameID, move)
	if err != nil {
		c.sendMoveReply("error")
		return
	} else {
		c.sendMoveReply("success")
		opponentID := c.GameService.GetOpponentID(gameID, c.PlayerID)
		opponentClient = c.Hub.FindClientByID(opponentID)
		opponentClient.sendOpponentsMove(move)
	}

	outcome := c.GameService.CheckOutcome(gameID)
	if outcome == "*" {
		return
	}
	var message string
	if outcome == "1-0" {
		message = "Checkmate. White won!"
	} else if outcome == "0-1" {
		message = "Checkmate. Black won!"
	} else if outcome == "1/2-1/2" {
		message = "Stalemate"
	}

	c.sendGameOver(message)
	opponentClient.sendGameOver(message)

}

// -------------- HELPER FUNCTIONS  --------------
func (c *Client) changePlayerStatus(playerID string, status int) {
	c.PlayerService.SetPlayerState(playerID, status)
	c.broadcastPlayerStatusChange(playerID, status)
}
