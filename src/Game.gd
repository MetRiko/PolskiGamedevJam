extends Node

var editorHints = false

onready var root = get_tree().get_root().get_node("Root")
onready var world = root.getWorld()
onready var soundController = root.getSoundController()

var maxHpOrbs = 11
var currHpOrbs = 0

func getPlayer():
	return world.getPlayer()

func getWorld():
	return world

func getSoundController():
	return soundController

