extends Node

#==============================================================================
# LÓGICA SIMPLIFICADA: ARMA VS COMPOSIÇÃO
#==============================================================================

const WEAPON_MATCH = {
	"carbonaceous": "laser",
	"rocky": "impactor_cinetico", 
	"metallic": "canhao_magnetico"
}

# Verifica se a arma usada é a correta para a composição do asteroide
func is_correct_weapon(asteroid_composition: String, weapon_type: String) -> bool:
	var composition = asteroid_composition.to_lower()
	if WEAPON_MATCH.has(composition):
		return WEAPON_MATCH[composition] == weapon_type
	return false

# Função principal que determina se o jogador venceu
func check_win_condition(asteroid_composition: String, weapon_type: String) -> bool:
	return is_correct_weapon(asteroid_composition, weapon_type)
