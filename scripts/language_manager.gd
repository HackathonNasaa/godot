extends Node
class_name LanguageManager

signal language_changed

var current_language: String = "en"

var translations := {
	"pt": {
		"play": "Jogar",
		"language": "Idioma",
		"music": "Música",
		"portuguese": "Português",
		"english": "Inglês",
		"ok": "OK",
		"alert": "⚠️ Alerta de colisão!",
		"victory": "🎉 Você acertou o meteoro! Vitória!",
		"fail": "💥 Falhou! O meteoro atingiu a Terra!",
		"unknown_meteor": "⚠️ Meteoro não identificado\ndetectado! Prepare-se!",
		"composition": "Composição"
	},
	"en": {
		"play": "Play",
		"language": "Language",
		"music": "Music",
		"portuguese": "Portuguese",
		"english": "English",
		"ok": "OK",
		"alert": "⚠️ Collision Alert!",
		"victory": "🎉 You hit the meteor! Victory!",
		"fail": "💥 You missed! The meteor hit Earth!",
		"unknown_meteor": "⚠️ Unidentified meteor\ndetected! Get ready!",
		"composition": "Composition"
	}
}


func set_language(lang: String) -> void:
	if translations.has(lang):
		current_language = lang
		print("🌐 Idioma alterado para:", lang)
		emit_signal("language_changed")
	else:
		push_warning("Idioma não suportado: %s" % lang)


func t(key: String) -> String:
	if translations.has(current_language) and translations[current_language].has(key):
		return translations[current_language][key]
	return key
