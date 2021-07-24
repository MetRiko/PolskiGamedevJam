extends RigidBody2D

var cellAttached = {}

var bulletVel := Vector2()

var alive = true

func _ready():
	connect("body_entered", self, "onBodyEntered")

func impulse(vel):
	bulletVel = vel
	apply_central_impulse(vel)

func _integrate_forces(state):
	if (state.get_contact_count() > 0):
		if alive == true:
			alive = false
			var normal = state.get_contact_local_normal(0) 
			_updateOnCollision(normal)
			linear_velocity = Vector2()
			collision_mask = 0

func onBodyEntered(body):
	
	if body is Damagable:
		if body.isBazookaOnly():
			body.doDamage(1.0)

func _updateOnCollision(collisionNormal):
	var power = pow(cellAttached.size(), 0.4) * 270.0
	for cell in cellAttached.values():
#		var vel = -bulletVel.rotated(rand_range(-PI * 0.5, PI * 0.5)).normalized() * power
		var vel = collisionNormal.rotated(rand_range(-PI * 0.5, PI * 0.5)).normalized() * power
#		cell.impulse(vel * 0.7)
		var timer = get_tree().create_timer(0.05)
#		cell.linear_damp = 0.0
		timer.connect("timeout", self, "onCellTimer", [cell, vel])
		
	cellAttached = {}
		
	var timer2 = get_tree().create_timer(0.85)
	timer2.connect("timeout", self, "destroy")

func destroy():
	queue_free()

func onCellTimer(cell, vel):
	cell.impulse(vel * 0.4)
#	cell.linear_velocity = Vector2()
#	cell.impulse(vel * 0.1)
	cell.changeColor(0)
	cell.enableGravity()
	cell.resetDamp()
#	cell.enableCollisionWithCells()

func attachCell(cell):
	var cellId = cell.get_instance_id()
	cellAttached[cellId] = cell
	cell.changeColor(3)
	cell.disableGravity()
	cell.linear_damp = 7.0
#	cell.disableCollisionWithCells()
	
func detachCell(cell):
	var cellId = cell.get_instance_id()
	cell = cellAttached.get(cellId)
	if cell:
		cell.changeColor(0)
		cell.enableGravity()
		cell.resetDamp()
		cellAttached.erase(cellId)
	
func _physics_process(delta):
	for cell in cellAttached.values():
		var vec = global_position - cell.global_position
#		var power = clamp(pow(vec.length(), 1.5) * 0.2, 40.0, 80.0)
		var power = clamp(pow(vec.length(), 1.5) * 0.25, 0.0, 120.0)
#		var power = pow(vec.length(), 0.8) * rand_range(-0.3, 1.2) *  2.0
#		print(power)
#		var vel = vec.normalized().rotated(rand_range(-0.3, 0.3)) * power * 15.0 * delta * 60.0
		var vel = vec.normalized() * power * 15.0 * delta * 60.0
		cell.linear_velocity = vel
#		cell.impulse(vel)
