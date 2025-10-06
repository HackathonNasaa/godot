extends CanvasLayer

@onready var menu_container = $MenuContainer
@onready var language_container = $LanguageContainer
@onready var btn_play = $MenuContainer/BtnPlay
@onready var btn_lang = $MenuContainer/BtnLanguage
@onready var btn_music = $MenuContainer/BtnMusic
@onready var btn_portuguese = $LanguageContainer/BtnPortuguese
@onready var btn_english = $LanguageContainer/BtnEnglish
@onready var player_anim: AnimatedSprite2D = $CharacterBody2D/anim

const GAME_SCENE_PATH := "res://scenes/game.tscn"

const MUSIC_ON_TEXTURE = "res://sprites/buttons/SoundOn.png"
const MUSIC_OFF_TEXTURE = "res://sprites/buttons/SoundOff.png"

var music_on: bool = true


func _ready() -> void:
	menu_container.visible = true
	language_container.visible = false

	btn_play.pressed.connect(_on_BtnPlay_pressed)



	_play_sleep_animation()


	btn_play.disabled = false
	await AsteroidManager.data_loaded
	btn_play.disabled = false


func _on_BtnPlay_pressed() -> void:
	var random_asteroid: Dictionary = AsteroidManager.get_random_asteroid()
	if not random_asteroid.is_empty():
		var name = random_asteroid.get("name", "Desconhecido")
		var composition = random_asteroid.get("composition", "Desconhecida")
		print("  - Nome do Asteroide:", name)
		print("  - Composição:", composition.capitalize())

	var error = get_tree().change_scene_to_file(GAME_SCENE_PATH)
	if error != OK:
		push_warning("Não foi possível carregar a cena do jogo: %s" % GAME_SCENE_PATH)


func _play_sleep_animation() -> void:
	if player_anim:
		player_anim.play("sleep")
		var frames = player_anim.sprite_frames
		if frames.has_animation("sleep"):
			frames.set_animation_loop("sleep", true)
