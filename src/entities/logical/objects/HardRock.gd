extends Damagable

var particles = null

func _ready():
	randomize()
	setHp(1.0)
	setBazookaOnly(true)
	particles = $Particles
	remove_child(particles)
	
func onKill():
	add_child(particles)
	particles.position = Vector2()
	
	for particle in particles.get_children():
		var angle = rand_range(0.0, PI * 2.0)
		particle.linear_velocity = Vector2(cos(angle), sin(angle)) * (180.0 + rand_range(0.0, 120.0))
	
func kill():
	
	$Sprite.visible = false
#	$CollisionShape2D.disabled = true
#	call_deferred("set_collision_layer", 0)
#	call_deferred("set_collision_mask", 0)
	collision_layer = 0
	collision_mask = 0
	
	call_deferred("onKill")
	
#	queue_free()
