extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var canvas

# Called when the node enters the scene tree for the first time.
func _ready():
	show()
	canvas = texture
	
	canvas.get_data().fill(Color(1,1,1,0))
	texture = canvas
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
