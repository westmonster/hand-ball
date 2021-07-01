extends Control


var colors = [
	Color("ff0000"),
	Color("ff6600"),
	Color("ffff00"),
	Color("00cc00"),
	Color("0000cc"),
	Color("cc00cc")
	]

var outlines = [ Color("000000"), Color("ffffff") ]

signal player_color_changed(color)
signal player_outline_changed(outline)

func center():
	var ctrl_half_size = rect_size/2
	var view_half_size = get_viewport().size/2
	rect_position = view_half_size-ctrl_half_size

func _ready():
	
	center()
	
	#popup_centered()
	# Called every time the node is added to the scene.
	gamestate.lobbyPath = get_path()
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	
	$connect/body_color.add_item("red")
	$connect/body_color.add_item("orange")
	$connect/body_color.add_item("yellow")
	$connect/body_color.add_item("green")
	$connect/body_color.add_item("blue")
	$connect/body_color.add_item("violet")
	$connect/body_color.select(2)
	
	$connect/outline_color.add_item("black")
	$connect/outline_color.add_item("white")
	$connect/outline_color.select(0)

func _on_host_pressed():
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return

	get_node("connect").hide()
	get_node("players").show()
	get_node("connect/error_label").text=""

	var player_name = get_node("connect/name").text
	var player_color = $connect/body_color.get_item_text($connect/body_color.selected)
	var player_outline = $connect/outline_color.get_item_text($connect/outline_color.selected)
	
	var port = int(get_node("connect/port").value)
	gamestate.host_game(port, player_name, player_color, player_outline)
	refresh_lobby()

func _on_join_pressed():
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return

	var ip = get_node("connect/ip").text
	if (not ip.is_valid_ip_address()):
		get_node("connect/error_label").text="Invalid IPv4 address!"
		return

	var port = int(get_node("connect/port").value)
	if (port == 0):
		get_node("connect/error_label").text="Port cannot be 0!"
		return

	get_node("connect/error_label").text=""
	get_node("connect/host").disabled=true
	get_node("connect/join").disabled=true

	var player_name = get_node("connect/name").text
	gamestate.join_game(port, ip, player_name, $connect/body_color.get_item_text($connect/body_color.selected), $connect/outline_color.get_item_text($connect/outline_color.selected))
	# refresh_lobby() gets called by the player_list_changed signal


func _on_cancel_pressed():
	get_node("connect").show()
	get_node("players").hide()
	get_node("connect/error_label").text=""
	
	gamestate.end_game()
	
	pass # Replace with function body.


func _on_connection_success():
	get_node("connect").hide()
	get_node("players").show()

func _on_connection_failed():
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled=false
	get_node("connect/error_label").set_text("Connection failed.")

func _on_game_ended():
	show()
	get_node("connect").show()
	get_node("players").hide()
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled

func _on_game_error(errtxt):
	get_node("error").dialog_text = errtxt
	get_node("error").popup_centered_minsize()

func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	get_node("players/list").clear()
	get_node("players/list").add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		get_node("players/list").add_item(p)

	get_node("players/start").disabled=not get_tree().is_network_server()

func _on_start_pressed():
	gamestate.begin_game()

func _on_Quit_pressed():
	#reload a scene
	#var currentScene = get_tree().get_current_scene().get_filename()
	#print(currentScene) # for Debug
	#get_tree().change_scene(currentScene)
	
	gamestate.end_game()
	print("end game")
	get_tree().quit()
	


func _on_body_color_item_selected(ID):
	$connect/body.modulate = colors[ID]
	emit_signal("player_color_changed",colors[ID])
	pass # Replace with function body.


func _on_outline_color_item_selected(ID):
	$connect/outline.modulate = outlines[ID]
	emit_signal("player_outline_changed",outlines[ID])
	pass # Replace with function body.


func _on_hide_pressed():
	hide()
	pass # Replace with function body.
