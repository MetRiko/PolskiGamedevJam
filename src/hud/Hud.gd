extends Control

const baseWidth = 67.0

var gameplay = null

onready var progress = $HpBar/TextureProgress

func _ready():
	$HpBar/AnimationPlayer.play("Idle", -1.0, 2.5)

	var world = Game.getWorld()
	gameplay = world.getGameplay()
	
	gameplay.connect("player_hp_changed", self, "_onHpChanged")
	gameplay.connect("player_max_hp_changed", self, "_onMaxHpChanged")

func _onHpChanged(hp, maxHp):
	$HpBar/Tween.interpolate_property(progress, "value", null, hp, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$HpBar/Tween.start()
#	progress.value = hp
	
func _onMaxHpChanged(hp, maxHp):
#	progress.max_value = maxHp
#	progress.rect_size.x = baseWidth + maxHp
	$HpBar/Tween.interpolate_property(progress, "max_value", null, maxHp, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	$HpBar/Tween.interpolate_property(progress, "rect_size:x", null, maxHp * 4.0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	$HpBar/Tween.start()
	
func _input(event):
	if event.is_action_pressed("move_left"):
		gameplay.addPlayerHp(-10.0)
		
	if event.is_action_pressed("move_right"):
		gameplay.addPlayerHp(10.0)
		
	if event.is_action_pressed("num_2"):
		gameplay.addPlayerMaxHp(-10.0)
		
	if event.is_action_pressed("num_3"):
		gameplay.addPlayerMaxHp(10.0)
#		pass
