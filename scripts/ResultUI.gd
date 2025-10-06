extends Control

# Sinal para avisar o game.gd que o round terminou e um novo pode começar.
signal round_finished

@export var dialog_position: Vector2 = Vector2(340, 150)
@onready var label: Label = $"CanvasLayer/NinePatchRect/Label"
@onready var dialog_box: NinePatchRect = $"CanvasLayer/NinePatchRect"
@onready var ok_button: Button = $"CanvasLayer/NinePatchRect/Button"

var is_visible: bool = false


func _ready() -> void:
	# Seu código de configuração original é mantido.
	dialog_box.visible = false
	dialog_box.custom_minimum_size = Vector2(550, 200)
	dialog_box.size = Vector2(550, 200)
	dialog_box.position = dialog_position
	dialog_box.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Configuração do Label
	if label:
		label.text = ""
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.add_theme_constant_override("margin_left", 20)
		label.add_theme_constant_override("margin_right", 20)
		label.add_theme_constant_override("margin_top", 20)
		label.add_theme_constant_override("margin_bottom", 60)
		label.custom_minimum_size = Vector2(500, 120)

	# Configuração do botão
	if ok_button:
		ok_button.custom_minimum_size = Vector2(100, 40)
		ok_button.size = Vector2(100, 40)
		var button_margin = Vector2(20, 20)
		ok_button.position = Vector2(
			dialog_box.size.x - ok_button.size.x - button_margin.x,
			dialog_box.size.y - ok_button.size.y - button_margin.y
		)
		ok_button.focus_mode = Control.FOCUS_NONE
		ok_button.mouse_filter = Control.MOUSE_FILTER_STOP
		ok_button.disabled = false

		if ok_button.pressed.is_connected(_on_ok_pressed):
			ok_button.pressed.disconnect(_on_ok_pressed)
		ok_button.pressed.connect(_on_ok_pressed)

# -------------------------------
# Mostrar resultado (VERSÃO ATUALIZADA)
# -------------------------------
func show_result(success: bool, message: String) -> void:
	is_visible = true
	dialog_box.visible = true
	
	# Agora usamos a 'message' que recebemos do weapon.gd
	label.text = message

	# Bônus: Mudar a cor da caixa para dar um feedback visual
	if success:
		dialog_box.modulate = Color(0.8, 1.0, 0.8) # Verde claro
	else:
		dialog_box.modulate = Color(1.0, 0.8, 0.8) # Vermelho claro

	# Congelar o player (sua lógica original)
	var player = get_tree().current_scene.get_node_or_null("CharacterBody2D")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)

# -------------------------------
# Esconder UI
# -------------------------------
func hide_result() -> void:
	is_visible = false
	dialog_box.visible = false
	dialog_box.modulate = Color.WHITE # Reseta a cor para o padrão

	# Desbloquear o player
	var player = get_tree().current_scene.get_node_or_null("CharacterBody2D")
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)

# -------------------------------
# Botão OK (VERSÃO ATUALIZADA)
# -------------------------------
func _on_ok_pressed() -> void:
	hide_result()
	emit_signal("round_finished")


# -------------------------------
# Input alternativo (sem mudanças)
# -------------------------------
func _input(event: InputEvent) -> void:
	if is_visible and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if ok_button and ok_button.get_global_rect().has_point(event.position):
			_on_ok_pressed()
			
			var vp = get_viewport()
			if vp:
				vp.set_input_as_handled()
