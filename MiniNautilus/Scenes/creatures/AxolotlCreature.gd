extends "res://Scenes/creatures/fish/Fish.gd"

export var PlayerChaseDistance := 60.0

var chase_obj : Spatial
var chasing_player := false

onready var sound_lib :SoundLib= $SoundLib_Flubbernubs

onready var idle_sound_timer :Timer = $IdleSoundTimer

func _ready() -> void:
	idle_sound_timer.start(5.0 + randf() * 5.0)
 
func on_attacked() -> void:
	pass # do nothing. No killing Lt. Flubbernubs
	
func _physics_process(delta: float) -> void:
	#._physics_process(delta)
	if TimeSlice.current_physics(time_slice_id_physics):
		check_player()
		#if chasing_player:
		#	create_new_poi()
		if chase_obj and is_instance_valid(chase_obj):
			poi = chase_obj.global_transform.origin
		else:
			create_new_poi()

func check_player() -> void:
	var delta = global_transform.origin - GM.player_node.global_transform.origin
	var distance :float= delta.length()
	if chasing_player and distance > PlayerChaseDistance:
		on_end_chase()
	elif not chasing_player and distance < PlayerChaseDistance:
		on_begin_chase()

func create_new_poi() -> void:
	# as Lt. flubbernubs, as consider the player as a POI
	if chasing_player:
		chase_obj = GM.player_node
	else:
		var fishes :Array =  get_tree().get_nodes_in_group("fish")
		if fishes.empty():
			return
		var close_fishes := []
		for f in fishes:
			var fish := f as Spatial
			var delta := global_transform.origin - fish.global_transform.origin
			var distance = delta.length()
			if distance < PlayerChaseDistance:
				close_fishes.append(fish)
		if close_fishes.empty():
			chase_obj = fishes[randi() % fishes.size()]
		else:
			chase_obj = close_fishes[randi() % close_fishes.size()]

func on_begin_chase() -> void:
	chasing_player = true
	create_new_poi()
	play_sound("start_chase")
	print("Starting chase")

func on_end_chase() -> void:
	chasing_player = false
	create_new_poi()
	play_sound("end_chase")
	print("Ending chase")

func _on_KillZone_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("ATE THE PLAYER!!!!")
		GM.trigger_game_over()
	if body.is_in_group("fish") or body.has_method("on_attacked"):
		# fish was caught
		body.on_attacked()
		play_sound("eat")
		create_new_poi()

func play_sound(name : String) -> void:
	sound_lib.play(name)
	idle_sound_timer.start(5.0 + randf() * 5.0)

func _on_IdleSoundTimer_timeout() -> void:
	play_sound("idle")
