extends Spatial



func _ready() -> void:
	# call it deferred so the level can load everything in first
	# not the most efficient method, but it works
	print("loading level")
	SaveData.connect("load_stage_signal", self, "test")
	
	SaveData.load_save_data()
	
func test() -> void:
	print("DID THE THING!")
