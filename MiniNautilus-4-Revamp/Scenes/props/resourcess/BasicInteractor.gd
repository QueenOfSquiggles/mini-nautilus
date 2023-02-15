extends Node3D # really should be checked a spatial, collidable object

@export var interaction_text := "Test interaction"

@export var item : Resource

@export (int) var num_interacts := 1
@export (bool) var destroy_on_interact := false

var interact_count := 0

func get_interact_text() -> String:
	return interaction_text

func interact(interacted_with) -> void:
	if interact_count >= num_interacts and num_interacts > 0:
		return
	print("Object ", self.name, " was interacted with by ", interacted_with)

	if interacted_with and interacted_with.has_method("get_inventory"):
		var temp = interacted_with.get_inventory()
		var inv := temp as ItemsContainer
		if not inv:
			print("[", interacted_with, "] has a null inventory!")
			return
		var returned_item = inv.add_item(item)
		if returned_item:
			print("failed to add ", returned_item, " to inventory")
			item.drop_into_world(self.transform.origin, get_tree().current_scene)
		else:
			print("Item ",item," added to inventory")
		if num_interacts > 0:
			interact_count += 1
		if interact_count >= num_interacts and destroy_on_interact:
			call_deferred("queue_free")
