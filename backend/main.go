package main

import (
	"log"
	"net/http"

	"chess/services"
	"chess/websockets"

	"github.com/gorilla/websocket"
)

func main() {
	hub := websockets.NewHub()
	go hub.Run()

	playerService := services.NewPlayerService()
	gameService := services.NewGameService()

	http.HandleFunc("/main", func(w http.ResponseWriter, r *http.Request) {
		MainHandler(hub, w, r, playerService, gameService)
	})

	log.Println("Starting server on :8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe:", err)
	}
}

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func MainHandler(hub *websockets.Hub, w http.ResponseWriter, r *http.Request, playerService *services.PlayerService, gameService *services.GameService) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("Upgrade:", err)
		return
	}
	client := &websockets.Client{Hub: hub, Conn: conn, Send: make(chan []byte, 256), PlayerService: playerService, GameService: gameService}
	hub.Register <- client

	go client.WritePump()
	go client.ReadPump()
}
