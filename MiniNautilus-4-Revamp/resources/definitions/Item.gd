extends Resource
class_name Item

@export var name := "Default Item"
@export var description := "Lorem Ipsum"

# texture representation in inventories
@export var inventory_texture : Texture2D

# scene representation for item in game world
@export var world_object : PackedScene


func drop_into_world(position : Vector3, parent : Node) -> void:
	var packed :PackedScene= world_object
	var world_item := packed.instantiate()
	world_item.transform.origin = position
	world_item.item = self
	if world_item is RigidBody3D:
		(world_item as RigidBody3D).mode = RigidBody3D.MODE_RIGID
	parent.add_child(world_item)
