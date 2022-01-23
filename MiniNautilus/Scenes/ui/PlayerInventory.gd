extends "res://Scenes/ui/PlayerMenuBase.gd"

export (Resource) var recipe_eat_e : Resource
export (Resource) var recipe_drink_e : Resource
export (Resource) var recipe_water_bottle_e : Resource


const EAT_HUNGER_VALUE := 0.25
const DRINK_THIRST_VALUE := 0.25

onready var recipe_eat := recipe_eat_e as Recipe
onready var recipe_drink := recipe_drink_e as Recipe
onready var recipe_water_bottle := recipe_water_bottle_e as Recipe

onready var stat_hunger := $"PanelContainer/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer2/StatHunger/HBoxContainer/ProgressBar"

onready var stat_thirst := $"PanelContainer/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer2/StatThirst/HBoxContainer/ProgressBar"

onready var stat_oxygen := $"PanelContainer/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer2/StatOxygen/HBoxContainer/ProgressBar"


func _ready() -> void:
	stat_hunger.value = GM.player_node.hunger
	stat_thirst.value = GM.player_node.thirst
	stat_oxygen.value = GM.player_node.oxygen


func _on_BtnEat_pressed() -> void:
	if does_player_have(recipe_eat):
		print("Player ate!")
		GM.player_node.hunger = min(GM.player_node.hunger + EAT_HUNGER_VALUE, 1.0)
		stat_hunger.value = GM.player_node.hunger
	else:
		print("Player is unable to eat")

func _on_BtnDrink_pressed() -> void:
	if does_player_have(recipe_drink):
		print("Player drank!")
		GM.player_node.thirst = min(GM.player_node.thirst + DRINK_THIRST_VALUE, 1.0)
		stat_thirst.value = GM.player_node.thirst
	else:
		print("Player is unable to drink")

func _on_BtnCraftWater_pressed() -> void:
	if does_player_have(recipe_water_bottle):
		print("Player made a water bottle!")
	else:
		print("Player is unable to craft bottle5")

func does_player_have(recipe : Recipe) -> bool:
	var inventory :ItemsContainer = GM.player_node.inventory
	assert(inventory)
	return recipe.do_craft(inventory)
