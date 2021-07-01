extends KinematicBody

# Declare member variables here. Examples:
puppet var slave_pos : Vector3 = Vector3()
puppet var slave_dir : Vector3 = Vector3()
puppet var slave_aim : Vector3 = Vector3()
puppet var slave_motion : Vector3 = Vector3()

#Declare player data here.
var player_name = "Smiley"
var player_color = "yellow"
var outline_color = "black"

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

export(float) var _health = 5.0
onready var health = _health
export(float) var health_regen_time = 10
export(float) var health_regen_amount = 1
var kills = 0
var deaths = 0
var kills_this_life = 0

#export var stunned = false

const max_slope_angle = 50

var current_anim = ""
var prev_firing = false
var ball_index = 0

var gravity : Vector3 = Vector3.DOWN * 12.0
var speed = 5.0
var max_speed = 10.0
const Accel = 0.5
const Deaccel = 16

var velocity : Vector3 = Vector3()

var camera
var rotation_helper

var mouse_sensitivity = 0.05
var dir

#ball stuff
onready var _ball = preload("res://scenes/ball.tscn")
export var fire_wait_time = 0.5 # Seconds
var can_fire = true

var is_drone = false

const respawn_time = 5
var _killer

var round_ended = false


signal health_changed()
signal powered_up(powerup)
signal powered_down(powerup)

# Use sync because it will be called everywhere
sync func fire():
	var ball_name = get_name() + str(ball_index)
	var ball_transform = $rotation_helper/muzzle.global_transform
	var ball = _ball.instance()
	ball.set_name(ball_name) # Ensure unique name for the bomb
	ball.set_global_transform(ball_transform)
	ball.start_point = ball.get_global_transform().origin
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
	ball_index+=1
	
	$AudioStreamPlayer3D.play(0.0)

# Set the colors of the player(called by gamestate)
func set_colors(body, outline):
	player_color = body
	outline_color = outline
	for i in $rotation_helper/faces.get_children():
		if i.name != outline: i.hide()
		else: i.show()
	for j in $outlines.get_children():
		if j.name != outline: j.hide()
		else: j.show()
	for k in $bodies.get_children():
		if k.name != body: k.hide()
		else: k.show()

func resize():
	var screenSize = get_viewport().size
	if is_network_master():
		$rotation_helper/Camera/crosshairs_outline.position = Vector2(screenSize.x/2,screenSize.y/2)
		$rotation_helper/Camera/crosshairs_outline.self_modulate = colors[outline_color]
		$rotation_helper/Camera/crosshairs_outline/crosshairs.modulate = colors[player_color]
	
	#prints("crosshairs position: ", $PlayerName/rotation_helper/Camera/crosshairs.rect_position)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_tree().connect("screen_resized", self, "resize")
	resize()
	
	gamestate.connect("round_ended", self, "end_of_round")
	
	$fire_timer.wait_time = fire_wait_time
	$health_timer.wait_time = health_regen_time
	$health_timer.start(health_regen_time)
	#$PlayerName/Sprite.modulate = colors[player_color]
	
	camera = $rotation_helper/Camera
	rotation_helper = $rotation_helper
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	slave_pos = self.get_translation()
	
	if (is_network_master()):
		if (!$rotation_helper/Camera.current):
			$rotation_helper/Camera.make_current()
		$outlines.hide()
	pass # Replace with function body.

