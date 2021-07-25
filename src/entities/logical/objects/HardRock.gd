extends Damagable

var particles = null

var hitDir := Vector2()

func _ready():
	randomize()
	setHp(1.0)
	setBazookaOnly(true)
	particles = $Particles
	remove_child(particles)
	
func onKill():
	
	$Tween.interpolate_property($Sprite, "modulate:r", 1.0, 4.0, 0.04, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	$Tween.interpolate_property($Sprite, "modulate:r", 4.0, 0.0, 0.08, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()
	$Tween.interpolate_property($Sprite, "scale", Vector2(1.0, 1.0), Vector2(1.6, 1.6), 0.04, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	$Tween.interpolate_property($Sprite, "scale", Vector2(1.6, 1.6), Vector2(1.0, 1.0), 0.08, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()
#	$Tween.interpolate_property($Sprite, "modulate:a", 1.0, 0.0, 0.16, Tween.TRANS_SINE, Tween.EASE_IN)
#	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	
	$Sprite.visible = false
	
	add_child(particles)
	particles.position = Vector2()
	
	for particle in particles.get_children():
#		var angle = (hitDir).angle() + rand_range(-PI * 0.4, PI * 0.4)
#		var angle = rand_range(-PI * 0.4, PI * 0.4)
		var angle = rand_range(-PI * 0.1, PI * 0.1) - PI * 0.5
		particle.linear_velocity = Vector2(cos(angle), sin(angle)) * (280.0 + rand_range(0.0, 210.0))
		
	yield(get_tree().create_timer(3.5), "timeout")
	
	$Tween.interpolate_property($Particles, "modulate:a", 1.0, 0.0, 0.8, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	
	queue_free()

func doDamage(value, _hitDir):
	hitDir = _hitDir
	.doDamage(value, hitDir)
	
func kill():
#	$CollisionShape2D.disabled = true
#	call_deferred("set_collision_layer", 0)
#	call_deferred("set_collision_mask", 0)
	collision_layer = 0
	collision_mask = 0
	
	call_deferred("onKill")
	
#	queue_free()
