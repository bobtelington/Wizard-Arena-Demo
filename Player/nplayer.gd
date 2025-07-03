class_name Player
extends CharacterBody3D

#Player Variables
@export var stats: PlayerStats
@export var health: int
@onready var spell_start = $Area3D/CollisionShape3D
var speed_multiplier: float = 1
var player_rotation: Vector3
var spell_orb = load("res://spell_orb.tscn")
var instance

#Camera Variables
@export var mouse_sensitivity: float = 0.1
@export var pitch_min := deg_to_rad(-90)
@export var pitch_max := deg_to_rad(90)
@export var camera_controller: SpringArm3D
@export var cam = Camera3D
var mouse_lock: bool = true
var mouse_input: bool = false
var mouse_rotation: Vector3
var mouse_yaw: float
var mouse_pitch: float
var camera_rotation: Vector3

func _input(event):
	if event.is_action_pressed("escape") and mouse_lock == true:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_lock = false
		print("mouse unlocked")
		
	if event.is_action_pressed("rmb") and mouse_lock == false:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_lock = true
		print("mouse locked")
		
func _unhandled_input(event):
	mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	
	if mouse_input:
		mouse_yaw = -event.relative.x * mouse_sensitivity
		mouse_pitch = -event.relative.y * mouse_sensitivity
		#print(Vector2(mouse_yaw, mouse_pitch))
		
func _update_camera(delta):
	mouse_rotation.x += mouse_pitch * delta
	mouse_rotation.x = clamp(mouse_rotation.x, pitch_min, pitch_max)
	mouse_rotation.y += mouse_yaw * delta
	
	player_rotation = Vector3(0,mouse_rotation.y,0)
	camera_rotation = Vector3(mouse_rotation.x,0,0)
	
	camera_controller.transform.basis = Basis.from_euler(camera_rotation)
	camera_controller.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(player_rotation)
	
	mouse_yaw = 0.0
	mouse_pitch = 0.0

func update_health():
	$HUD/Panel/Label.text = str(health)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health = stats.base_health
	update_health()
	print("Health: ", health)
	
func take_damage(amount):
	health -= amount
	if health < 0:
		health = 0
	update_health()
	print("Health: ", health)
	
func heal():
	health += 10
	if health > stats.base_health:
		health = stats.base_health
	update_health()
	print("Health: ", health)
	
func attack():
	if mouse_lock:
		cam.mouse_to_3d()
		$HUD/Panel2/Label.text = str(cam.target)
		instance = spell_orb.instantiate()
		instance.position = spell_start.global_position
		instance.transform.basis = spell_start.global_transform.basis
		get_parent().add_child(instance)
	else:
		pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	_update_camera(delta)
	
	if Input.is_action_just_pressed("damage"):
		take_damage(5)
	
	if Input.is_action_just_pressed("heal"):
		heal()
	
	if Input.is_action_just_pressed("lmb"):
		attack()
	
	var move_speed = stats.base_speed * speed_multiplier
	var jump_force = stats.jump_force
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		
	#Handle Sprint
	if Input.is_action_pressed("sprint") and is_on_floor():
		speed_multiplier = 2.0
		
	if not Input.is_action_pressed("sprint") and is_on_floor():
		speed_multiplier = 1.0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()