func _input(event):
	if is_network_master() and !round_ended:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_helper.rotate_x(deg2rad(event.relative.y * mouse_sensitivity))
			self.rotate_y(deg2rad(event.relative.x * mouse_sensitivity * -1))
			
			var camera_dir = rotation_helper.rotation_degrees
			camera_dir.x = clamp(camera_dir.x, -89.99, 89.99)
			rotation_helper.rotation_degrees = camera_dir
			rset("slave_aim",rotation_helper.rotation_degrees)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var sink = velocity.y # we want to stor eonly the downward velocity for this game ( you would not normaly do this
	# This removes any latteral movements we dont want
	velocity = Vector3( 0.0, sink , 0.0 )
	if is_on_floor():
		velocity += gravity * 0.1 * delta
	else:
		velocity += gravity * delta

	if (is_network_master() and health > 0 and !round_ended):
		# get teh imput here

		var firing = Input.is_action_pressed("fire")
		
		#----- Walking -----
		dir = Vector3()
		var cam_xform = camera.get_global_transform()
		
		var input_movement_vector = Vector2()
		if (Input.is_action_pressed("move_left")):
			input_movement_vector.x -= 1 * speed
			#self.set_rotation( Vector3( 0 , -.5*PI , 0 ) )
		if (Input.is_action_pressed("move_right")):
			input_movement_vector.x += 1 * speed
			#self.set_rotation( Vector3( 0 , .5*PI , 0 ))
		if (Input.is_action_pressed("move_forward")):
			input_movement_vector.y += 1 * speed
			#self.set_rotation( Vector3( 0 , PI , 0 ) )
		if (Input.is_action_pressed("move_backward")):
			input_movement_vector.y -= 1 * speed
			#self.set_rotation( Vector3( 0 ,2*PI , 0 ) )
		
		input_movement_vector = input_movement_vector.normalized()
		
		# Basis vectors are already normalized.
		dir += -cam_xform.basis.z * input_movement_vector.y
		dir +=  cam_xform.basis.x * input_movement_vector.x
		#----------
			

		
		if (firing and not prev_firing): #semi-auto fire
			if can_fire:
				rpc("fire")
				$rotation_helper/Camera/crosshairs_outline.hide()
				#sets the rate of fire:
				#----------------------
				can_fire = false #disables firing until timer times out
				$fire_timer.start(fire_wait_time) #upon timeout, calls _on_timer_timeout() which sets can_fire to true

		prev_firing = firing
		
		#----- Movement -----
		
		dir.y = 0
		dir = dir.normalized()
		
		velocity.y += delta * gravity.y
		
		var hvel = velocity
		hvel.y = 0
		
		var target = dir
		target *= max_speed
		
		var accel
		if dir.dot(hvel) > 0:
			accel = Accel
		else:
			accel = Deaccel
		
		#prints("Player ", self, " speed: ", speed)
		
		hvel = hvel.linear_interpolate(target, accel * delta)
		velocity.x = hvel.x
		velocity.z = hvel.z
		
		rset("slave_motion", velocity)
		#var mpos : Vector3 = self.get_translation()
		rset("slave_pos", self.get_translation()  )
		rset("slave_dir" , self.get_rotation() )
	else:
		self.set_translation(slave_pos)
		self.set_rotation(slave_dir)
		get_node("rotation_helper").rotation_degrees = slave_aim
		velocity = slave_motion

	velocity = move_and_slide( velocity , Vector3.UP, 0.05,4,deg2rad(max_slope_angle))
	if (not is_network_master() ):
		slave_pos = self.get_translation() # To avoid jitter
#
	var pos = get_translation()
	var cam = get_tree().get_root().get_camera()
	var screenpos = cam.unproject_position(pos + Vector3(0,0.6,0))
	get_node("PlayerName").set_position(Vector2(screenpos.x , screenpos.y ) )
	if(Input.is_action_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if(Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
		if Input.is_action_pressed("fire"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_player_name(new_name):
	get_node("PlayerName/label").set_text(new_name)

func get_player_name():
	return $PlayerName/label.text

func die(killer):
	#prints(self, " was killed by: ", killer)
	#if killer._get("kills") != null:
	
	killer.kills += 1
	killer.kills_this_life += 1
	
	
	get_tree().get_root().get_node("/root/gamestate").count_kills()
	hide()
	if (is_network_master()):
		killer.get_node("rotation_helper/Camera").make_current()
		killer.get_node("outlines").hide()
		killer.get_node("outline_timer").start(respawn_time)
	#$BehaviorTree.enabled     = false
	$CollisionShape.disabled  = true
	$CollisionShape2.disabled = true
	$rotation_helper/Camera/crosshairs_outline.hide()
	$respawn_Timer.connect("timeout", self, "_on_respawn_timer_timeout")
	$respawn_Timer.one_shot = true
	$respawn_Timer.start(respawn_time)
	
	kills_this_life = 0

func spawn(transform):
	health = _health
	emit_signal("health_changed")
	global_transform = transform
	show()
	if (is_network_master()):
		$rotation_helper/Camera.make_current()
	#$BehaviorTree.enabled     = true
	$rotation_helper/Camera/crosshairs_outline.show()
	$CollisionShape.disabled  = false
	$CollisionShape2.disabled = false
	

func damage(by_who, damage):
	health -= damage
	#prints(self, " damaged by ", by_who, " Health: ", health)
	emit_signal("health_changed")
	if health <= 0:
		die(by_who)
	if health > _health:
		health = _health
	$health_timer.start(health_regen_time)

func _on_respawn_timer_timeout():
	get_tree().get_root().get_node("/root/gamestate").respawn(self)
	pass

func _on_fire_timer_timeout():
	can_fire = true
	$rotation_helper/Camera/crosshairs_outline.show()
	pass # Replace with function body.


func _on_outline_timer_timeout():
	$outlines.show()
	pass # Replace with function body.

func end_of_round(winner):
	round_ended = true
	$rotation_helper/Camera/crosshairs_outline.hide()

func _on_health_timer_timeout():
	damage(self, -health_regen_amount)
	pass # Replace with function body.
