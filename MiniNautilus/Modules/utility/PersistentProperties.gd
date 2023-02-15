extends Node


export (String) var save_id := "generic_save"
export (NodePath) var source_node : NodePath
export (Array, String) var properties := []

func _ready() -> void:
	SaveData.connect("on_loading", self, "load_data")
	SaveData.connect("on_saving", self, "save_data")

func load_data() -> void:
	var data := SaveData.load_custom_data(save_id) as Dictionary
	var node := get_node(source_node) as Node
	if data.empty():
		return
	for key in properties:
		if data.has(key):
			node.set_indexed(key, data[key])

func save_data() -> void:
	var data := {}
	var node := get_node(source_node) as Node
	for key in properties:
		data[key] = node.get_indexed(key)
	if not data.empty():
		SaveData.save_custom_data(save_id, data)
