extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	resize()
	get_tree().connect("screen_resized", self, "resize")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func resize():
	var ctrl_half_size = rect_size/2
	var view_half_size = get_viewport().size/2
	rect_position = view_half_size-ctrl_half_size