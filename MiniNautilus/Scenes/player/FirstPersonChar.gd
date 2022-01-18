extends KinematicBody

export (Resource) var inventory : Resource

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

func _ready() -> void:
	camera = $rotation_helper/model/Camera
	rotation_helper = $rotation_helper
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GM.set_up_player(self)

func _physics_process(delta: float) -> void:
	process_input(delta)
	process_movement(delta)


func process_input(_delta : float) -> void:
	dir = Vector3()
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
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	
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
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
		
	# let these be event driven so I don't have to poll all the time. Movement needs to be polled because I need to know the on/off states of every movement axis each physics step, these are one-shots essentially
	if event.is_action_pressed("interact"):
		do_interact()
	if event.is_action_pressed("attack"):
		do_attack()


func do_interact() -> void:
	#print("Interaction just pressed!")
	raycast.interact()

func do_attack() -> void:
	print("Attack just pressed!")

func get_inventory() -> ItemsContainer:
	return inventory as ItemsContainer
