extends Node2D

var track
const soundFiles = [
	 preload("../../audio assets/collecting water.wav"), #bending(continuous)
	 preload("../../audio assets/bullet.wav"),           #shooting bullets(burst)
	 preload("../../audio assets/melee.wav"),            #melee part of shotgun(burst)
	 preload("../../audio assets/shotgun.wav"),          #shotgun part of shotgun(burst)
	 preload("../../audio assets/shield.wav"),           #shield(continous)
	 preload("../../audio assets/multijump.wav"),        #multijump(burst)
	 preload("../../audio assets/intro.wav"),            #on start of game
	 preload("../../audio assets/skafander.wav"),        #on start of gameplay
	 preload("../../audio assets/skafander 2.wav"),      #on first input
	 preload("../../audio assets/module 1.wav"),         #on finding module/ if preferred, scrap a couple of those and add some more for abilities
	 preload("../../audio assets/module 2.wav"),         #-||-
	 preload("../../audio assets/module 3.wav"),         #-||-
	 preload("../../audio assets/module 4.wav"),         #-||-
	 preload("../../audio assets/kosmici.wav"),          #on first combat encounter (maybe a room start)
	 preload("../../audio assets/upgrade 1.wav"),        #on finding an ability
	 preload("../../audio assets/upgrade 2.wav"),        #-||-
	 preload("../../audio assets/upgrade 3.wav"),        #-||-
	 preload("../../audio assets/upgrade 4.wav"),        #-||-
	 preload("../../audio assets/optional.wav")          #don't add, no proper sprite that it refers to
]

func PlayAudio(dialogueId):
	track = soundFiles[dialogueId]
	$AudioPlayer.stream = track
	$AudioPlayer.play()
