extends Node

var player_node : KinematicBody
var player_hud : Control

var debug_draw : DebugDraw

signal on_player_setup

func set_up_debug_draw(draw : DebugDraw) -> void:
	debug_draw = draw

func set_up_player(player : KinematicBody) -> void:
	self.player_node = player
	player_hud = player.get_node("HUD")
	emit_signal("on_player_setup")

