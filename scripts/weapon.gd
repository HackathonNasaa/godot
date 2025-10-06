extends Area2D

# --------------------------
# Configurações
# --------------------------
@export var pickup_key: Key = KEY_ENTER
@export var drop_key: Key = KEY_SPACE
@export var weapon_type: String = "canhao_magnetico"
@onready var target: Area2D = $"../../WeaponTarget"
@onready var audio_pickup: AudioStreamPlayer = $AudioPickup

# Caminho da cena de resultado
const RESULT_SCREEN_PATH := "res://scenes/result_screen.tscn"

# --------------------------
# Variáveis de estado
# --------------------------
var is_held: bool = false
var holder: CharacterBody2D = null
var offset: Vector2 = Vector2(20, -10)
var original_z_index: int = 0
var follow_speed: float = 12.0
var weapon_active: bool = false
static var global_holder: CharacterBody2D = null

# --------------------------
# Ready
# --------------------------
func _ready():
	original_z_index = z_index
	visible = false

# --------------------------
# Ativa / desativa a arma
# --------------------------
func activate_weapon():
	weapon_active = true
	visible = true

func deactivate_weapon():
	weapon_active = false
	visible = false
	is_held = false
	holder = null
	global_holder = null

# --------------------------
# Process: segue o player
# --------------------------
func _process(delta):
	if is_held and holder:
		var target_pos = holder.global_position + offset
		global_position = global_position.lerp(target_pos, follow_speed * delta)
		z_index = 100
	else:
		z_index = original_z_index

# --------------------------
# Input
# --------------------------
func _input(event):
	if event is InputEventKey and event.pressed:
		if not is_held and event.keycode == pickup_key:
			_attempt_pickup()
		elif is_held and event.keycode == drop_key:
			_attempt_drop()

# --------------------------
# Tentativa de pegar arma
# --------------------------
func _attempt_pickup():
	if not weapon_active or global_holder != null:
		return

	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			holder = body
			global_holder = body
			is_held = true
			if audio_pickup:
				audio_pickup.play()
			if $AnimatedSprite2D:
				$AnimatedSprite2D.play("pickup")
			return

# --------------------------
# Tentativa de soltar arma
# --------------------------
func _attempt_drop():
	if not is_held:
		return
	
	global_holder = null

	# VERIFICA SE ESTÁ NA ÁREA DO ALVO ANTES DE SOLTAR
	if target and target.get_overlapping_bodies().has(holder):
		print("🎯 Arma colocada no alvo! (%s)" % weapon_type)
		is_held = false
		holder = null
		global_position = target.global_position
		await _fire_weapon()
	else:
		# NÃO PERMITE SOLTAR FORA DO ALVO - MOSTRA FEEDBACK
		print("❌ Você só pode soltar a arma no alvo!")
		
		# Feedback visual (pisca em vermelho)
		_show_error_feedback()
		
		# Mantém a arma seguindo o jogador
		is_held = true
		holder = holder  # Mantém o holder
		global_holder = holder

# --------------------------
# Feedback de erro visual
# --------------------------
func _show_error_feedback():
	if $AnimatedSprite2D:
		# Salva a modulação original
		var original_modulate = $AnimatedSprite2D.modulate
		
		# Pisca em vermelho
		$AnimatedSprite2D.modulate = Color.RED
		await get_tree().create_timer(0.3).timeout
		$AnimatedSprite2D.modulate = original_modulate

# --------------------------
# Função de disparo / resultado
# --------------------------
func _fire_weapon() -> void:
	# Toca animação de disparo da arma
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("fire")
		await $AnimatedSprite2D.animation_finished

	# Obtém referência à cena principal
	var scene = get_tree().current_scene
	if not scene:
		push_warning("Cena principal não encontrada")
		return

	# Pega o asteroide atual
	if not scene.has_method("get_current_asteroid"):
		push_warning("Cena principal não possui get_current_asteroid()")
		return

	var asteroid = scene.get_current_asteroid()

	if asteroid.is_empty():
		print("ERRO: Não foi possível obter os dados do asteroide atual.")
		return

	var success: bool = GameRules.is_correct_weapon(asteroid.composition, weapon_type)

	if success:
		print("✅ Sucesso! Meteoro destruído com a arma correta: %s" % weapon_type)
	else:
		print("❌ FALHA: Arma incorreta para este tipo de meteoro!")

	# Salva o resultado no Global e muda para a cena de resultado
	if has_node("/root/Global"):
		get_node("/root/Global").last_game_result = success
	else:
		push_warning("Global singleton não encontrado! Criando variável local.")
		if not get_tree().root.has_meta("last_game_result"):
			get_tree().root.set_meta("last_game_result", success)

	# Muda para a cena de resultado
	get_tree().change_scene_to_file(RESULT_SCREEN_PATH)
