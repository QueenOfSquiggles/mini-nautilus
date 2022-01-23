extends Spatial



func _ready() -> void:
	# call it deferred so the level can load everything in first
	# not the most efficient method, but it works
	if not SaveData.does_save_data_exist():
		print("No save data found! playing opening cutscene")
		GM.trigger_start_cutscene()
	yield(VisualServer, "frame_post_draw")
	SaveData.load_save_data()
