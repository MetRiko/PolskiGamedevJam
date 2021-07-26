extends Node2D


func _ready():
	var soundCtrl = Game.getSoundController()
	soundCtrl.playMusic()
