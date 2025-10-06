# MusicManager.gd
extends Node

var music_stream = preload("res://sprites/Soundeffects/soundtrack_miguel.ogg")
var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	if music_stream:
		music_player.stream = music_stream

		# Ativa loop na stream (se for possível)
		if music_player.stream is AudioStream:
			music_player.stream.loop = true

		music_player.play()
