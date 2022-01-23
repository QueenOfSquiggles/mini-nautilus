extends Control


const MAIN_MENU := "res://Scenes/menus/MainMenu.tscn"
const GAME_WORLD := "res://Scenes/GameWorld.tscn"


func _on_BtnReloadSave_pressed() -> void:
	SceneManagement.load_scene(GAME_WORLD, true)


func _on_BtnMainMenu_pressed() -> void:
	SceneManagement.load_scene(MAIN_MENU)
