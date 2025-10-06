extends CharacterBody2D

const SPEED = 150.0

@onready var anim: AnimatedSprite2D = $anim                    # Para "sleep", "wake_up" e "idle"
@onready var animRun: AnimatedSprite2D = $AnimatedSprite2D     # Para "run", "run_cima" e "run_baixo"

var is_awake: bool = false
var can_move: bool = false

func _ready() -> void:
	# Mapeia as teclas WASD para ações de movimento
	map_key_if_not_exists("ui_up", KEY_W)
	map_key_if_not_exists("ui_left", KEY_A)
	map_key_if_not_exists("ui_down", KEY_S)
	map_key_if_not_exists("ui_right", KEY_D)
	add_to_group("player")

	anim.visible = true
	animRun.visible = false
	anim.play("sleep")
	visible = true

# ✅ Função corrigida para Godot 4.x
func map_key_if_not_exists(action_name: String, key_code: Key):
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.keycode == key_code:
			return

	var key_event := InputEventKey.new()
	key_event.keycode = key_code
	InputMap.action_add_event(action_name, key_event)

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		return

	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if direction.length() > 0.1:
		velocity = direction.normalized() * SPEED

		# Mostrar animRun e esconder anim
		anim.visible = false
		animRun.visible = true

		# Define animação baseada na direção
		if direction.y < -0.5:
			if animRun.animation != "run_cima" or not animRun.is_playing():
				animRun.play("run_cima")
		elif direction.y > 0.5:
			if animRun.animation != "run_baixo" or not animRun.is_playing():
				animRun.play("run_baixo")
		else:
			if animRun.animation != "run" or not animRun.is_playing():
				animRun.play("run")

		# Flip horizontal apenas se não estiver indo para cima ou para baixo diretamente
		animRun.flip_h = direction.x < 0 and abs(direction.y) < 0.5
	else:
		velocity = Vector2.ZERO

		# Parou de se mover: mostra idle
		if animRun.visible:
			animRun.visible = false
			anim.visible = true
			anim.play("idle")

	move_and_slide()

func wake_up() -> void:
	if is_awake:
		return

	is_awake = true
	anim.play("wake_up")
	await anim.animation_finished

	anim.visible = false
	animRun.visible = true
	animRun.play("run")
	can_move = true
