extends CharacterBody3D

func die():
	queue_free()

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		get_tree().call_group("Player", "take_damage", 20)
