extends Node2D

signal player_hp_changed
signal player_max_hp_changed
signal player_died 

var playerHp = 20.0

var maxPlayerHp = 20.0

func _ready():
	setPlayerMaxHp(maxPlayerHp)
	setPlayerHp(playerHp)

func addPlayerHp(value : float):
	setPlayerHp(playerHp + value)

func damagePlayer(value : float, knockback : Vector2 = Vector2.ZERO):
	var world = get_parent()
	var bendingCtrl = world.getBendingController()
	var damageAfterReduce = bendingCtrl.reduceDamage(value, knockback)
	if damageAfterReduce > 0.0:
		addPlayerHp(-damageAfterReduce)
	var player = world.getPlayer()
	player.impulse(knockback)
	return damageAfterReduce > 0

func addPlayerMaxHp(value : float):
	setPlayerMaxHp(maxPlayerHp + value)
	
func restoreFullHp():
	setPlayerHp(maxPlayerHp)

func setPlayerHp(value : float):
	var mem = playerHp
	playerHp = clamp(value, 0.0, maxPlayerHp)
	emit_signal("player_hp_changed", playerHp, maxPlayerHp)
	if playerHp == 0.0 and playerHp != mem:
		emit_signal("player_died")

func setPlayerMaxHp(value : float):
	maxPlayerHp = max(value, 0.0)
	emit_signal("player_max_hp_changed", playerHp, maxPlayerHp)
	setPlayerHp(playerHp)
	
