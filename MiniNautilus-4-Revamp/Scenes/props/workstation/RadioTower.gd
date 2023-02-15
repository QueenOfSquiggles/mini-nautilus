extends "res://Scenes/props/resourcess/BasicInteractor.gd"

@export (PackedScene) var workstation_menu : PackedScene

func interact(interacted_with) -> void:
	var inst := workstation_menu.instantiate()
	get_tree().current_scene.add_child(inst)
