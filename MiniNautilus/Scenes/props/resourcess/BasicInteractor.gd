extends Node # really should be on a spatial, collidable object

export var interaction_text := "Test interaction"

func get_interact_text() -> String:
	return interaction_text

func interact() -> void:
	print("Object ", self.name, " was interacted with")
	
