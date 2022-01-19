extends GridContainer


const Slot := preload("res://Scenes/ui/item_system/InventorySlotUI.tscn")

export (Resource) var target_items_container : Resource
export var disable_drag_and_drop := false

var container : ItemsContainer

func _ready() -> void:
	container = target_items_container as ItemsContainer
	# assert to keep me sane
	assert(container, "Container is not assigned to a valid ItemsContainer")
	container.connect("items_changed", self, "on_items_changed")
	refresh_entire_display() # initializes needed slots and fills them with their items

func refresh_entire_display() -> void:
	var target = container.inventory_size
	if target <= 0:
		target = container.items.size()
	if get_child_count() < target:
		for i in range(target - get_child_count()):
			var slot = Slot.instance()
			slot.inventory = container
			slot.drag_drop_disabled = disable_drag_and_drop
			add_child(slot)
	# now there should be proper number of slots
	on_items_changed(range(target))
	
func on_items_changed(indices : Array) -> void:
	#print("Detected items changed at indices ", indices)
	for index in indices:
		update_slot(index)

func update_slot(index : int) -> void:
	var item := container.get_item(index) as Item
	var slot := get_child(index)
	#print("Attempting to update display for slot #", index, "with item : ", item)
	slot.display_item(item)
	if not item == null:
		#print("Updating slot #", index, " to display item \"", item.name, "\"")
		pass

