extends Resource
class_name Recipe

export (Array, Resource) var ingredients := [] # TODO dictionary doesn't work
export (Resource) var result : Resource

func can_craft(container : ItemsContainer, consume := false) -> bool:
	var remaining := ingredients.duplicate(true)
	var consume_array := []
	for index in range(container.items.size()):
		var item := container.items[index] as Item
		if remaining.has(item):
			consume_array.append(index)
			remaining.remove(remaining.find(remaining))
	if remaining.empty():
		if consume:
			for index in consume_array:
				container.remove_item(index)
		return true
	return false

func do_craft(container : ItemsContainer) -> bool:
	if can_craft(container, true):
		return true # do crafting
	return false
