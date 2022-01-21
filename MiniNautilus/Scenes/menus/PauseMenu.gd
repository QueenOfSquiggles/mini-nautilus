extends Node



enum State {
	NORMAL=0, OPTIONS=1
}

var current_state :int = State.NORMAL # setup invalid value so ready func calls the enter value

onready var OptionsMenuSlider : UISlide = $OptionsMenu/UiSlide
onready var center_menu :Control = $CenterMenu

var accept_inputs := false

func _ready() -> void:
	get_tree().paused = true
	OptionsMenuSlider.hide()
	set_state(State.NORMAL)
	if GM.player_hud:
		GM.player_hud.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# after 0.1 seconds set the accept input val to true so we can take inputs
	get_tree().create_timer(0.1).connect("timeout", self, "set", ["accept_inputs", true])
	
func set_state(state : int) -> void:
	match(state):
		State.NORMAL:
			on_enter_normal()
		State.OPTIONS:
			on_enter_options()
	current_state = state


func on_enter_normal() -> void:
	OptionsMenuSlider.hide()
	center_menu.visible = true
	
func on_enter_options() -> void:
	OptionsMenuSlider.display()
	#(OptionsMenuSlider.get_parent() as Control).visible = true
	center_menu.visible = false

func _on_OptionsMenu_on_return_button_pressed() -> void:
	set_state(State.NORMAL)

func _on_BtnSave_pressed() -> void:
	SaveData.save_data()

func _on_BtnOptions_pressed() -> void:
	set_state(State.OPTIONS)

func _on_BtnMainMenu_pressed() -> void:
	leave_pause()
	SceneManagement.load_scene("res://Scenes/menus/MainMenu.tscn", true)

func _on_BtnReturn_pressed() -> void:
	if GM.player_hud:
		GM.player_hud.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	leave_pause()

func leave_pause() -> void:
	get_tree().paused = false
	queue_free()
	

func _input(event: InputEvent) -> void:
	if not accept_inputs:
		return
	if event.is_action_pressed("ui_cancel"):
		get_tree().create_timer(0.1).connect("timeout", self, "_on_BtnReturn_pressed")

func _on_BtnLoadSave_pressed() -> void:
	SaveData.load_save_data()


func _on_BtnQuitDesktop_pressed() -> void:
	SaveData.save_data()
	get_tree().quit()
