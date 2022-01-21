extends Spatial



func _ready() -> void:
	# call it deferred so the level can load everything in first
	# not the most efficient method, but it works	
	SaveData.load_save_data()
