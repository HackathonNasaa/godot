extends Area2D

@onready var popup: Control = get_node("../DialogBox")
@onready var button_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	

func _on_body_entered(body: Node2D):
	# se já foi confirmado no passado, não abre mais
	if popup.has_been_confirmed:
		return

	# Verifica se o corpo que entrou é o jogador
	if body.is_in_group("player"):
		var meteor_data = AsteroidManager.get_random_asteroid()
		popup.show_popup(body, meteor_data)
		
		# Toca a animação "press" do sprite do botão
		if button_sprite:
			button_sprite.play("press")
			print("🎬 Animação 'press' do botão iniciada")

func _on_body_exited(body: Node2D):
	pass
