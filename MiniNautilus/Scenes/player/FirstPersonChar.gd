extends KinematicBody

export (Resource) var inventory : Resource

const CUSTOM_DATA_SUFFIX := "_player_data"

const PAUSE_MENU_SCENE := "res://Scenes/menus/PauseMenu.tscn"

const GRAVTIY := -24.8
var vel := Vector3()
const MAX_SPEED := 20.0
const ACCEL := 4.5

var dir := Vector3()

const DEACCEL_MOVING := 4.0 # Likely will be lower because of water sim
const DEACCEL_IDLE := 1.0 # Likely will be lower because of water sim

var camera : Camera
var rotation_helper : Spatial
var has_movement_input := false

var MOUSE_SENSITIVITY := 0.3

onready var raycast : RayCast = $"rotation_helper/model/Camera/RayCast"

onready var anim : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	camera = $rotation_helper/model/Camera
	rotation_helper = $rotation_helper
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GM.set_up_player(self)
	SaveData.connect("on_saving", self, "save_data")
	SaveData.connect("on_loading", self, "load_data")
	# this should make it so anytime the player is unloaded from a scene, whether returning to a menu or the game is closing normally, the data gets saved.
	# this doesn't prevent loss from crashing, but that's really hard to prevent anyway
	self.connect("tree_exiting", self, "save_data")
	#load_data()
	
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
	if Input.is_action_pressed("ui_cancel"):
		var pause_menu :PackedScene= load(PAUSE_MENU_SCENE)
		get_tree().current_scene.add_child(pause_menu.instance())


func do_interact() -> void:
	if raycast.interact():
		anim.play("interact")

func do_attack() -> void:
	if raycast.attack():
		anim.play("knife_attack")
	else:
		anim.play("cannot_attack")

func get_inventory() -> ItemsContainer:
	return inventory as ItemsContainer


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
	"inventory:items",
	"transform",
	"rotation_helper:rotation"
]

func load_data() -> void:
	var data := SaveData.load_custom_data(CUSTOM_DATA_SUFFIX)
	if data.empty():
		return
#	if data.has("transform"):
#		var t = data["transform"]
#		print("data variable is type ", typeof(t), " with value ", t)
#		if typeof(t) == TYPE_TRANSFORM:
#			print("Successfully stored/loaded as a transform!!!")
#		set_indexed("transform", t)
	print("TYPE_VECTOR3=", TYPE_VECTOR3)
	for key in save_vars:
		if data.has(key):
			var value = data[key]
			print("Loading [",key,"] with value [", value, "], type=", typeof(value))
			set_indexed(key, data[key])

func save_data() -> void:
	var data := {}
	for key in save_vars:
		data[key] = get_indexed(key)
#	data["transform"] = get_indexed("transform")
	SaveData.save_custom_data(CUSTOM_DATA_SUFFIX, data)
