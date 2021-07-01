extends TextureRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(NodePath) var _parent
onready var parent = get_node(_parent)


# Called when the node enters the scene tree for the first time.
func _ready():
	#get_tree().connect("screen_resized", self, "resize")
	#resize()
	parent.connect("health_changed", self, "update_display")
	if is_network_master():
		$body.modulate = gamestate.colors[parent.player_color]
		$outline.modulate = gamestate.colors[parent.outline_color]
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_display():
	if is_network_master():
		$outline.frame = stepify((parent.health / parent._health), 0.25) * 4
	pass

func resize():
	var screenSize = get_viewport().size
	if is_network_master():
		rect_position = Vector2(0, screenSize.y - rect_size.y)

func end_of_round(winner):
	hide()
