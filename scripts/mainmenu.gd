extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var brickSprite = preload("res://scenes/mainMenu/brickSprite.tscn")
var bodySprite  = preload("res://scenes/mainMenu/bodySprite.tscn")
var faceSprite  = preload("res://scenes/mainMenu/faceSprite.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	setupFaces()
	get_tree().connect("screen_resized", self, "resize")
	resize()
	gamestate.connect("round_ended", self, "end_of_round")
	gamestate.connect("game_ended", self, "end_of_game")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func setupFaces():
	for i in $wallpaper/foreground/faces.get_children():
		i.frame = 0
		i.play("default")

func resize():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var screenSize = get_viewport().size
	var numBricks = Vector2(floor(screenSize.x/64)+1,floor(screenSize.y/64)+1)
	var numFaces  = Vector2(floor(screenSize.x/70)+1,floor(screenSize.y/70)+1)
	
	#prints("numbricks: ", numBricks
	for i in $wallpaper/background.get_children():
		i.queue_free()
	for i in $wallpaper/foreground/bodies.get_children():
		i.queue_free()
	for i in $wallpaper/foreground/faces.get_children():
		i.queue_free()
	print($wallpaper/background)
	$lobby.center()
	for y in range(0,numBricks.y+1):
		for x in range(0,numBricks.x+1):
			var brick = brickSprite.instance()
			brick.position = Vector2(x*64, y*64)
			$wallpaper/background.add_child(brick)
	for y in range(0,numFaces.y+3):
		for x in range(0,numFaces.x+3):
			var face = faceSprite.instance()
			var body = bodySprite.instance()
			face.position = Vector2(x*70, y*70 - 70)
			body.position = Vector2(x*70, y*70 - 70)
			
			if y != 0 and x != 0:
				face.set_script(null)
				
			$wallpaper/foreground/faces.add_child(face)
			$wallpaper/foreground/bodies.add_child(body)
	$menuItems.rect_position = Vector2(24,screenSize.y-(24+$menuItems.rect_size.y))
	pass

func _on_btn_lobby_pressed():
	if $lobby.visible: $lobby.hide()
	else: $lobby.show()
	pass # Replace with function body.


func _on_btn_play_pressed():
	$lobby._on_host_pressed()
	$lobby._on_start_pressed()
	pass # Replace with function body.


func _on_btn_quit_pressed():
	get_tree().quit()
	pass # Replace with function body.

func end_of_round(winner):
	show()
	$wallpaper.hide()
	$menuItems.hide()
	$lobby.hide()
	$end_of_round_screen.show()
	$end_of_round_screen.get_node("lbl_winner").change_text(winner.get_player_name())
	$end_of_round_screen.get_node("body").modulate = gamestate.colors[winner.player_color]
	$end_of_round_screen.get_node("outline").modulate = gamestate.colors[winner.outline_color]
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass 

func end_of_game():
	show()
	$wallpaper.show()
	$menuItems.show()
	#$lobby.show()
	$end_of_round_screen.hide()
