extends TextureRect


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
export(NodePath) var _parent
onready var parent = get_node(_parent)


# Called when the node enters the scene tree for the first time.
func _ready():
	#get_tree().connect("screen_resized", self, "resize")
	#resize()
	parent.connect("powered_up", self, "check_enabled",[],1)
	parent.connect("powered_down", self, "check_disabled",[],1)
	if is_network_master():
		$TextureProgress.tint_progress = gamestate.colors[parent.player_color]
		$TextureProgress.tint_over = gamestate.colors[parent.outline_color]
	$Tween.interpolate_property($TextureProgress,"value",80,18,10.0,Tween.TRANS_LINEAR,Tween.EASE_IN,0)

func check_enabled(powerup):
	if powerup == "speed" and is_network_master():
		show()
		$Tween.start()

func check_disabled(powerup):
	if powerup == "speed" and is_network_master():
		hide()