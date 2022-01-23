extends "res://Scenes/creatures/fish/Fish.gd"

onready var idle_sound_timer := $IdleSoundTimer
onready var sound_lib : SoundLib = $SoundLib_Chonkus

func _ready() -> void:
	randomize()


func _on_IdleSoundTimer_timeout() -> void:
	sound_lib.play()
	idle_sound_timer.start(5.0 + randf() * 5.0)
