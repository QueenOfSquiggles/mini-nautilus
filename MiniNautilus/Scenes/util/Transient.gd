extends Node

enum Style {
	DEFERRED, TIME
}

export (Style) var removal_style := Style.DEFERRED
export (float) var removal_time := 0.1

func _ready() -> void:
	if removal_style == Style.DEFERRED:
		get_parent().call_deferred("queue_free")
	else:
		get_tree().create_timer(removal_time).connect("timeout", get_parent(), "queue_free")
