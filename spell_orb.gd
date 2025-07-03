extends Node3D

const SPEED = 40

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		get_tree().call_group("Enemy", "die")
