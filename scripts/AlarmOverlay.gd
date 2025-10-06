extends ColorRect

var blinking := false
@onready var siren_audio: AudioStreamPlayer = $SirenAudio  # ou get_node("SirenAudio")

func _ready() -> void:
	visible = false
	color = Color(1, 0, 0, 0.6)  # Vermelho mais escuro (mais opaco)
	modulate = Color(1, 1, 1, 0) # começa invisível

	# Garante que o som não comece sozinho
	if siren_audio:
		siren_audio.stop()

func set_active(active: bool) -> void:
	blinking = active
	if active:
		visible = true
		# Iniciar sirene
		if siren_audio and not siren_audio.playing:
			siren_audio.play()
		start_blinking()
	else:
		visible = false
		modulate = Color(1, 1, 1, 0)
		# Parar sirene
		if siren_audio and siren_audio.playing:
			siren_audio.stop()

func start_blinking() -> void:
	while blinking:
		var tween_in = create_tween()
		tween_in.tween_property(self, "modulate:a", 0.6, 0.6)
		await tween_in.finished

		if not blinking:
			break

		var tween_out = create_tween()
		tween_out.tween_property(self, "modulate:a", 0.0, 0.6)
		await tween_out.finished
