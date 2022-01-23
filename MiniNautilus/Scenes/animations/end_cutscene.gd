extends Spatial


func end_cutscene() -> void:
	GM.finish_cutscene()
	queue_free()
	SceneManagement.load_scene("res://Scenes/menus/MainMenu.tscn")
