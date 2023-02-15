extends Node

export (Array, Resource) var registered_items := []

func get_item(id : int) -> Item:
	if id >= 0 and id < registered_items.size():
		return registered_items[id]
	return null

func get_id(item : Item) -> int:
	for i in range(registered_items.size()):
		if item == registered_items[i]:
			return i
	return 0

