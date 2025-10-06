extends Control

# Nós da cena
@onready var anim_sprite: AnimatedSprite2D = $ResultAnimation

func _ready() -> void:
	# Inicialmente invisível
	visible = false
	show_result(Global.last_game_result)

# -------------------------
# Mostra a tela de resultado
# -------------------------
# success = true -> vitória
# success = false -> derrota
func show_result(success: bool) -> void:
	visible = true
	
	if not anim_sprite:
		push_warning("AnimatedSprite2D não encontrado!")
		return

	# Configura a animação para NÃO fazer loop
	anim_sprite.sprite_frames.set_animation_loop("victory", false)
	anim_sprite.sprite_frames.set_animation_loop("defeat", false)

	# Escolhe animação
	if success:
		anim_sprite.animation = "victory"
	else:
		anim_sprite.animation = "defeat"
	
	anim_sprite.play()

	# Bloqueia o player
	var player = get_tree().current_scene.get_node_or_null("CharacterBody2D")
	if player:
		player.can_move = false

	# Conecta sinal da animação
	if not anim_sprite.animation_finished.is_connected(_on_animation_finished):
		anim_sprite.animation_finished.connect(_on_animation_finished)

# -------------------------
# Chamado quando a animação termina
# -------------------------
func _on_animation_finished() -> void:
	print("🎬 Animação terminou, voltando para o menu...")
	
	# Desbloqueia o player (opcional)
	var player = get_tree().current_scene.get_node_or_null("CharacterBody2D")
	if player:
		player.can_move = true

	# SEMPRE volta para o menu inicial, independente do resultado
	const MENU_SCENE_PATH := "res://scenes/ui.tscn"
	var err = get_tree().change_scene_to_file(MENU_SCENE_PATH)
	if err != OK:
		push_warning("Não foi possível carregar a cena do menu inicial: %s" % MENU_SCENE_PATH)
