extends Control

signal on_return_button_pressed

"""
Options menu. Most crucial elements taken from Calinou's repo : https://github.com/Calinou/godot-sponza/blob/master/scripts/settings_gui.gd
"""

const managed_settings := {
	"environment" : {
		"fog_enabled" : {
			"keys" : ["Enabled", "Disabled (faster but with visual artifacts)"],
			"values" : [true, false]
		},
		"glow_enabled": {
			"keys" : ["Enabled", "Disabled"],
			"values" : [true, false]
		},
		"ss_reflections_enabled": {
			"keys" : ["Enabled", "Disabled"],
			"values" : [true, false]
		},
		"ssao_enabled": {
			"keys" : ["Enabled", "Disabled"],
			"values" : [true, false]
		},
		"ssao_blur":{
			"keys" : ["Disabled","Fast","Balanced","Pretty"],
			"values" : [
				Environment.SSAO_BLUR_DISABLED,
				Environment.SSAO_BLUR_1x1,
				Environment.SSAO_BLUR_2x2,
				Environment.SSAO_BLUR_3x3
			],
		},
		"ssao_quality": {
			"keys" : [
				"Fast", 
				"Balanced", 
				"Pretty"
			],
			"values" : [
				Environment.SSAO_QUALITY_LOW,
				Environment.SSAO_QUALITY_MEDIUM,
				Environment.SSAO_QUALITY_HIGH,
			],
		},
		"tonemap_mode" : {
			"keys" : [
				"Linear", 
				"Reinhardt", 
				"Filmic", 
				"ACES", 
				"ACES (Fitted)"
			],
			"values" : [
				Environment.TONE_MAPPER_LINEAR,
				Environment.TONE_MAPPER_REINHARDT,
				Environment.TONE_MAPPER_FILMIC,
				Environment.TONE_MAPPER_ACES,
				Environment.TONE_MAPPER_ACES_FITTED,	
			],
		},
		"tonemap_exposure" : {
			"keys" : ["0.4","0.6","0.8","1.0 (Normal)","1.2","1.4","1.6","1.8"],
			"values" : [0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8],
		},
	}
}
const default_settings := {
	"environment" : {
		"glow_enabled":  true,
		"ss_reflections_enabled": false,
		"ssao_enabled": false,
		"ssao_blur": Environment.SSAO_BLUR_1x1,
		"ssao_quality": Environment.SSAO_QUALITY_MEDIUM,
		"tonemap_mode" : Environment.TONE_MAPPER_ACES_FITTED,
		"tonemap_exposure" :  1.0,
	}
}

var queued_settings := {}

const SAVE_SUFFIX := "_gfx_options"

func _ready() -> void:
	var temp = SaveData.load_custom_data(SAVE_SUFFIX)
	queued_settings = temp as Dictionary
	if queued_settings.empty():
		queued_settings = default_settings.duplicate(true)
		save_settings()
	propogate_changes()
	connect("tree_exiting", self, "save_settings")
	SaveData.connect("on_saving", self, "save_settings")
	create_menu_items()

func save_settings() -> void:
	SaveData.save_custom_data(SAVE_SUFFIX, queued_settings)	



func create_menu_items() -> void:
	var root := $VBoxContainer/SettingsPanel/VBoxContainer
#	var fog := create_env_setting_dropdown("fog_enabled")
#	root.add_child(fog)
	for entry in managed_settings["environment"].keys():
		var dropmenu = create_env_setting_dropdown(entry)
		root.add_child(dropmenu)

func create_env_setting_dropdown(key : String) -> Control:
	var split := HBoxContainer.new()
	var label := Label.new()
	var dropmenu = OptionButton.new()
	split.add_child(label)
	split.add_child(dropmenu)
	label.text = key
	split.alignment = HBoxContainer.ALIGN_CENTER
	split.size_flags_horizontal = SIZE_EXPAND
	
	var dict := managed_settings["environment"] as Dictionary
	dict = dict[key] as Dictionary
	var names := dict["keys"] as Array
	for option in names:
		dropmenu.add_item(option)
	dropmenu.connect("item_selected", self, "on_option_selected", [key])
	
	var prop_value = queued_settings["environment"][key]
	var index = (dict["values"] as Array).find(prop_value)
	dropmenu.select(index)
	return split
		
		
func on_option_selected(index : int, property : String) -> void:
	var value = managed_settings["environment"][property]["values"][index]
	queued_settings["environment"][property] = value
	propogate_changes()

func propogate_changes() -> void:
	if not try_set_current_environment():
		# this effectively never runs
		try_change_resource_file()

func try_set_current_environment() -> bool:
	var env :WorldEnvironment = get_tree().current_scene.find_node("WorldEnvironment") as WorldEnvironment
	if not env:
		print("failed to find world environment")
		return false
	apply_settings(env.environment)
	return true

func try_change_resource_file() -> void:
	var env_res := load("res://world_environments/in_game_env.tres") as Environment
	apply_settings(env_res)
	# did the world environment change?	

func apply_settings(env : Environment) -> void:
	var env_settings :Dictionary = queued_settings["environment"] if queued_settings.has("environment") else {}
	for entry in env_settings.keys():
		env.set_indexed(entry, env_settings[entry])

func _on_BtnReturn_pressed() -> void:
	save_settings()
	emit_signal("on_return_button_pressed")
