extends Control

@onready var label: Label = $"../CanvasLayer/NinePatchRect/Label"
@onready var dialog_box: NinePatchRect = $"../CanvasLayer/NinePatchRect"
@onready var ok_button: Button = $"../CanvasLayer/NinePatchRect/Button"
@onready var timer_label: Label = $"../CanvasLayer/TimerContainer/TimerLabel"
@onready var game_timer: Timer = $"../CanvasLayer/TimerContainer/Timer"
@onready var audio_open_ui: AudioStreamPlayer = $AudioOpenUI

var has_been_confirmed: bool = false
var _player_ref: CharacterBody2D = null
var _prev_can_move: bool = false
@export var popup_offset: Vector2 = Vector2(0, -120)

func get_all_children_recursive(root: Node) -> Array:
	var all_children = []
	for child in root.get_children():
		all_children.append(child)
		all_children += get_all_children_recursive(child)
	return all_children


func _ready() -> void:
	print("🔹 _ready chamado - preparando UI e alarmes")
	dialog_box.visible = false
	
	dialog_box.custom_minimum_size = Vector2(500, 200)
	dialog_box.size = Vector2(500, 200)
	dialog_box.position = global_position + popup_offset + Vector2(320, 200)
	dialog_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog_box.pivot_offset = dialog_box.size / 2

	if label:
		label.text = ""
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.add_theme_color_override("font_color", Color.BLACK)
		label.add_theme_constant_override("line_spacing", 4) 
		label.add_theme_constant_override("margin_left", 25)
		label.add_theme_constant_override("margin_right", 120) 
		label.add_theme_constant_override("margin_top", 25)
		label.add_theme_constant_override("margin_bottom", 60)
		label.custom_minimum_size = Vector2(300, 120)
		label.size = Vector2(300, 120)

	if ok_button:
		ok_button.custom_minimum_size = Vector2(70, 30)
		ok_button.size = Vector2(70, 30)
		var button_margin = Vector2(20, 20)
		ok_button.position = Vector2(
			button_margin.x,
			dialog_box.size.y - ok_button.size.y - button_margin.y
		)
		ok_button.focus_mode = Control.FOCUS_NONE
		ok_button.mouse_filter = Control.MOUSE_FILTER_STOP
		ok_button.disabled = false
		if not ok_button.pressed.is_connected(_on_ok_pressed):
			ok_button.pressed.connect(_on_ok_pressed)
		
		# 🔤 Texto do botão em múltiplos idiomas
		_update_texts()

	if timer_label:
		timer_label.text = ""
	if game_timer:
		game_timer.stop()

	print("✅ DialogBox pronto")
	await get_tree().process_frame
	_show_only_alarm_light()


# ------------------------------------------------------------
# 🌍 Atualiza textos do idioma atual
# ------------------------------------------------------------
func _update_texts() -> void:
	if ok_button:
		ok_button.text = Languagemanager.t("ok")


# ------------------------------------------------------------
# 💬 Mostra popup com texto no idioma atual
# ------------------------------------------------------------
func show_popup(player: CharacterBody2D = null, meteor_data: Dictionary = {}) -> void:
	print("🔹 show_popup chamado")
	if has_been_confirmed:
		print("⚠️ Popup já confirmado, ignorando")
		return

	var alert_text := ""
	
	if not meteor_data.is_empty():
		var meteor_name = meteor_data.get("name", "Desconhecido")
		var meteor_comp = meteor_data.get("composition", "desconhecida")

		# 🔤 Texto multilíngue
		if Languagemanager.current_language == "pt":
			alert_text = "%s\nAsteroide '%s'\nComposição: %s." % [
				Languagemanager.t("alert"),
				meteor_name,
				meteor_comp.capitalize()
			]
		else:
			alert_text = "%s\nAsteroid '%s'\nComposition: %s." % [
				Languagemanager.t("alert"),
				meteor_name,
				meteor_comp.capitalize()
			]
	else:
		if Languagemanager.current_language == "pt":
			alert_text = "⚠️ Meteoro não identificado\ndetectado! Prepare-se!"
		else:
			alert_text = "⚠️ Unidentified meteor\ndetected! Get ready!"

	label.text = alert_text
	dialog_box.visible = true
	print("🟡 DialogBox visível")

	if audio_open_ui:
		audio_open_ui.play()

	if ok_button:
		ok_button.disabled = false
		await get_tree().process_frame

	if player:
		_player_ref = player
		_prev_can_move = _player_ref.can_move
		_player_ref.can_move = false
		if "velocity" in _player_ref:
			_player_ref.velocity = Vector2.ZERO
		print("🟡 Player bloqueado")


# ------------------------------------------------------------
# 🔒 Fecha popup e restaura controle do player
# ------------------------------------------------------------
func hide_popup() -> void:
	print("🔹 hide_popup chamado")
	if not dialog_box.visible:
		print("⚠️ DialogBox já invisível")
		return
	dialog_box.visible = false
	print("🔵 DialogBox escondido")
	if _player_ref:
		_player_ref.can_move = _prev_can_move
		_player_ref = null
		print("🟢 Player desbloqueado")


# ------------------------------------------------------------
# 🔦 Controle de alarmes
# ------------------------------------------------------------
func _get_alarms() -> Array:
	var alarms = []
	var root = get_tree().current_scene
	for child in get_all_children_recursive(root):
		if child is AnimatedSprite2D and child.name.begins_with("Alarms"):
			alarms.append(child)
			print("🔹 Alarm encontrado:", child.name)
	if alarms.size() == 0:
		print("⚠️ Nenhum Alarm encontrado")
	return alarms


func _show_only_alarm_light() -> void:
	var alarms = _get_alarms()
	for alarm in alarms:
		print("🔴 AlarmLight ligado:", alarm.name)
		alarm.visible = true
		alarm.animation = "AlarmsLight"
		alarm.frame = 0
		alarm.play()


func _show_only_alarm_dark() -> void:
	var alarms = _get_alarms()
	for alarm in alarms:
		print("⚫ AlarmDark ligado:", alarm.name)
		alarm.visible = true
		alarm.animation = "AlarmsDark"
		alarm.frame = 0
		alarm.play()


# ------------------------------------------------------------
# 🚀 BOTÃO OK → ativa todas as armas
# ------------------------------------------------------------
func _on_ok_pressed() -> void:
	print("🔹 Botão OK pressionado")
	if has_been_confirmed:
		print("⚠️ Já confirmado")
		return

	has_been_confirmed = true
	hide_popup()

	var weapons_node = get_tree().current_scene.get_node_or_null("Weapons")
	if weapons_node:
		for weapon in weapons_node.get_children():
			if weapon.has_method("activate_weapon"):
				weapon.activate_weapon()
		print("🟢 Todas as armas ativadas")
	else:
		push_warning("⚠️ Nó 'Weapons' não encontrado na cena")

	_show_only_alarm_dark()

	var game_node = get_tree().current_scene
	if game_node and game_node.has_method("deactivate_alarm_and_start_timer"):
		print("🟢 Chamando deactivate_alarm_and_start_timer")
		game_node.deactivate_alarm_and_start_timer()
	else:
		push_warning("Método deactivate_alarm_and_start_timer não encontrado na cena principal")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if ok_button and ok_button.get_global_rect().has_point(event.position):
			print("🎯 Clique no botão via input global")
			_on_ok_pressed()
			var vp = get_viewport()
			if vp:
				vp.set_input_as_handled()
