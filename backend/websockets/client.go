package websockets

import (
	"encoding/json"
	"log"

	"chess/services"

	"github.com/gorilla/websocket"
)

type Client struct {
	Hub           *Hub
	Conn          *websocket.Conn
	Send          chan []byte
	PlayerID      string
	PlayerService *services.PlayerService
	GameService   *services.GameService
}

func (c *Client) ReadPump() {
	defer func() {
		if c.PlayerID != "" {
			player := c.PlayerService.GetPlayerByID(c.PlayerID)
			c.broadcastPlayerLeft(player)
			c.PlayerService.RemovePlayer(c.PlayerID)
		}
		c.Hub.Unregister <- c
		c.Conn.Close()
	}()

	// When connection established, register client to hub and send current players list
	c.Hub.Register <- c
	c.sendPlayerList()

	for {
		_, message, err := c.Conn.ReadMessage()
		if err != nil {
			log.Println("Read error:", err)
			break
		}
		var msg map[string]interface{}
		if err := json.Unmarshal(message, &msg); err != nil {
			log.Println("Unmarshal error:", err)
			continue
		}
		c.handleIncomingMessage(msg)
	}
}

func (c *Client) WritePump() {
	defer func() {
		c.Conn.Close()
	}()
	for {
		select {
		case message, ok := <-c.Send:
			if !ok {
				c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			if err := c.Conn.WriteMessage(websocket.TextMessage, message); err != nil {
				log.Println("Write error:", err)
				return
			}
		}
	}
}
