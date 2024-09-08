package models

import (
	"github.com/google/uuid"
	"github.com/notnil/chess"
)

type Game struct {
	ID            string
	Game          *chess.Game
	WhitePlayerID string
	BlackPlayerID string
}

func NewGame(whitePlayerID string, blackPlayerID string) *Game {
	return &Game{
		ID:            uuid.New().String(),
		Game:          chess.NewGame(chess.UseNotation(chess.LongAlgebraicNotation{})),
		WhitePlayerID: whitePlayerID,
		BlackPlayerID: blackPlayerID,
	}
}
