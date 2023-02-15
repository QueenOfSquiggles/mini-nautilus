extends Node
class_name UISlide

enum SlideOptions {
	Left, Right, Top, Bottom
}

@export (SlideOptions) var SlideStyleOption := SlideOptions.Left
@export (String) var InputActionName := "ui_toggle_level_menu"

@onready var target : Control = get_parent()
@onready var tween : Tween = $Tween

signal on_display_complete
signal on_hide_complete

var start_x : float = 0.0
var start_y : float = 0.0
var hiding_anim := false

func _ready() -> void:
	call_deferred("second_tick_init")

func second_tick_init() -> void:
	start_x = target.position.x
	start_y = target.position.y
	get_tree().connect("screen_resized",Callable(self,"on_screen_resize"))
	tween.connect("finished",Callable(self,"_on_tween_completed"))

func on_screen_resize():
	match SlideStyleOption:
		SlideOptions.Right:
			start_x = get_viewport().size.x - target.size.x
		SlideOptions.Bottom:
			start_y = get_viewport().size.y - target.size.y

func _input(event: InputEvent) -> void:
	if InputActionName.is_empty():
		return
	if event.is_action(InputActionName) and not tween.is_active():
		# if input pressed and no tweens are active
		if target.visible:
			hide()
		else:
			display()

func display() -> void:
	target.visible = true
	var start := 0.0
	var end := 0.0
	match (SlideStyleOption):
		SlideOptions.Left:
			start = -target.size.x
			end = 0.0
		SlideOptions.Right:
			start = start_x + target.size.x
			end = start_x
		SlideOptions.Top:
			start = -target.size.y
			end = 0.0
		SlideOptions.Bottom:
			start = start_y + target.size.y
			end = start_y
	_move(start, end)

func hide() -> void:
	var start := 0.0
	var end := 0.0
	match (SlideStyleOption):
		SlideOptions.Left:
			start = 0.0
			end = -target.size.x
		SlideOptions.Right:
			start = start_x
			end = start_x + target.size.x
		SlideOptions.Top:
			start = 0.0
			end = -target.size.y
		SlideOptions.Bottom:
			start = start_y
			end = start_y + target.size.y
	hiding_anim = true
	_move(start, end)

func _move(start : float, end: float) -> void:
	tween.stop_all() # remove_at all
	var prop := "position:x"
	if SlideStyleOption == SlideOptions.Top or SlideStyleOption == SlideOptions.Bottom:
		prop = "position:y"
	tween.interpolate_property(target, prop, start, end, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start() # start

func _on_tween_completed(object: Object, key: NodePath) -> void:
	if hiding_anim:
		hiding_anim = false
		target.visible = false
		emit_signal("on_hide_complete")
	else:
		emit_signal("on_display_complete")
