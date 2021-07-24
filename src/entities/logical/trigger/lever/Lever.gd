tool
extends ControlledTrigger

#export var playerRef: NodePath 
export var actionableDistance:float = 1.0 setget _toolDistanceChange

func _toolDistanceChange(dst):
	if Engine.editor_hint:
		update()
	actionableDistance = dst

var player: Node2D = null
#onready var player: Node2D = get_node(playerRef)

func _ready():
	if not Engine.editor_hint:
		player = Game.getPlayer()
		
var inRange:bool = false

func _draw():
	if Engine.editor_hint or (debug_hints and OS.is_debug_build()):
		draw_arc(Vector2.ZERO,actionableDistance,0,deg2rad(360),64,Color.red,1.0,true)
	if debug_hints and OS.is_debug_build():
		if inRange:
			draw_circle(24*Vector2.UP + 24*Vector2.LEFT,5,Color.green)
		else:
			draw_arc(24*Vector2.UP + 24*Vector2.LEFT,5,0,deg2rad(360),64,Color.green,1.0,true)
		
		
func poll_player_distance():
	inRange = false
	if player.global_position.distance_to(global_position) < actionableDistance:
		inRange = true

func _input(event):
	if not Engine.editor_hint and event.is_action_pressed("Interact"):
		if inRange:
			flip()

func _process(delta):
	if not Engine.editor_hint:
		poll_player_distance()
		update()
