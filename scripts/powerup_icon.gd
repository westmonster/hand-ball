extends TextureRect


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
export(NodePath) var _parent
export(String, "speed", "rapidfire", "health", "armor", "jump", "omnishot", "poison") var _powerup = "speed"
onready var parent = get_node(_parent)
export(float) var top_of_icon = 80
export(float) var bottom_of_icon = 18
export(float) var time = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	#get_tree().connect("screen_resized", self, "resize")
	#resize()
	hide()
	parent.connect("powered_up", self, "check_enabled",[],1)
	parent.connect("powered_down", self, "check_disabled",[],1)
	if is_network_master():
		$TextureProgress.tint_progress = gamestate.colors[parent.player_color]
		$TextureProgress.tint_over = gamestate.colors[parent.outline_color]
	$Tween.interpolate_property($TextureProgress,"value",top_of_icon,bottom_of_icon,time,Tween.TRANS_LINEAR,Tween.EASE_IN,0)

func check_enabled(powerup):
	if powerup == _powerup and is_network_master():
		show()
		$Tween.start()

func check_disabled(powerup):
	if powerup == _powerup and is_network_master():
		hide()