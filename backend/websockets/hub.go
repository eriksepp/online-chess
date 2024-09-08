package websockets

type Hub struct {
	Clients    map[*Client]bool
	PlayerMap  map[string]*Client
	Broadcast  chan []byte
	Register   chan *Client
	Unregister chan *Client
}

func NewHub() *Hub {
	return &Hub{
		Broadcast:  make(chan []byte),
		Register:   make(chan *Client),
		Unregister: make(chan *Client),
		Clients:    make(map[*Client]bool),
		PlayerMap:  make(map[string]*Client),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.Register:
			h.Clients[client] = true
		case client := <-h.Unregister:
			if _, ok := h.Clients[client]; ok {
				delete(h.Clients, client)
				close(client.Send)

				if client.PlayerID != "" {
					delete(h.PlayerMap, client.PlayerID)
				}
			}
		case message := <-h.Broadcast:
			for client := range h.Clients {
				select {
				case client.Send <- message:
				default:
					close(client.Send)
					delete(h.Clients, client)
				}
			}
		}
	}
}

func (h *Hub) FindClientByID(playerID string) *Client {
	if client, ok := h.PlayerMap[playerID]; ok {
		return client
	}
	return nil
}

func (h *Hub) AssignPlayerID(client *Client, playerID string) {
	client.PlayerID = playerID
	h.PlayerMap[playerID] = client
}
