extends CharacterBody3D

@export var base_speed = 5.0
@export var speed_multiplier = 1
@export var move_speed = 5.0
@export var is_sprinting = false

var is_stunned: bool = false
var stun_timer := 0.0

var jump_force = 4.5
var rotation_speed = 16.0 #Model rotation

var spell_orb = load("res://spell_orb.tscn")
var instance

@onready var spring_arm = $CameraRoot/CameraYaw/CameraPitch/SpringArm3D
@onready var model = $MeshRoot/Wizard
@onready var spell_start = $MeshRoot/Wizard/RayCast3D

func set_speed_multiplier(value: float) -> void:
	speed_multiplier = clamp(value, 0.0, 5.0)
	move_speed = base_speed * speed_multiplier

func stun(duration: float) -> void:
	is_stunned = true
	stun_timer = duration
	set_speed_multiplier(0.0)
	velocity.x = 0
	velocity.z = 0

func _physics_process(delta: float) -> void:
	#Handle stun
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false
			set_speed_multiplier(1.0)
		
		#Apply gravity while stunned
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		#Prevent movement while stunned
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
		move_and_slide()
		return

	#Handle sprint
	if is_on_floor():
		if Input.is_action_pressed("sprint"):
			is_sprinting = true
		else:
			is_sprinting = false

		if is_sprinting:
			set_speed_multiplier(2.0)
		else:
			set_speed_multiplier(1.0)
	
	#Handle Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	#Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	#Handle attack
	if Input.is_action_just_pressed("lmb"):
		instance = spell_orb.instantiate()
		instance.position = spell_start.global_position
		instance.transform.basis = spell_start.global_transform.basis
		get_parent().add_child(instance)
	
	#Input & movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var camera_basis = spring_arm.global_transform.basis
	var forward = camera_basis.z
	var right = camera_basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()

	var move_dir = (right * input_dir.x + forward * input_dir.y).normalized()

	if move_dir != Vector3.ZERO:
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
		var target_rotation = atan2(move_dir.x, move_dir.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation, delta * rotation_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()
