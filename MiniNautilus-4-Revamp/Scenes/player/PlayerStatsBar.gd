extends PanelContainer

@onready var player := $"../.."

@onready var stat_hunger := $HBoxContainer/StatHunger
@onready var stat_thirst := $HBoxContainer/StatThirst
@onready var stat_oxygen := $HBoxContainer/StatOxygen

func _process(delta : float) -> void:
	stat_hunger.value = player.hunger
	stat_thirst.value = player.thirst
	stat_oxygen.value = player.oxygen
	
