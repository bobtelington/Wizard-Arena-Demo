extends Node3D

const SPEED = 40

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
