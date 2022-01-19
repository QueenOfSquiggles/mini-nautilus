extends RayCast

onready var player_hud : Control = $"../../../../HUD"
onready var camera :Camera = get_parent()

onready var player_root := $"../../../.."

const cache_time := 1.0

var cached_colliding_obj : Spatial

var can_interact := false
var can_attack := false

signal on_start_can_attack
signal on_start_can_interact
signal on_end_can_attack
signal on_end_can_interact

func _physics_process(_delta: float) -> void:
	if is_colliding():
		var colliding = get_collider()
		if colliding == cached_colliding_obj:
			return
		if colliding.has_method("get_interact_text"):
			$Timer.stop()
			can_interact = true
			emit_signal("on_start_can_interact")
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
		elif colliding.has_method("on_attacked"):
			$Timer.stop()
			can_attack = true
			emit_signal("on_start_can_attack")
			cached_colliding_obj = colliding as Spatial
		# \/\/ Good debug for when tooltip isn't working
		#else:
		#	print("Object ", colliding, " doesn't have proper method for interaction display")
	else:
		if player_hud.is_tooltip_visible() and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			# only kill tooltips when mouse is captured. In UIs let Tooltip be handled there
			player_hud.hide_tooltip()
		if cached_colliding_obj != null and $Timer.time_left <= 0.0:
			$Timer.start(cache_time)

func interact() -> bool:
	if cached_colliding_obj and is_instance_valid(cached_colliding_obj):
		if cached_colliding_obj.has_method("interact"):
			cached_colliding_obj.interact(player_root)
			return true
	return false

func attack() -> bool:
	if cached_colliding_obj and is_instance_valid(cached_colliding_obj):
		if cached_colliding_obj.has_method("on_attacked"):
			cached_colliding_obj.on_attacked()
			return true
	return false

func _on_Timer_timeout() -> void:
	cached_colliding_obj = null
	if can_attack:
		can_attack = false
		emit_signal("on_end_can_attack")
	if can_interact:
		can_interact = false
		emit_signal("on_end_can_interact")
	$Timer.stop()
