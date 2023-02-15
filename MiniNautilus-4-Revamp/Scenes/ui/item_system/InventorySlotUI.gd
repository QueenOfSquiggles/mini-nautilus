extends AspectRatioContainer

var inventory : ItemsContainer

@onready var texture_rect : TextureRect = $"Panel/Texture2D"

var item_name := ""
var item_desc := ""
var drag_drop_disabled := false

func display_item(item : Item) -> void:
	if item:
		var tex := item.inventory_texture
		if tex:
			texture_rect.texture = tex
		item_name = item.name
		item_desc = item.description
	else:
		texture_rect.texture = null
		item_name = ""
		item_desc = ""
	
func _get_drag_data(_position: Vector2) -> Dictionary:
	# godot built-in drag & drop
	if drag_drop_disabled:
		# in some cases where we only want to display, but not affect the items, like in the hotbar
		return {}
		
	var index = get_index()
	var item := inventory.remove_item(index)
	if item is Item:
		# valid item and not null
		var data := {}
		data["Item"] = item
		data["Index"] = index
		
		var dragPreview := TextureRect.new()
		dragPreview.texture = item.inventory_texture
		set_drag_preview(dragPreview)
		#print("Dragging : ", data)
		return data
	if GM.player_hud:
		GM.player_hud.hide_tooltip()
	return {}

func can_drop_data(_position: Vector2, data) -> bool:
	#print("Verifying drop validity")
	return data is Dictionary and data.has("Item")

func drop_data(_position: Vector2, data : Dictionary) -> void:
	var index = get_index()
	var drop_index = data["Index"] as int
	var item := data["Item"] as Item
	inventory.set_item(drop_index, item) # replace item at original location
	inventory.swap_items(index, drop_index) # swap slots around
	# this does create a few extra signal calls so might not be very performant, but not really noticable for the most part
	#print("accepted item ", item, "from index :", drop_index, " at index : ", index)


