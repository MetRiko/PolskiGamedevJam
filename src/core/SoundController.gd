extends Node2D

var track
const soundFiles = [
	preload("res://res/audio/collecting water.wav"), #bending(continuous)
	preload("res://res/audio/bullet.wav"),           #shooting bullets(burst)
	preload("res://res/audio/melee.wav"),            #melee part of shotgun(burst)
	preload("res://res/audio/shotgun.wav"),          #shotgun part of shotgun(burst)
	preload("res://res/audio/shield.wav"),           #shield(continous)
	preload("res://res/audio/multijump.wav"),        #multijump(burst)
	preload("res://res/audio/intro.wav"),            #on start of game
	preload("res://res/audio/skafander.wav"),        #on start of gameplay
	preload("res://res/audio/skafander 2.wav"),      #on first input
	preload("res://res/audio/module 1.wav"),         #on finding module/ if preferred, scrap a couple of those and add some more for abilities
	preload("res://res/audio/module 2.wav"),         #-||-
	preload("res://res/audio/module 3.wav"),         #-||-
	preload("res://res/audio/module 4.wav"),         #-||-
	preload("res://res/audio/kosmici.wav"),          #on first combat encounter (maybe a room start)
	preload("res://res/audio/upgrade 1.wav"),        #on finding an ability
	preload("res://res/audio/upgrade 2.wav"),        #-||-
	preload("res://res/audio/upgrade 3.wav"),        #-||-
	preload("res://res/audio/upgrade 4.wav"),        #-||-
	preload("res://res/audio/optional.wav")          #don't add, no proper sprite that it refers to
]

const musicFile = preload("res://res/audio/ambient.wav")

var moduleSounds = [
	soundFiles[9],
	soundFiles[10],
	soundFiles[11],
	soundFiles[12]
]
var nextModuleSound = 0

var skillsSounds = [
	soundFiles[14],
	soundFiles[15],
	soundFiles[16],
	soundFiles[17],
	soundFiles[14],
	soundFiles[15],
	soundFiles[16],
	soundFiles[17],
	soundFiles[14]
]
#var nextSkillSound = 0

var intro = [
	soundFiles[6],
	soundFiles[7],
	soundFiles[8]
]
var nextIntroSound = 0

func playMusic():
	$AudioPlayerMusic.stream = musicFile
	$AudioPlayerMusic.play()

func playSkillSound(skillId):
	playAudio(skillsSounds[skillId])

func playNextModuleSound():
	if nextModuleSound < moduleSounds.size():
		playAudio(moduleSounds[nextModuleSound])
		nextModuleSound = (nextModuleSound + 1) % moduleSounds.size()
		
func stopSound():
	$AudioPlayer.stop()
		
func playNextIntroSound():
	if nextIntroSound < intro.size():
		playAudio(intro[nextIntroSound])
		nextIntroSound += 1

func playAudio(_track):
#	track = soundFiles[dialogueId]
	track = _track
	$AudioPlayer.stream = track
	$AudioPlayer.play()
