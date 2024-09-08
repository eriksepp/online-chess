package services

import (
	"chess/models"
	"fmt"
	"math/rand"
	"sync"
	"time"
)

type GameService struct {
	Games map[string]*models.Game
	mu    sync.Mutex
}

func NewGameService() *GameService {
	return &GameService{
		Games: make(map[string]*models.Game),
	}
}

func (s *GameService) CreateGame(player1ID, player2ID string) *models.Game {
	var whitePlayerID string
	var blackPlayerID string

	// Assign colors randomly
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	if r.Intn(2) == 0 {
		whitePlayerID = player1ID
		blackPlayerID = player2ID
	} else {
		blackPlayerID = player1ID
		whitePlayerID = player2ID
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	game := models.NewGame(whitePlayerID, blackPlayerID)
	s.Games[game.ID] = game
	return game
}

func (s *GameService) HandleMoveRequest(gameID, moveStr string) error {
	chessGame := s.Games[gameID].Game
	if err := chessGame.MoveStr(string(moveStr)); err != nil {
		fmt.Println("Error: ", err)
		return err
	}
	return nil
}

func (s *GameService) CheckOutcome(gameID string) string {
	return s.Games[gameID].Game.Outcome().String()
}

func (s *GameService) GetOpponentID(gameID, playerID string) string {
	gameData := s.Games[gameID]
	if gameData.WhitePlayerID == playerID {
		return gameData.BlackPlayerID
	} else {
		return gameData.WhitePlayerID
	}
}
