extends Spatial

export (PackedScene) var FishPacked : PackedScene
export (int) var desired_number := 8
export (float) var refresh_time_spawning := 2.0
export (float) var refresh_time_idle := 8.0
export (bool) var only_spawn_off_screen := true 

onready var owned_root := $owned

var is_on_screen := false

func _ready() -> void:
	$Timer.start(0.1)

func _on_screen_entered() -> void:
	is_on_screen = true

func _on_screen_exited() -> void:
	is_on_screen = false

func _on_Timer_timeout() -> void:
	var time := refresh_time_idle if check_can_add() else refresh_time_spawning
	$Timer.start(time)

func check_can_add() -> bool:
	var screen_spawn_flag :bool = true if (not only_spawn_off_screen) else (not is_on_screen)
	if owned_root.get_child_count() < desired_number and screen_spawn_flag:
		add_new_owned()
		return false
	return true

func add_new_owned() -> void:
	var own :Spatial = FishPacked.instance()
	owned_root.add_child(own)
	own.global_transform.origin = global_transform.origin
	#print("Spawnging a new fish : ", own.name)
