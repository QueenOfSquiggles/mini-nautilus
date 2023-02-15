extends Control
class_name DebugDraw

const DISABLED := true

var draw_queue := {}

func _ready() -> void:
	GM.set_up_debug_draw(self)
	set_process(false)
	
func _process(_delta: float) -> void:
	if draw_queue.is_empty():
		set_process(false)
	#update()s

func _draw() -> void:
	for key in draw_queue.keys():
		var entry := draw_queue[key] as Dictionary
		draw_line(entry.start,entry.end,entry.color,entry.size)
	#print("Drew %s debug line entries in this frame" % draw_queue.size())
	draw_queue.clear() # remove_at drawing queue

func draw_line_3d(start : Vector3, end : Vector3, line_size : float, color : Color) -> void:
	if DISABLED:
		return
	var cam := get_viewport().get_camera_3d() as Camera3D

	var posA := cam.unproject_position(start)
	var posB := cam.unproject_position(end)
	var entry := {
		"start" : posA,
		"end" : posB,
		"color" : color,
		"size" : line_size,
		"aa" : true		
	}
	# using the hash should theoretically prevent multiple calls for the same line?
	draw_queue[entry.hash()] = entry
	set_process(true)

