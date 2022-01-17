extends KinematicBody

const GRAVTIY := -24.8
var vel := Vector3()
const MAX_SPEED := 20.0
const ACCEL := 4.5

var dir := Vector3()

const DEACCEL_MOVING := 2.0 # Likely will be lower because of water sim
const DEACCEL_IDLE := 0.5 # Likely will be lower because of water sim

var camera : Camera
var rotation_helper : Spatial
var has_movement_input := false

var MOUSE_SENSITIVITY := 0.3

func _ready() -> void:
	camera = $rotation_helper/model/Camera
	rotation_helper = $rotation_helper
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	process_input(delta)
	process_movement(delta)


func process_input(delta : float) -> void:
	dir = Vector3()
	var camxform :Transform = camera.global_transform
	var input_vec := Vector2()
	if Input.is_action_pressed("move_forwards"):
		input_vec.y += 1
	if Input.is_action_pressed("move_back"):
		input_vec.y -= 1
	if Input.is_action_pressed("move_left"):
		input_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vec.x += 1
	has_movement_input = (input_vec.length_squared() > 0.5)
	input_vec = input_vec.normalized()
	# something here probably allows for swimming
	dir += -camxform.basis.z * input_vec.y
	dir += camxform.basis.x * input_vec.x
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	
func process_movement(delta : float) -> void:
	#dir.y = 0
	dir = dir.normalized()
	
	var hvel := vel
	#hvel.y = 0
	
	var target := dir
	target *= MAX_SPEED
	
	var accel : float
	if dir.dot(hvel) > 0:
		accel = ACCEL
	elif has_movement_input:
		accel = DEACCEL_MOVING
	else:
		accel = DEACCEL_IDLE
	
	hvel = hvel.linear_interpolate(target, accel * delta)
	
	vel = hvel
	#vel.x = hvel.x
	#vel.z = hvel.z
	
	vel = move_and_slide(vel, Vector3.DOWN)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
