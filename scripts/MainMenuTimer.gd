extends Timer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var colors = [
	Color("ff0000"),
	Color("ff6600"),
	Color("ffff00"),
	Color("00cc00"),
	Color("0000cc"),
	Color("cc00cc")
	]

var outlines = [ Color("ffffff"), Color("000000") ]
var outlineIndex = 1
var outlineCounter = 0
var colorIndex = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	colorIndex += 1
	outlineCounter += 1
	if colorIndex > colors.size()-1:
		colorIndex = 0
		
	for i in get_node("../back").get_children():
		i.modulate = colors[colorIndex]
	if outlineCounter > 5:
		outlineCounter = 0
		outlineIndex += 1
		if outlineIndex > 1: outlineIndex = 0
		for j in get_node("../faces").get_children():
			j.modulate = outlines[outlineIndex]
	start(2)
	pass # Replace with function body.
