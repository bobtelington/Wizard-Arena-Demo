extends Area3D

@export var stun_duration := 3.0
@export var stun_multiplier := 0.0  # Set to 0 to stop movement completely

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.has_method("stun"):
		body.stun(stun_duration)
		queue_free()
