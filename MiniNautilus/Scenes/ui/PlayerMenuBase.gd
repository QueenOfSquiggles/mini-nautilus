extends Node

var read_inputs := false

func _ready() -> void:
	call_deferred("set", "read_inputs", true)

func _on_MenuBase_tree_entered() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GM.player_hud.visible = false

func _on_MenuBase_tree_exiting() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GM.player_hud.visible = true

func _input(event: InputEvent) -> void:
	if not read_inputs:
		return
	if event.is_action_pressed("open_inventory") or event.is_action("ui_cancel"):
		queue_free()
