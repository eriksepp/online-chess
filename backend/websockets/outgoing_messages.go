package websockets

import (
	"encoding/json"
	"log"

	"chess/config"
	"chess/models"
)

// -------------- OUTGOING MESSAGES 1-1 --------------

func (c *Client) sendPlayerList() {
	players := c.PlayerService.GetPlayerList()
	message, err := composeMessage(config.WsMsgTypes.PLAYERS_LIST, players)
	if err != nil {
		log.Println("Error creating user list message:", err)
		return
	}
	c.Send <- message
}

func (c *Client) sendNicknameReply(playerData *models.Player, success string) {
	message, err := composeMessage(config.WsMsgTypes.SET_NICKNAME_REPLY, playerData, success)
	if err != nil {
		log.Println("Error creating nickname reply message:", err)
		return
	}
	c.Send <- message
}

func (c *Client) sendIncomingInvitationRequest(inviterID string) {
	message, err := composeMessage(config.WsMsgTypes.INCOMING_INVITE_REQUEST, inviterID)
	if err != nil {
		log.Println("Error creating incoming invitation request message:", err)
		return
	}
	c.Send <- message
}

func (c *Client) sendCancelIncomingInvitation() {
	message, err := composeMessage(config.WsMsgTypes.CANCEL_INCOMING_INVITE, nil)
	if err != nil {
		log.Println("Error creating cancel incoming invitation message:", err)
		return
	}
	c.Send <- message
}

func (c *Client) sendOutgoingInvitationDeclined() {
	message, err := composeMessage(config.WsMsgTypes.OUTGOING_INVITE_DECLINED, nil)
	if err != nil {
		log.Println("Error creating outgoing invitation declined message:", err)
		return
	}
	c.Send <- message
}

func (c *Client) sendStartGame(game *models.Game) {
	payload := c.composeStartGamePayload(game)
	message, err := composeMessage(config.WsMsgTypes.START_GAME, payload)
	if err != nil {
		log.Println("Error creating start game message:", err)
		return
	}
	c.Send <- message
}

func (c *Client) sendMoveReply(success string) {
	message, err := composeMessage(config.WsMsgTypes.MOVE_REPLY, nil, success)
	if err != nil {
		log.Println("Error creating move reply message:", err)
		return
	}
	c.Send <- message
}

func (c *Client) sendOpponentsMove(move string) {
	message, err := composeMessage(config.WsMsgTypes.OPPONENTS_MOVE, move)
	if err != nil {
		log.Println("Error creating opponent move message:", err)
		return
	}
	c.Send <- message
}

func (c *Client) sendGameOver(msg string) {
	message, err := composeMessage(config.WsMsgTypes.GAME_OVER, msg)
	if err != nil {
		log.Println("Error creating game over message:", err)
		return
	}
	c.Send <- message
}

// -------------- OUTGOING MESSAGES BROADCAST --------------

func (c *Client) broadcastNewPlayer(player *models.Player) {
	message, err := composeMessage(config.WsMsgTypes.NEW_PLAYER, player)
	if err != nil {
		log.Println("Error creating new player message:", err)
		return
	}

	c.Hub.Broadcast <- message
}

func (c *Client) broadcastPlayerLeft(player *models.Player) {
	message, err := composeMessage(config.WsMsgTypes.PLAYER_LEFT, player)
	if err != nil {
		log.Println("Error creating player left message:", err)
		return
	}

	c.Hub.Broadcast <- message
}

func (c *Client) broadcastPlayerStatusChange(playerID string, newStatus int) {
	payload := map[string]interface{}{
		"ID":     playerID,
		"status": newStatus,
	}

	message, err := composeMessage(config.WsMsgTypes.PLAYER_STATUS_CHANGE, payload)
	if err != nil {
		log.Println("Error creating player status change message:", err)
		return
	}

	c.Hub.Broadcast <- message
}

// -------------- HELPER FUNCTIONS  --------------
func composeMessage(msgType string, payload interface{}, status ...string) ([]byte, error) {
	type messageStruct struct {
		Type    string       `json:"type"`
		Payload *interface{} `json:"payload"`
		Status  *string      `json:"status,omitempty"`
	}

	var payloadField *interface{}
	if payload != nil {
		payloadField = &payload
	}

	var statusField *string
	if len(status) > 0 {
		statusField = &status[0]
	}

	message := messageStruct{
		Type:    msgType,
		Payload: payloadField,
		Status:  statusField,
	}

	// Serialize the message to JSON
	messageBytes, err := json.Marshal(message)
	if err != nil {
		log.Println("Error marshaling ws message: %v\n", err)
		return nil, err
	}

	return messageBytes, nil
}

func (c *Client) composeStartGamePayload(game *models.Game) map[string]interface{} {
	payload := map[string]interface{}{
		"gameID":          game.ID,
		"whitePlayerID":   game.WhitePlayerID,
		"whitePlayerName": c.PlayerService.GetNicknameByID(game.WhitePlayerID),
		"blackPlayerID":   game.BlackPlayerID,
		"blackPlayerName": c.PlayerService.GetNicknameByID(game.BlackPlayerID),
	}
	return payload
}
