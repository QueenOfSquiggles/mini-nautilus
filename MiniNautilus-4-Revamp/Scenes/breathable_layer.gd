extends Area3D


func _ready() -> void:
	pass


func _on_breathable_layer_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.oxygen = 1.0
