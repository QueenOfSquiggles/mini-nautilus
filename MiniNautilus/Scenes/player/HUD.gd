extends Control

onready var tooltip := $Tooltip
onready var tooltip_label := $Tooltip/Label

func create_tooltip(pos : Vector2, text : String) -> void:
	set_tooltip_text(text)
	set_tooltip_pos(pos)
	show_tooltip()

func set_tooltip_text(text : String) -> void:
	tooltip_label.text = text
	
func set_tooltip_pos(pos : Vector2)-> void:
	tooltip.rect_position = pos	

func show_tooltip() -> void:
	tooltip.visible = true

func hide_tooltip() -> void:
	tooltip.visible = false

func is_tooltip_visible() -> bool:
	return tooltip.visible
