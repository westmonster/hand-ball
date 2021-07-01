extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	resize()
	gamestate.connect("round_ended", self, "end_of_round")
	get_tree().connect("screen_resized", self, "resize")
	pass # Replace with function body.

func resize():
	var screenSize = get_viewport().size
	if is_network_master():
		rect_position = Vector2(0, screenSize.y - rect_size.y)

func end_of_round(winner):
	hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
