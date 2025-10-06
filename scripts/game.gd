# game.gd (Versão Simplificada - sem potência/orçamento)
extends Node2D

# Renomeado para evitar conflito com Singleton GameState.gd
enum GameFlowState {
	MENU,
	LANGUAGE_SELECTION,
	RUNNING
}

const RESULT_SCENE_PATH = "res://scenes/result_screen.tscn" # Única cena de resultado para tudo

# --- Estado do jogo ---
var game_state = GameFlowState.RUNNING

# --- Nós da cena ---
@onready var alarm_layer: CanvasLayer = $AlarmLayer
@onready var alarm_overlay: ColorRect = $AlarmLayer/AlarmOverlay
@onready var player: CharacterBody2D = $CharacterBody2D
@onready var timer_label: Label = $"CommandRoom/CanvasLayer/TimerContainer/TimerLabel"
@onready var game_timer: Timer = $"CommandRoom/CanvasLayer/TimerContainer/Timer"

# --- Mecânicas ---
@export var weapons_container: Node
@export var result_ui: Control
@export var asteroid_info_label: Label

var current_asteroid: Dictionary
var _timer_started: bool = false
var _remaining_seconds: int = 0

# ========================
# READY
# ========================
func _ready() -> void:
	game_state = GameFlowState.RUNNING
	activate_alarm()

	if player and player.has_method("wake_up"):
		await player.wake_up()
	
	var icon_tex = preload("res://sprites/movement_icons.png")
	show_tutorial(icon_tex, "Pressione Z para pegar o item!", 4.0)

	# Conexões
	AsteroidManager.data_loaded.connect(_on_data_loaded)
	if result_ui and result_ui.has_signal("round_finished"):
		result_ui.round_finished.connect(_start_new_round)

	_deactivate_all_weapons()

# ========================
# CALLBACKS
# ========================
func _on_data_loaded():
	print("✅ Dados dos asteroides carregados!")

func deactivate_alarm_and_start_timer() -> void:
	if _timer_started:
		return
	_timer_started = true

	if alarm_overlay:
		alarm_overlay.set_active(false)

	_remaining_seconds = 180
	if timer_label:
		timer_label.text = _format_time(_remaining_seconds)
	if game_timer:
		if game_timer.timeout.is_connected(_on_countdown_tick):
			game_timer.timeout.disconnect(_on_countdown_tick)
		game_timer.timeout.connect(_on_countdown_tick)
		game_timer.start()
		print("✅ Timer iniciado.")

	_start_new_round()

# ========================
# ROUND
# ========================
func _start_new_round():
	print("--- NOVO ROUND ---")
	current_asteroid = AsteroidManager.get_random_asteroid()
	if current_asteroid.is_empty():
		if asteroid_info_label: asteroid_info_label.text = "ERRO: Asteroide inválido"
		return

	# Obtém a arma correta para este asteroide
	var correct_weapon_id = GameRules.WEAPON_MATCH[current_asteroid.composition]

	var info_text = """
	Alvo: %s
	Composição: %s
	Arma Eficaz: %s
	""" % [current_asteroid.name, current_asteroid.composition.capitalize(), correct_weapon_id.capitalize()]

	if asteroid_info_label:
		asteroid_info_label.text = info_text

	_activate_all_weapons()

# ========================
# GETTERS
# ========================
func get_current_asteroid() -> Dictionary:
	return current_asteroid

# ========================
# ATIVA/DESATIVA ARMAS
# ========================
func _activate_all_weapons():
	if not weapons_container: return
	for weapon in weapons_container.get_children():
		if weapon.has_method("activate_weapon"):
			weapon.activate_weapon()

func _deactivate_all_weapons():
	if not weapons_container: return
	for weapon in weapons_container.get_children():
		if weapon.has_method("deactivate_weapon"):
			weapon.deactivate_weapon()

# ========================
# GAMEFLOW ORIGINAL
# ========================
func start_game():
	game_state = GameFlowState.RUNNING
	print("Jogo iniciado!")
	activate_alarm()

func activate_alarm():
	if alarm_overlay:
		alarm_overlay.set_active(true)

func _on_countdown_tick():
	_remaining_seconds -= 1
	if timer_label:
		timer_label.text = _format_time(_remaining_seconds)
	if _remaining_seconds <= 0:
		if game_timer:
			game_timer.stop()
		_on_timer_timeout()

func _on_timer_timeout():
	print("💥 TEMPO ESGOTADO! 💥")
	Global.last_game_result = false
	get_tree().change_scene_to_file(RESULT_SCENE_PATH)
	


func _format_time(seconds: int) -> String:
	var m = int(seconds / 60)
	var s = int(seconds % 60)
	return "%02d:%02d" % [m, s]

# ========================
# TUTORIAL
# ========================
func show_tutorial(icon_texture: Texture2D, text: String, duration: float = 3.0):
	var tutorial_scene = preload("res://scenes/TutorialIcon.tscn")
	var tutorial_instance = tutorial_scene.instantiate()
	tutorial_instance.icon_texture = icon_texture
	tutorial_instance.display_text = text
	add_child(tutorial_instance)
	
	var timer_node = tutorial_instance.get_node("Timer")
	timer_node.wait_time = duration
	if not timer_node.timeout.is_connected(tutorial_instance.fade_out_and_destroy):
		timer_node.timeout.connect(tutorial_instance.fade_out_and_destroy)
	timer_node.start()
