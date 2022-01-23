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
			var r_index := remaining.find(item)
			print("Found needed item for recipe '",item.name,"' ", item, "\n\tclearing out index ", r_index, " from remaining queue")
			
			remaining.remove(r_index)
	if remaining.empty():
		if consume:
			for index in consume_array:
				container.remove_item(index)
		#print("can_craft in recipe [", self.resource_path, "] returned true")
		return true
	#print("can_craft in recipe [", self.resource_path, "] returned false")
	return false

func do_craft(container : ItemsContainer) -> bool:
	if can_craft(container, true):
		container.add_item(result)
		return true
	return false
