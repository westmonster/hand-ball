extends Node2D

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
var colorIndex = 1

func _ready():
	# Connect only the first sprite's signal
	$"faces/Sprite".connect("animation_finished", self, "_on_Sprite_animation_finished")

func _on_Sprite_animation_finished():
	print('going now')
	colorIndex += 1
	if colorIndex > colors.size()-1:
		colorIndex = 0
		outlineIndex += 1
		if outlineIndex > 1: outlineIndex = 0
		for j in get_node("faces").get_children():
			j.modulate = outlines[outlineIndex]
		
	for i in get_node("bodies").get_children():
		i.modulate = colors[colorIndex]
