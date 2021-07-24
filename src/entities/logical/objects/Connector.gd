extends Node2D

export var connection: NodePath

var connectedWith = null

func _ready():
	if connection:
		connectedWith = get_node(connection)
		for triggerable in get_children():
			triggerable.connectTo(connectedWith)
