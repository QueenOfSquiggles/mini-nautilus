extends Node3D


func end_cutscene() -> void:
	GM.finish_cutscene()
	queue_free()
