extends "res://Scenes/ui/PlayerMenuBase.gd"
"""
Radio tower costs resources to 1
"""

@export (Resource) var copper_item : Resource
@export (Resource) var plastics_item : Resource

@export (Resource) var consume_copper_exported : Resource
@export (Resource) var consume_plastics_exported : Resource

@onready var consume_copper := consume_copper_exported as Recipe
@onready var consume_plastics := consume_plastics_exported as Recipe

const PLASTICS_REQUIRED := 20
const COPPER_REQUIRED := 30

var copper :int = 0
var plastics :int = 0

@onready var progress_copper := $"PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/Requirements/CopperRequirement/VBoxContainer/ProgressBar"

@onready var progress_plastics := $"PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/Requirements/PlasticRequirement/VBoxContainer/ProgressBar"

@onready var save_progress := $"PersistentProperties"

signal on_values_changed

func _ready() -> void:
	progress_copper.min_value = 0
	progress_copper.max_value = COPPER_REQUIRED
	progress_plastics.min_value = 0
	progress_plastics.max_value = PLASTICS_REQUIRED
	save_progress.load_data()
	_refresh_display()

func _refresh_display() -> void:
	progress_copper.value = copper
	progress_plastics.value = plastics
	emit_signal("on_values_changed")
	print("Radio Tower Status : ", copper, "/", COPPER_REQUIRED, "copper; ", plastics, "/", PLASTICS_REQUIRED, " plastics")
	save_progress.save_data()
	if copper >= COPPER_REQUIRED and plastics >= PLASTICS_REQUIRED:
		on_tower_completed()

func on_tower_completed() -> void:
	GM.trigger_win_condition()
	queue_free()

func _on_BtnAddCopper_pressed() -> void:
	if consume_copper.do_craft(_player_inv()):
		copper += 1
		_refresh_display()

func _on_BtnRemoveCopper_pressed() -> void:
	if copper > 0:
		copper -= 1
		_player_inv().add_item(copper_item)
		_refresh_display()

func _on_BtnAddPlastics_pressed() -> void:
	if consume_plastics.do_craft(_player_inv()):
		plastics += 1
		_refresh_display()

func _on_BtnRemovePlastics_pressed() -> void:
	if plastics > 0:
		plastics -= 1
		_player_inv().add_item(plastics_item)
		_refresh_display()

func _player_inv() -> ItemsContainer:
	return GM.player_node.inventory as ItemsContainer
