extends Node2D

# Variáveis públicas para configurar o ícone no momento da criação.
# O script do trigger vai preencher estas variáveis.
var icon_texture: Texture2D
var display_text: String

# Chamado uma vez quando o nó entra na árvore da cena para a configuração inicial.
func _ready():
	# Configura a textura da imagem e o texto do label com os dados recebidos.
	$Sprite2D.texture = icon_texture
	$Label.text = display_text
	
	# Inicia a animação de fade-in para o ícone aparecer suavemente.
	self.modulate.a = 0
	var tween_in = create_tween()
	tween_in.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)
	
	# Dispara o timer que determinará o tempo de vida do ícone.
	$Timer.start()

# Chamado pelo sinal "timeout" do Timer quando o tempo de vida do ícone acaba.
func fade_out_and_destroy():
	# Executa uma animação de fade-out para o ícone desaparecer suavemente.
	var tween_out = create_tween()
	tween_out.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	
	# Espera a animação de fade-out terminar antes de remover o ícone do jogo.
	await tween_out.finished
	queue_free()
	
		# essas duas coisas fazem a mesma coisa
		# $Sprite2D.texture = icon_texture
		# get_node("Sprite2D").texture = icon_texture
