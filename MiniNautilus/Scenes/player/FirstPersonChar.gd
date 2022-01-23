extends KinematicBody

#export (Resource) var inventory : Resource

const CUSTOM_DATA_SUFFIX := "_player_data"

const PAUSE_MENU_SCENE := "res://Scenes/menus/PauseMenu.tscn"
const INVENTORY_MENU_SCENE := "res://Scenes/ui/PlayerInventory.tscn"

const GRAVTIY := -24.8
var vel := Vector3()
const MAX_SPEED := 10.0
const ACCEL := 4.5

var dir := Vector3()

const DEACCEL_MOVING := 4.0
const DEACCEL_IDLE := 2.0

var camera : Camera
var rotation_helper : Spatial
var has_movement_input := false

var MOUSE_SENSITIVITY := 0.3

var inventory : ItemsContainer

var hunger := 1.0
var thirst := 1.0
var oxygen := 1.0

var hunger_rate := 0.001
var thirst_rate := 0.002
var oxygen_rate := 0.001

onready var raycast : RayCast = $"rotation_helper/model/Camera/RayCast"

onready var anim : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	inventory = ItemsContainer.new(50, "PlayerInventory")
	camera = $rotation_helper/model/Camera
	rotation_helper = $rotation_helper
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GM.set_up_player(self)
	SaveData.connect("on_saving", self, "save_data")
	SaveData.connect("on_loading", self, "load_data")
	self.connect("tree_exiting", self, "save_data")
	assert(inventory)

func _process(delta: float) -> void:
	hunger -= hunger_rate * delta
	thirst -= thirst_rate * delta
	oxygen -= oxygen_rate * delta
	if hunger < 0:
		GM.trigger_game_over()
		call_deferred("set", "hunger", 1.0)
	if thirst < 0:
		GM.trigger_game_over()
		call_deferred("set", "thirst", 1.0)
	if oxygen < 0:
		GM.trigger_game_over()
		call_deferred("set", "oxygen", 1.0)
	
func _physics_process(delta: float) -> void:
	process_input(delta)
	process_movement(delta)

func process_input(_delta : float) -> void:
	dir = Vector3()
	if Input.is_action_pressed("screenshot_fuckup_prevention"):
		return
	var camxform :Transform = camera.global_transform
	var input_vec := Vector2() # cam-aligned movement
	var global_up_down := 0.0 # global rise/fall
	
	# using get_axis means a gamepad will gradiate automagically :3
	input_vec.x = Input.get_axis("move_left", "move_right")
	input_vec.y = Input.get_axis("move_back", "move_forwards")
	global_up_down = Input.get_axis("move_global_down", "move_global_up")

	has_movement_input = (input_vec.length_squared() > 0.5)
	input_vec = input_vec.normalized()
	# something here probably allows for swimming
	dir += -camxform.basis.z * input_vec.y # align to cam-relative axis
	dir += camxform.basis.x * input_vec.x # align to cam-relative axis
	dir += Vector3.UP * global_up_down # keep global so up/down is easier

	
func process_movement(delta : float) -> void:
	dir = dir.normalized()
	var target := dir
	target *= MAX_SPEED
	var accel : float
	if dir.dot(vel) > 0: # the fps demo used 'hvel' to seperate the horizontal axis. I don't need to because there are 3 axes of motion for swimming
		accel = ACCEL
	elif has_movement_input:
		accel = DEACCEL_MOVING
	else:
		accel = DEACCEL_IDLE
	# why do we do the modifications on a seperate var? was it to seperate horizontal and vertical motion?
	vel = vel.linear_interpolate(target, accel * delta)
	vel = move_and_slide(vel, Vector3.DOWN)

func _input(event: InputEvent) -> void:
	# let these be event driven so I don't have to poll all the time. Movement needs to be polled because I need to know the on/off states of every movement axis each physics step, these are one-shots essentially
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
			self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

			var camera_rot = rotation_helper.rotation_degrees
			camera_rot.x = clamp(camera_rot.x, -70, 70)
			rotation_helper.rotation_degrees = camera_rot
		# only try when mouse is captured
		if event.is_action_pressed("interact"):
			do_interact()
		if event.is_action_pressed("attack"):
			do_attack()
	if event.is_action_pressed("ui_cancel"):
		open_menu(PAUSE_MENU_SCENE)
	if event.is_action_pressed("open_inventory"):
		open_menu(INVENTORY_MENU_SCENE)

func open_menu(path : String) -> void:
		var menu :PackedScene= load(path)
		get_tree().current_scene.add_child(menu.instance())

func do_interact() -> void:
	if raycast.interact():
		anim.play("interact")

func do_attack() -> void:
	if raycast.attack():
		anim.play("knife_attack")
	else:
		anim.play("cannot_attack")

func get_inventory() -> ItemsContainer:
	return inventory


func _on_RayCast_on_start_can_attack() -> void:
	anim.play("knife_ready")

func _on_RayCast_on_end_can_attack() -> void:
	anim.play("knife_unready")

func _on_RayCast_on_start_can_interact() -> void:
	anim.play("can_interact_start")

func _on_RayCast_on_end_can_interact() -> void:
	anim.play_backwards("can_interact_start")


const save_vars := [
	# variable paths for values to save
	# this could be extrapolated to a seperate node for resuability
	"transform",
	"rotation_helper:rotation",
	"hunger",
	"thirst",
	"oxygen"
]

func load_data() -> void:
	var data := SaveData.load_custom_data(CUSTOM_DATA_SUFFIX) as Dictionary
	if data.empty():
		return
	for key in save_vars:
		if data.has(key):
			set_indexed(key, data[key])
	if data.has("inventory"):
		var ids := data["inventory"] as Array
		inventory.clear()
		inventory.load_from_ids(ids)

func save_data() -> void:
	var data := {}
	for key in save_vars:
		data[key] = get_indexed(key)
	data["inventory"] = inventory.get_as_ids()
	SaveData.save_custom_data(CUSTOM_DATA_SUFFIX, data)
