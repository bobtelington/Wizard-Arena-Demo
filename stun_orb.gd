extends Area3D

var attack_damage := 10

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.has_method("damage"):
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		
		body.attack(attack)
