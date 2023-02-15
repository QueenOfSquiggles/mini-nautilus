extends PanelContainer

@onready var par := get_parent()

func _on_mouse_entered() -> void:
	if par.item_name.is_empty():
		return
	#print("Mouse entered slot with %s" % par.item_name)
	if par.texture_rect.texture and GM.player_hud:
		GM.player_hud.create_tooltip(par.position, "%s\n%s" % [par.item_name, par.item_desc])

func _on_mouse_exited() -> void:
	if par.item_name.is_empty():
		return
	#print("Mouse exited slot with %s" % par.item_name)
	if par.texture_rect.texture and GM.player_hud:
		GM.player_hud.hide_tooltip()
