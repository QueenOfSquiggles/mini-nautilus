extends Control

const MAIN_MENU := "res://Scenes/menus/MainMenu.tscn"

func _on_BtnMainMenu_pressed() -> void:
	SceneManagement.load_scene(MAIN_MENU)
