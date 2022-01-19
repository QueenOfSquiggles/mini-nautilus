extends Spatial



func _ready() -> void:
	print("Scene loading data")
	SaveData.load_save_data()

func _input(event: InputEvent) -> void:
	if event.is_action("ui_home"):
		print("Scene saving data")
		SaveData.save_data()
		
