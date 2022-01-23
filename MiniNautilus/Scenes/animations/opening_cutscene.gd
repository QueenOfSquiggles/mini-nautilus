extends Spatial


func end_cutscene() -> void:
	GM.finish_cutscene()
	queue_free()
