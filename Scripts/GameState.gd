extends Node

enum Phase {
	GAMEPLAY,
	DIALOGUE,
	PAUSED,
	STAGE_INTRO,
	STAGE_CLEAR
}

var phase: Phase = Phase.GAMEPLAY
