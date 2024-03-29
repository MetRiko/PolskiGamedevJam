extends Control

const baseWidth = 67.0

var gameplay = null

var deathScreenDisplayed = false

onready var progress = $HpBar/TextureProgress

var gameState = 0

func _setupIntro():
	var player = Game.getPlayer()
	player.switchControls(false)
	$Intro/Black.modulate.a = 1.0
	$Intro/StoryLabel.modulate.a = 0.0
	$Intro/SpaceLabel.modulate.a = 1.0
	$HpBar.modulate.a = 0.0
	
func startGame():
	$Intro/SpaceLabel.modulate.a = 0.0
	$Intro/StoryLabel.modulate.a = 1.0
	Game.getSoundController().playNextIntroSound()
	$Intro/Title.modulate.a = 0.0
	yield(get_tree().create_timer(33.0), "timeout")
	changeGameState(2)

func skipDialog():
	$Intro.modulate.a = 0.0
	$HpBar.modulate.a = 1.0
	Game.getSoundController().stopSound()
	var player = Game.getPlayer()
	player.switchControls(true)

func _ready():
	_setupIntro()
	
	$HpBar/AnimationPlayer.play("Idle", -1.0, 2.5)

	var world = Game.getWorld()
	gameplay = world.getGameplay()
	
	gameplay.connect("player_hp_changed", self, "_onHpChanged")
	gameplay.connect("player_max_hp_changed", self, "_onMaxHpChanged")
	gameplay.connect("player_died", self, "_onPlayerDied")

	$DeathScreen/TextureRect.modulate.a = 0.0
	$DeathScreen/Labels.modulate.a = 0.0

func _onHpChanged(hp, maxHp):
	if $HpBar/Tween.is_active():
		yield($HpBar/Tween, "tween_all_completed")
	$HpBar/Tween.interpolate_property(progress, "value", null, hp, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$HpBar/Tween.start()
#	progress.value = hp
	
func _onMaxHpChanged(hp, maxHp):
#	progress.max_value = maxHp
#	progress.rect_size.x = baseWidth + maxHp
	if $HpBar/Tween.is_active():
		yield($HpBar/Tween, "tween_all_completed")
	$HpBar/Tween.interpolate_property(progress, "max_value", null, maxHp, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	$HpBar/Tween.interpolate_property(progress, "rect_size:x", null, maxHp * 4.0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	$HpBar/Tween.start()
	
func changeGameState(state):
	if gameState != state:
		gameState = state
		if state == 1:
			startGame()
		elif state == 2:
			skipDialog()
	
func _onPlayerDied():
	displayDeathScreen()
	
func _input(event):
	
	if gameState == 0:
		if event.is_action_pressed("jump"):
			changeGameState(1)
			
	elif gameState == 1:
		if event.is_action_pressed("jump"):
			changeGameState(2)
	
	
	if event.is_action_pressed("num_2"):
		gameplay.addPlayerHp(-10.0)
		
	if event.is_action_pressed("num_3"):
		gameplay.addPlayerHp(10.0)
		
#	if event.is_action_pressed("num_2"):
#		gameplay.addPlayerMaxHp(-10.0)
#
#	if event.is_action_pressed("num_3"):
#		gameplay.addPlayerMaxHp(10.0)
#		pass

#	if event.is_action_pressed("num_2"):
#		displayDeathScreen()
#	if event.is_action_pressed("num_3"):
#		hideDeathScreen()
	
	if deathScreenDisplayed == true:
		if event.is_action_pressed("jump"):
			Game.getWorld().respawnPlayer()
			hideDeathScreen()

func hideDeathScreen():
	deathScreenDisplayed = false
	$DeathScreen/Tween.interpolate_property($DeathScreen/TextureRect, "modulate:a", null, 0.0, 1.2, Tween.TRANS_SINE, Tween.EASE_IN)
	$DeathScreen/Tween.start()
	$DeathScreen/Tween.interpolate_property($DeathScreen/Labels, "modulate:a", null, 0.0, 1.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$DeathScreen/Tween.start()
		
func displayDeathScreen():
	$DeathScreen/Tween.interpolate_property($DeathScreen/TextureRect, "modulate:a", null, 0.5, 0.9, Tween.TRANS_SINE, Tween.EASE_OUT)
	$DeathScreen/Tween.start()
	$DeathScreen/Tween.interpolate_property($DeathScreen/Labels, "modulate:a", null, 1.0, 1.2, Tween.TRANS_SINE, Tween.EASE_IN)
	$DeathScreen/Tween.start()
	yield($DeathScreen/Tween, "tween_all_completed")
	deathScreenDisplayed = true
