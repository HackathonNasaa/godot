# asteroid_manager.gd
extends Node

signal data_loaded
var all_asteroids: Array = []
var http_request: HTTPRequest

const ASTEROID_API_URL = "https://meteors-ten.vercel.app/api/asteroid"

func _ready():
	# Cria o nó HTTPRequest e adiciona como filho
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# Inicia o download dos dados assim que o jogo começa!
	fetch_asteroid_data()

func fetch_asteroid_data():
	# A verificação para não baixar de novo continua útil
	if not all_asteroids.is_empty():
		emit_signal("data_loaded") # Se os dados já existem, emite o sinal imediatamente
		return 
	
	print("Iniciando download dos dados dos asteroides...")
	http_request.request(ASTEROID_API_URL)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		var json_result = JSON.parse_string(body.get_string_from_utf8())
		if json_result is Array and not json_result.is_empty():
			all_asteroids = json_result
			print("Dados dos asteroides carregados com sucesso!")
			emit_signal("data_loaded")
		else:
			print("Falha ao processar os dados dos asteroides (JSON inválido).")
	else:
		print("Falha ao baixar os dados dos asteroides. Código: ", response_code)

func get_random_asteroid() -> Dictionary:
	if all_asteroids.is_empty():
		return {}
	var random_index = randi() % all_asteroids.size()
	return all_asteroids[random_index]
