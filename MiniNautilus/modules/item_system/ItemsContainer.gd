extends Resource
class_name ItemsContainer

signal items_changed(indices)

export var container_name := "Generic Inventory"
# inventory size 0 for dynamic allocation
# any other size for a fixed quantity
export var inventory_size := 0

export (Array, Resource) var items := []

func _init(size : int, name : String = "Generated") -> void:
	self.inventory_size = size
	self.container_name = name
	ensure_full()

func ensure_full() -> void:
	if inventory_size > items.size():
		for i in range(inventory_size - items.size()):
			items.append(null)
		#print("Items ready in '", container_name, "' : ", items)

func add_item(item : Item) -> Item:
	if item == null:
		return null
	for index in range(items.size()):
		if items[index] == null:
			# empty slot for item. put it in and return
			items[index] = item
			emit_signal("items_changed", [index])
			return null
	if items.size() < inventory_size:
		# no empty slots and inventory has room to grow
		# append item
		items.append(item)
		emit_signal("items_changed", [items.size()-1])
		return null
		
	return item # failed to add to inventory. return item ref

func set_item(index : int, item : Item) -> Item:
	if not is_valid_index(index):
		return item
	var previous_item = items[index]
	items[index] = item
	emit_signal("items_changed", [index])
	return previous_item

func swap_items(index_a : int, index_b : int) -> void:
	if not is_valid_index(index_a) or not is_valid_index(index_b):
		print("failed to swap items because one or both indices are invalid: ", [index_a, index_b])
		return
	var temp_item = items[index_a]
	items[index_a] = items[index_b]
	items[index_b] = temp_item
	emit_signal("items_changed", [index_a, index_b])

func remove_item(index : int) -> Item:
	if not is_valid_index(index):
		return null
	var item = items[index]
	items[index] = null
	if inventory_size <= 0 and index == items.size()-1:
		# we are using a dynamic allocating inventory, clear extra slot if at end
		items.remove(index)
	emit_signal("items_changed", [index])
	return item

func get_item(index : int) -> Item:
	if is_valid_index(index):
		return items[index]
	return null

func is_valid_index(index : int) -> bool:
	ensure_full() # <-- make sure there are slots for fixed size inventories
	return index >= 0 and index < items.size()
	
func clear() -> void:
	for i in range(items.size()):
		items[i] = null

func get_as_ids() -> Array:
	"""
	Using the array of ids works better for serialization
	"""
	var ids := []
	for item in items:
		if item:
			ids.append(Items.get_id(item))
	return ids

func load_from_ids(ids : Array) -> void:
	"""
	Using the array of ids works better for serialization
	this method does not automatically clear the inventory
	"""
	for i in ids:
		var item := Items.get_item(i) as Item
		if item:
			add_item(item)
