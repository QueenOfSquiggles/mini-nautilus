extends RayCast

onready var player_hud : Control = $"../../../../HUD"
onready var camera :Camera = get_parent()

var cached_colliding_obj : Spatial

func _physics_process(_delta: float) -> void:
	if is_colliding():
		var colliding = get_collider()
		if colliding.has_method("get_interact_text"):
			var text : String = colliding.get_interact_text()
			var pos := Vector2()
			if colliding is Spatial:
				cached_colliding_obj = colliding as Spatial
				var obj_pos := cached_colliding_obj.global_transform.origin
				pos = camera.unproject_position(obj_pos)
				#print("Handling spatial interaction")
			if player_hud.is_tooltip_visible():
				player_hud.set_tooltip_pos(pos)
			else:
				player_hud.create_tooltip(pos, text)
		# \/\/ Good debug for when tooltip isn't working
		#else:
		#	print("Object ", colliding, " doesn't have proper method for interaction display")
	else:
		if player_hud.is_tooltip_visible():
			player_hud.hide_tooltip()
		if cached_colliding_obj:
			cached_colliding_obj = null

func interact() -> bool:
	if cached_colliding_obj:
		if cached_colliding_obj.has_method("interact"):
			cached_colliding_obj.interact()
			return true
	return false
