extends KinematicBody2D

var cellAttached = {}

var bulletVel := Vector2()

var alive = true

func _ready():
	var collider = $BigBazookaArea/CollisionShape2D
	collider.shape = collider.shape.duplicate()

func impulse(vel):
	bulletVel = vel

func _updateOnCollision(collisionNormal):
	if alive == true:
		alive = false
	for body in $BigBazookaArea.get_overlapping_bodies():
		if body is Damagable:
			if body.isBazookaOnly() and cellAttached.size() >= 50.0:
				body.doDamage(1.0, bulletVel)
	
	var power = pow(cellAttached.size(), 0.4) * 270.0
	for cellData in cellAttached.values():
		var cell = cellData.cell
#		var vel = -bulletVel.rotated(rand_range(-PI * 0.5, PI * 0.5)).normalized() * power
		var vel = collisionNormal.rotated(rand_range(-PI * 0.5, PI * 0.5)).normalized() * power
#		cell.impulse(vel * 0.7)
#		cell.enableCollisionWithCells()
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
	cell.enableCollisionWithCells()

func _calculateBoltOffsetAndSpeed(n):
	
	var size = cellAttached.size()
	var dir = bulletVel.normalized()
#	print(dir)
	
	var maxRadius = pow(size, 0.6) * 0.7
#	var maxRadius = 4.0 + size * 0.8
#	var maxDistance = 1.0 + size * 1.1
	var maxDistance = 20.0 + pow(size, 0.4) * 8.0
#	var maxDistance = 80.0
#	var maxDistance = 400.0
	
	var distance = rand_range(0.0, maxDistance * (1.0 - (n / size))) #float(n) / size * maxDistance
	var distanceProgress = 1.0 - distance / maxDistance
	
#	var radius = rand_range(0.0, maxRadius) * (distanceProgress * 0.4)
#	var radius = rand_range(0.0, maxRadius) * distanceProgress
	var radius = maxRadius * distanceProgress
	
#	var angle = rand_range(0.0, PI * 2.0)

	var angle = dir.angle() + rand_range(-PI * 0.5, PI * 0.5)
	
	var offset = (-dir * distance) + Vector2(cos(angle), sin(angle)) * radius
	
#	var speed = rand_range(0.0, 1.0) * distanceProgress
	var speed = pow(1.0 - distanceProgress, 0.4)
	
	return [offset, speed]

func shoot(vel : Vector2):
	impulse(vel)
	_recalculateOffsets()
	var maxRadius = 5.0 + pow(cellAttached.size(), 0.6) * 0.7
	$BigBazookaArea/CollisionShape2D.shape.radius = maxRadius * 2.2

func _recalculateOffsets():
	var i = 0
	for cellData in cellAttached.values():
		var result = _calculateBoltOffsetAndSpeed(i)
		cellData.boltOffset = result[0]
		cellData.speed = result[1]
		i += 1

func attachCell(cell):
	var cellId = cell.get_instance_id()
	
	cellAttached[cellId] = {
		cell = cell,
		boltOffset = Vector2(),
		speed = rand_range(0.0, 1.0)
	}
	cell.changeColor(3)
	cell.disableGravity()
	cell.linear_damp = 7.0
	cell.disableCollisionWithCells()

func detachCell(cell):
	var cellId = cell.get_instance_id()
	var cellData = cellAttached.get(cellId)
	if cellData:
		cell.changeColor(0)
		cell.enableGravity()
		cell.resetDamp()
		cellAttached.erase(cellId)
	
var rotationProgress = 0.0
	
func _physics_process(delta):
	
	if alive == true:
		var result = move_and_collide(bulletVel * delta)# * 60.0)
		if result:
			call_deferred("_updateOnCollision", result.normal)
#			_updateOnCollision(result.normal)
	
	for cellData in cellAttached.values():
		var cell = cellData.cell
		var offset = cellData.boltOffset
		var speed = cellData.speed
		
		var power = 140.0 + speed * 60.0# + 100.0
#		var power = 140.0 + speed * 10.0 + 1600.0
		
		var vec = global_position - cell.global_position + offset
		cell.impulse(vec.normalized() * power * delta * 60.0)
#		cell.linear_velocity = vec.normalized() * power * delta * 60.0 #* 5.0
		#vec.normalized() * power * delta * 60.0
		
		
#		var vec = global_position - cell.global_position
#		var power = clamp(pow(vec.length(), 1.5) * 0.25, 0.0, 120.0)
#		var vel = vec.normalized() * power * 15.0 * delta * 60.0
#		cell.linear_velocity = vel
