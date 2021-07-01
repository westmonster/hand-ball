extends KinematicBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#movement stuff
var gravity : Vector3 = Vector3.DOWN * 12.0
export(float) var speed = 5.0
export(float) var max_speed = 10.0
const Accel = 0.5
const Deaccel = 16
export(float) var turn_speed = 1.25

#ball stuff
onready var _ball = preload("res://scenes/ball.tscn")
export(float) var fire_wait_time = 0.5 # Seconds
var can_fire = true
var ball_index = 0

#Declare player data here.
export var player_color = "yellow"
export var outline_color = "black"

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

const is_drone = true

# Use sync because it will be called everywhere
sync func fire():
	prints("Child nodes: ", get_children())
	var ball = _ball.instance()
	ball.set_name(get_name() + str(ball_index)) # Ensure unique name for the bomb
	ball.creator = self
	ball.from_player = get_tree().get_network_unique_id()
	ball.color = player_color
	ball.outline = outline_color
	for i in ball.get_node("color").get_children():
		if i.name == player_color: i.show()
		else: i.hide()

	for j in ball.get_node("outline").get_children():
		if j.name == outline_color: j.show()
		else: j.hide()

	# No need to set network mode to ball, will be owned by master by default
	get_node("../..").add_child(ball)
	ball.set_global_transform($rotation_helper/muzzle.global_transform)
	ball.start_point = ball.global_transform.origin
	ball_index+=1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$BehaviorTree._tick()
	pass

func task_succeed():
	return OK
	pass

func task_fail():
	return FAILED
	pass

func task_fire(task):
	if can_fire:
		fire()
		can_fire = false
		$Timer.start(1.0)
		task.failed()
	else:
		task.failed()
	pass

func _on_Timer_timeout():
	can_fire = true
	pass # Replace with function body.
