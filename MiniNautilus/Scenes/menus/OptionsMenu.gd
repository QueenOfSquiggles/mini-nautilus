extends Control

signal on_return_button_pressed

"""
Options menu. Most crucial elements taken from Calinou's repo : https://github.com/Calinou/godot-sponza/blob/master/scripts/settings_gui.gd
"""

const managed_settings := {
	"environment" : {
		"glow_enabled": {
			"Enabled" : true,
			"Disabled" : false
		},
		"ss_reflections_enabled": {
			"Enabled" : true,
			"Disabled" : false
		},
		"ssao_enabled": {
			"Enabled" : true,
			"Disabled" : false
		},
		"ssao_blur":{
			"Disabled" : Environment.SSAO_BLUR_DISABLED,
			"Fast - 1x1" : Environment.SSAO_BLUR_1x1,
			"Balanced - 2x2" : Environment.SSAO_BLUR_2x2,
			"Pretty 3x3" : Environment.SSAO_BLUR_3x3			
		},
		"ssao_quality": {
			"Fast" : Environment.SSAO_QUALITY_LOW,
			"Balanced" : Environment.SSAO_QUALITY_MEDIUM,
			"Pretty" : Environment.SSAO_QUALITY_HIGH,
		},
		"tonemap_mode" : {
			"Linear" : Environment.TONE_MAPPER_LINEAR,
			"Reinhardt" : Environment.TONE_MAPPER_REINHARDT,
			"Filmic" : Environment.TONE_MAPPER_FILMIC,
			"ACES" : Environment.TONE_MAPPER_ACES,
			"ACES Fitted" : Environment.TONE_MAPPER_ACES_FITTED,
		},
		"tonemap_exposure" : {
			"Default (0.4)" : 0.4,
			"Default (0.6)" : 0.6,
			"Default (0.8)" : 0.8,
			"Default (1.0)" : 1.0,
			"Default (1.2)" : 1.2,
			"Default (1.4)" : 1.4,
			"Default (1.6)" : 1.6,
			"Default (1.8)" : 1.8,
		},
	}
}
const default_settings := {
	"environment" : {
		"glow_enabled":  true,
		"ss_reflections_enabled": true,
		"ssao_enabled": true,
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
	print("Loaded GFX settings : ", queued_settings)
	# TODO : how can I apply saved settings without using the pause menu?
	propogate_changes()
	connect("tree_exiting", self, "save_settings")
	SaveData.connect("on_saving", self, "save_settings")
	
func save_settings() -> void:
	print("Saving GFX settings : ", queued_settings)
	SaveData.save_custom_data(SAVE_SUFFIX, queued_settings)	

func _on_CheckButton_toggled(button_pressed: bool) -> void:
	if not queued_settings.has("environment"):
		queued_settings["environment"] = {}
	queued_settings["environment"]["fog_enabled"] = button_pressed
	propogate_changes()

func propogate_changes() -> void:
	print("Applying graphic settings : ", queued_settings)
	if not try_set_current_environment():
		print("failed to edit a currently loaded environment. attempting to edit the resource file?")
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
		print("Setting environment var [%s] to [%s]" % [entry, env_settings[entry]])
		env.set_indexed(entry, env_settings[entry])
	#env_settings.clear()


func _on_BtnReturn_pressed() -> void:
	save_settings()
	emit_signal("on_return_button_pressed")
