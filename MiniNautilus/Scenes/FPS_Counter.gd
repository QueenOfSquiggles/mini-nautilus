extends PanelContainer

onready var label :Label = $Label


func _process(delta: float) -> void:
	var fps := Engine.get_frames_per_second()
	label.text = "FPS : %d" % int(fps)
	
