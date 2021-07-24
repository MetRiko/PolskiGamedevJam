tool
extends SignalTriggerable
class_name GravityField

export var maxRange := 100

var fieldStartLocalPoint = Vector2(0.0, 16.0)

var enabled = null

var playerEntered = false
var stateChanged = false

var gravityVec := Vector2()

func setMaxRange(value):
	maxRange = value
	update()
	
func getMaxRange():
	return maxRange

func _renderHints():
	var offset = fieldStartLocalPoint.y
	draw_line(Vector2(16.0, offset), Vector2(16.0, -maxRange + offset), Color.red, 1.0, true)
	draw_line(Vector2(-16.0, offset), Vector2(-16.0, -maxRange + offset), Color.red, 1.0, true)
	draw_line(Vector2(-16.0, -maxRange + offset), Vector2(16.0, -maxRange + offset), Color.red, 1.0, true)

func _draw():
	if Engine.editor_hint == true:
		_renderHints()
	elif Game.editorHints == true:
		_renderHints()
		

#func _updateParticles():
#	$Particles2D


var playerInGravityFieldsCount = 0

func _physics_process(delta):
	if Engine.editor_hint == true or Game.editorHints == true:
		update()
	if Engine.editor_hint == false:
#		print(playerEntered)
		
#		stateChanged = true
#		if stateChanged == true:
#			stateChanged = false
#
#			var player = Game.getPlayer()
#			var found = player
#			for body in $Area2D.get_overlapping_bodies():
##				print(body)
#				if body is Player:
#					found = true
#			changePlayerEntered(found)
#			print(playerEntered)
##			print(playerEntered)
#
		if playerEntered == true:
			var player = Game.getPlayer()
			var gravVec = $Area2D.gravity_vec * $Area2D.gravity
			
			
			var playerVec = player.global_position - global_position
			
			var proj = playerVec.project(gravVec)
			
			var point = global_position + proj
			
			var sideVec = point - player.global_position
			
			
			var finalSideVec = sideVec.normalized() * pow(sideVec.length() / 16.0, 2.4) * 15.0 #. player.linearVelocity.length() # 0.0 - 1.0
			
#			player.impulse(finalSideVec)
			
			var gravityVecProj = player.linearVelocity.project(gravVec.normalized())
#			print(gravityVecProj.length())
			
			var gravPower = 1.0 - clamp(gravityVecProj.length() / 500.0, 0.0, 1.0)
			
			var antyGravForce = max(player.linearVelocity.y, player.gravityForce)
			
			player.impulse($Area2D.gravity_vec * ($Area2D.gravity * 0.2 * gravPower - antyGravForce * 0.6)) 
#			player.linearVelocity = Vector2()
#			player.impulse($Area2D.gravity_vec * gravityVecProj.length())
			
#			var angleSign = sign(gravVec.angle_to(playerVec))
			
			
#			var sideVec = -gravVec.normalized().rotated(angleSign * PI * 0.5) * proj.length()
#			player.impulse(sideVec * 0.1)
			
#			proj = Vector2(sign(gravVec.x) * abs(proj.x), sign(gravVec.y) * abs(proj.y))
			
#			var dotp = proj.normalized().angle_to(player.linearVelocity.normalized())
#			var sideVel = -proj.rotated(sign(dotp) * PI * 0.5)
#			print(proj)
#			player.impulse(sideVel)
			
#			var vel = -player.linearVelocity / ($Area2D.linear_damp * 1.3) + $Area2D.gravity_vec * $Area2D.gravity * 0.3
			
#			var power = player.linearVelocity / ($Area2D.linear_damp * 1.5)
			
#			player.impulse($Area2D.gravity_vec * $Area2D.gravity * 0.04)
			
#			player.impulse(vel)
			
#			player.impulse(-gravVec.normalized().rotated(angleSign * PI * 0.5) * power.length() * 0.6) # * player.linearVelocity.length() * 0.02)
			
#			print(player.linearVelocity.y )
			player.impulse(Vector2.UP * max(player.linearVelocity.y, player.gravityForce))

func changePlayerEntered(flag : bool):
	
	if flag != playerEntered:
		playerEntered = flag
		var player = Game.getPlayer()
#		if flag == true:
#			player.linearVelocity *= 0.3
#		player.switchFriction(not playerEntered)
#		player.switchGravity(not playerEntered)

#func _calculateNumberOfFields():
	

func _onBodyEntered(body):
	if body is Player:
#		stateChanged = true
		changePlayerEntered(true)

func _onBodyExited(body):
	if body is Player:
		changePlayerEntered(false)
#		stateChanged = true
#	for body in $Area2D.get_overlapping_bodies():
#		print(body)
#		if body is Player:
#			changePlayerEntered(true)
#			print('hehe')
#			return
#	changePlayerEntered(false)
		

func _ready():
	if Engine.editor_hint == false:
		$Particles2D.process_material = $Particles2D.process_material.duplicate()
		$Area2D/CollisionShape2D.shape = $Area2D/CollisionShape2D.shape.duplicate()
		
		$Particles2D.process_material.emission_box_extents.y = maxRange * 0.5
		$Particles2D.position.y = -maxRange * 0.5 + fieldStartLocalPoint.y
		$Area2D.position.y = -maxRange * 0.5 + fieldStartLocalPoint.y
		$Area2D/CollisionShape2D.shape.extents.y = maxRange * 0.5
	
		var angle = global_rotation - PI * 0.5
		$Area2D.gravity_vec = Vector2.RIGHT.rotated(angle)
		
		$Area2D.connect("body_entered", self, "_onBodyEntered")
		$Area2D.connect("body_exited", self, "_onBodyExited")
		
		if state:
			onRisingEdge()
		else:
			onFallingEdge()
			
	update()

func _visualUpdate():
	
	if enabled == true:
		$Sprite.frame = 6
	else:
		$Sprite.frame = 5
		
	$Area2D/CollisionShape2D.disabled = not enabled
	$Particles2D.visible = enabled

func enableField():
	if enabled != true:
		enabled = true
		_visualUpdate()
		
	
func disableField():
	if enabled != false:
		enabled = false
		_visualUpdate()

func onFallingEdge():
	disableField()
#
func onRisingEdge():
	enableField()
