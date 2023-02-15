extends Node

var player_node : KinematicBody
var player_hud : Control

var debug_draw : DebugDraw

signal on_player_setup

const GAME_OVER_SCREEN := "res://Scenes/menus/GameOverScreen.tscn"
const WIN_CUTSCENE := "res://Scenes/animations/end_cutscene.tscn"
const GAME_START_CUTSCENE := "res://Scenes/animations/opening_cutscene.tscn"

func _ready() -> void:
	self.pause_mode = Node.PAUSE_MODE_PROCESS

func set_up_debug_draw(draw : DebugDraw) -> void:
	debug_draw = draw

func set_up_player(player : KinematicBody) -> void:
	self.player_node = player
	player_hud = player.get_node("HUD")
	emit_signal("on_player_setup")

func trigger_game_over() -> void:
	_release_mouse()
	SceneManagement.load_scene(GAME_OVER_SCREEN)

func trigger_win_condition() -> void:
	_play_cutscene(WIN_CUTSCENE)

func trigger_start_cutscene() -> void:
	_play_cutscene(GAME_START_CUTSCENE)

func _play_cutscene(path : String) -> void:
	yield(VisualServer, "frame_post_draw")
	var cutscene :Node= load(path).instance()
	get_tree().current_scene.add_child(cutscene)
	cutscene.pause_mode = Node.PAUSE_MODE_PROCESS
	player_hud.visible = false
	get_tree().paused = true

func _release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func finish_cutscene() -> void:
	if is_instance_valid(player_hud):
		player_hud.visible = true
	get_tree().paused = false
