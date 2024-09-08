package services

import (
	"chess/models"
	"sync"
)

type PlayerService struct {
	Players map[string]*models.Player // Use ID as key
	mu      sync.Mutex
}

func NewPlayerService() *PlayerService {
	return &PlayerService{
		Players: make(map[string]*models.Player),
	}
}

func (s *PlayerService) AddPlayer(nickname string) *models.Player {
	s.mu.Lock()
	defer s.mu.Unlock()
	player := models.NewPlayer(nickname)
	s.Players[player.ID] = player
	return player
}

func (s *PlayerService) RemovePlayer(id string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.Players, id)
}

func (s *PlayerService) GetPlayerList() []*models.Player {
	s.mu.Lock()
	defer s.mu.Unlock()
	players := make([]*models.Player, 0, len(s.Players))
	for _, player := range s.Players {
		players = append(players, player)
	}
	return players
}

func (s *PlayerService) SetPlayerState(id string, state int) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if player, exists := s.Players[id]; exists {
		player.State = models.PlayerState(state)
	}
}

func (s *PlayerService) GetPlayerByID(id string) *models.Player {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.Players[id]
}

func (s *PlayerService) GetNicknameByID(id string) string {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.Players[id].Nickname
}

func (s *PlayerService) FindFirstOtherPlayerWithStatus(currentId string, status models.PlayerState) *models.Player {
	s.mu.Lock()
	defer s.mu.Unlock()

	for _, player := range s.Players {
		if player.State == status && player.ID != currentId {
			return player
		}
	}

	return nil
}
