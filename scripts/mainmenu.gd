extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	gamestate.connect("round_ended", self, "end_of_round")
	gamestate.connect("game_ended", self, "end_of_game")
	get_tree().connect("screen_resized", self, "resize")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func resize():
	print($background)
	$lobby.center()
	$menuItems.rect_position = Vector2(24, get_viewport().size.y - (24+$menuItems.rect_size.y))

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
