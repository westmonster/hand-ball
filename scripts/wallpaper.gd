extends Node2D

var brickSprite = preload("res://scenes/mainMenu/brickSprite.tscn")
var bodySprite  = preload("res://scenes/mainMenu/bodySprite.tscn")
var faceSprite  = preload("res://scenes/mainMenu/faceSprite.tscn")

func _ready():
	setupFaces()
	get_tree().connect("screen_resized", self, "resize")
	resize()

func setupFaces():
	for i in $foreground/faces.get_children():
		i.frame = 0
		i.play("default")

func resize():
	var screenSize = get_viewport().size
	var numBricks = Vector2(floor(screenSize.x/64)+1,floor(screenSize.y/64)+1)
	var numFaces  = Vector2(floor(screenSize.x/70)+1,floor(screenSize.y/70)+1)
	
	#prints("numbricks: ", numBricks
	for i in $background.get_children():
		i.queue_free()
	for i in $foreground/bodies.get_children():
		i.queue_free()
	for i in $foreground/faces.get_children():
		i.queue_free()
	for y in range(0,numBricks.y+1):
		for x in range(0,numBricks.x+1):
			var brick = brickSprite.instance()
			brick.position = Vector2(x*64, y*64)
			$background.add_child(brick)
	for y in range(0,numFaces.y+3):
		for x in range(0,numFaces.x+3):
			var face = faceSprite.instance()
			var body = bodySprite.instance()
			face.position = Vector2(x*70, y*70 - 70)
			body.position = Vector2(x*70, y*70 - 70)
			
			if y == 0 and x == 0:
				# since the face at 0, 0 can be deleted above when resizing, we have to do this
				# check so faces and bodies get color changes
				face.connect("animation_finished", $foreground, "_on_Sprite_animation_finished")
			
			$foreground/faces.add_child(face)
			$foreground/bodies.add_child(body)
