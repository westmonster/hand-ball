extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("../../lobby").connect("player_color_changed",self,"color_changed",[],0)
	get_node("../../lobby").connect("player_outline_changed",self,"outline_changed",[],0)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_viewport().get_mouse_position()
	pass

func color_changed(color):
	self_modulate = color
	pass

func outline_changed(outline):
	$outline.self_modulate = outline
	pass
