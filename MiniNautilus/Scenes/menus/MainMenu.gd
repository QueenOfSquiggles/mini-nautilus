extends Control

const GAME_SCENE := "res://Scenes/GameWorld.tscn"
const CREDITS_SCENE := "res://Scenes/menus/CreditsMenu.tscn"

func _on_BtnPlay_pressed() -> void:
	SceneManagement.load_scene(GAME_SCENE, true)

func _on_BtnCredits_pressed() -> void:
	SceneManagement.load_scene(CREDITS_SCENE)

func _on_BtnQuit_pressed() -> void:
	get_tree().quit()


