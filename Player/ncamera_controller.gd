extends Node

#Camera variables
@onready var yaw_node = $CameraYaw
@onready var pitch_node = $CameraYaw/CameraPitch
@onready var camera = $CameraYaw/CameraPitch/Camera3D

var yaw : float = 0
var pitch : float = 0
var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07
var yaw_acceleration : float = 15
var pitch_acceleration : float = 15
var pitch_max: float = 40
var pitch_min: float = -60

var camera_mode: bool = true

#On ready
func _ready():
	#Capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#Camera controls
func _input(event):
	#Release mouse (esc key)
	if event.is_action_pressed("escape") and camera_mode == true:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		camera_mode = false
		print(camera_mode)
	
	#Capture mouse (left click)
	if event.is_action_pressed("rmb") and camera_mode == false:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera_mode = true
		print(camera_mode)
	
	#Camera movement (mouse move)
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += -event.relative.y * pitch_sensitivity
		
func _physics_process(delta):
	#Camera clamp
	pitch = clamp(pitch, pitch_min, pitch_max)
	#For direct cam
	yaw_node.rotation_degrees.y = yaw
	pitch_node.rotation_degrees.x = pitch
	#For smooth cam
	#yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	#pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
