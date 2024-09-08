package models

import (
	"github.com/google/uuid"
)

type PlayerState int

const (
	Main     PlayerState = iota // available for invite
	Pending                     // has sent or received an invite
	WaitRoom                    // is waiting in wait room
	Playing                     // in a game
)

type Player struct {
	ID       string
	Nickname string
	State    PlayerState
}

func NewPlayer(nickname string) *Player {
	return &Player{
		ID:       uuid.New().String(),
		Nickname: nickname,
		State:    Main,
	}
}
