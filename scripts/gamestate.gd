extends Node

# Default game port
var DEFAULT_PORT : int = 10567

# Max number of players
const MAX_PEERS = 4

# Name for my player
var player_name = "Smiley"
var player_color = "yellow"
var player_outline = "black"
var lobbyPath = ""

# Names for remote players in id:name format
var players = {}
# Colors for remote players in id:[color, outline] format
var players_colors = {}

# Timer and array for respawn
var respawn_queue = []
var _spawn_points = []
var respawn_timer = Timer.new()
var end_screen_timer = Timer.new()

# Pickup thing
var _pickup = preload("res://scenes/pickup.tscn")

# Signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal round_ended(winner)
signal game_ended()
signal game_error(what)

var colors = {
	"red"    : Color("ff0000"),
	"orange" : Color("ff6600"),
	"yellow" : Color("ffff00"),
	"green"  : Color("00cc00"),
	"blue"   : Color("0000cc"),
	"violet" : Color("cc00cc"),
	"white"  : Color("ffffff"),
	"black"  : Color("000000")
	}

# Callback from SceneTree
func _player_connected(id):
	# This is not used in this demo, because _connected_ok is called for clients
	# on success and will do the job.
	pass

# Callback from SceneTree
func _player_disconnected(id):
	if (get_tree().is_network_server()):
		if (has_node("/root/level_3d")): # Game is in progress
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
		else: # Game is not in progress
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)
				

# Callback from SceneTree, only for clients (not server)
func _connected_ok():
	# Registration of a client beings here, tell everyone that we are here
	rpc("register_player", get_tree().get_network_unique_id(), player_name, player_color, player_outline)
	emit_signal("connection_succeeded")

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions

remote func register_player(id, new_player_name, new_player_color, new_player_outline):
	if (get_tree().is_network_server()):
		# If we are the server, let everyone know about the new player
		rpc_id(id, "register_player", 1, player_name, player_color, player_outline) # Send myself to new dude
		for p_id in players: # Then, for each remote player
			rpc_id(id, "register_player", p_id, players[p_id], players_colors[p_id][0], players_colors[p_id][1]) # Send player to new dude
			rpc_id(p_id, "register_player", id, new_player_name, new_player_color, new_player_outline) # Send new dude to player

	players[id] = new_player_name
	players_colors[id] = [new_player_color, new_player_outline]
	emit_signal("player_list_changed")

remote func unregister_player(id):
	players.erase(id)
	players_colors.erase(id)
	emit_signal("player_list_changed")

remote func pre_start_game(spawn_points):
	# Change scene
	var level_3d = load("res://scenes/class-ick.tscn").instance()
	get_tree().get_root().add_child(level_3d)

	get_tree().get_root().get_node("main_menu").hide()
	#get_tree().get_root().get_node("UI").hide()
	
	#get_tree().get_root().get_node("UI/Windows/lobby").hide()

	var player_scene = load("res://scenes/smiloid.tscn")

	for p_id in spawn_points:
		var spawn_pos = level_3d.get_node("spawn_points/" + str(spawn_points[p_id])).get_translation()
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name
		player.set_translation(spawn_pos)
		player.set_network_master(p_id) #set unique id as master

		if (p_id == get_tree().get_network_unique_id()):
			# If node for this peer id, set name
			player.set_player_name(player_name)
			
			player.set_colors(player_color, player_outline)
		else:
			# Otherwise set name from peer
			player.set_player_name(players[p_id])
			player.set_colors(players_colors[p_id][0], players_colors[p_id][1])

		level_3d.get_node("players").add_child(player)

	# Set up score
	level_3d.get_node("score").add_player(get_tree().get_network_unique_id(), player_name)
	for pn in players:
		level_3d.get_node("score").add_player(pn, players[pn])

	if (not get_tree().is_network_server()):
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!
	_spawn_points = get_tree().get_root().get_node("level_3d/spawn_points").get_children()

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if (not id in players_ready):
		players_ready.append(id)

	if (players_ready.size() == players.size()):
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(port, new_player_name, body_color, outline_color):
	player_name = new_player_name
	player_color = body_color
	player_outline = outline_color
	DEFAULT_PORT = port
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

func join_game(port, ip, new_player_name, body_color, outline_color):
	player_name = new_player_name
	player_color = body_color
	player_outline = outline_color
	DEFAULT_PORT = port
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)

func end_game():
	if (has_node("/root/level_3d")): # Game is in progress
		# End it
		get_node("/root/level_3d").queue_free()

	emit_signal("game_ended")
	#players.clear()
	#players_colors.clear()
	get_tree().set_network_peer(null) # End networking
	get_tree().get_root().get_node("main_menu").show()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_timeout_queue_respawn():
	for i in respawn_queue:
		respawn(i)
	if respawn_queue.size() > 0:
		respawn_timer.start(1)

func respawn(entity):
	#var _spawn_points = get_tree().get_root().get_node("level_3d/spawn_points").get_children()
	for i in range(0,_spawn_points.size()-1):
		if _spawn_points[i].get_node("Area").get_overlapping_bodies().size() == 0:
			entity.spawn(_spawn_points[i].global_transform)
			var tmp_sp = _spawn_points[i]
			_spawn_points.remove(i)
			_spawn_points.append(tmp_sp)
			if respawn_queue.has(entity):
				respawn_queue.erase(entity)
			return
	respawn_queue.append(entity)
	respawn_timer.start()
	return 

func count_kills():
	var player_list = get_tree().get_root().get_node("/root/level_3d/players").get_children()
	for i in player_list:
		if i.kills > 5 and !i.is_drone:
		#	prints("winner: ", i.name)
		#	prints("Players: ", players.values())
			emit_signal("round_ended", i)
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			end_screen_timer.start(10)
	pass

func _ready():
	add_child(respawn_timer)
	respawn_timer.one_shot = true
	respawn_timer.connect("timeout", self, "_on_timeout_queue_respawn")
	add_child(end_screen_timer)
	end_screen_timer.one_shot = true
	end_screen_timer.connect("timeout", self, "end_game")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
