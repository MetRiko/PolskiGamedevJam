extends Node2D

const sceneBazookaBullet = preload("res://src/bending/BazookaBullet.tscn")

onready var bendingCtrl = get_parent()

func _ready():
	bendingCtrl.getBendingTechnique().connect("attract_mode_changed", self, "onAttractModeChanged")

func onAttractModeChanged(state):
	if state == false:
		_tryShoot()

func _tryShoot():
	
	var player = bendingCtrl.get_parent().getPlayer()
	var playerPos = player.global_position
	
	var mousePos = get_global_mouse_position()
	var vec = mousePos - playerPos
	vec = vec.normalized() * clamp(vec.length(), 0.0, bendingCtrl.getBendingTechnique().maxBendingRange) 
	var targetPos = playerPos + vec

	var indicator = bendingCtrl.getIndicator()
	var indicatorPos = indicator.global_position
	
	var indicatorVec = targetPos - indicatorPos
	
	if indicatorVec.length() > 30.0:
		shoot(indicatorVec.normalized())
		
func shoot(dir):
	var bullet = sceneBazookaBullet.instance()
	$Bullets.add_child(bullet)
	
	var indicator = bendingCtrl.getIndicator()
	bullet.global_position = indicator.global_position
	
	var vel = dir * 850.0
#	var vel = dir * 200.0
#	bullet.impulse(vel)
	
	var cells = bendingCtrl.getBendingTechnique().detachRandomCells(200)
	for cell in cells:
		bullet.attachCell(cell)
		
	bullet.shoot(vel)
	
	
