extends Area

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var bodies = []
var open = false
var picked_up = false
export(String, "speed", "rapidfire", "health", "armor", "jump", "omnishot", "poison") var pickup = "speed"
export(float) var value = 5
export(float) var time = 10
export(bool)  var permanent = true
var alive = 0

var items = ["speed", "rapidfire", "health", "armor", "jump", "omnishot", "poison"]

var smiloid_script = preload("res://scripts/smiloid.gd")
var target
onready var y_trans = $capsule.translation.y
var attributes = []


func set_pickup():
	for i in $capsule/top_cap.get_children():
		i.hide()
	for i in $capsule/bot_cap.get_children():
		i.hide()
	for i in $capsule/icon.get_children():
		i.hide()
	match pickup:
		"speed":
			$capsule/top_cap/blu_hemi.show()
			$capsule/bot_cap/blu_hemi.show()
			$capsule/icon/speed.show()
		"rapidfire":
			$capsule/top_cap/red_cone.show()
			$capsule/bot_cap/red_cone.show()
			$capsule/icon/rapidfire.show()
		"health":
			$capsule/top_cap/blu_cone.show()
			$capsule/bot_cap/blu_cone.show()
			$capsule/icon/health.show()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.one_shot = true
	set_pickup()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !picked_up:
		alive += delta
		$capsule.translation.y = y_trans + sin(alive/1.5)/100
		$capsule.rotation.x = sin(alive)/100
		$capsule.rotation.z = cos(alive)/100
	#	prints($capsule.translation.y)
	pass

func _on_approach_body_entered(body):
	if body is KinematicBody:
		if bodies.size() < 1:
			var scrub = $AnimationPlayer.current_animation_length - $AnimationPlayer.current_animation_position
			$AnimationPlayer.play("open")
			$AnimationPlayer.seek(scrub)
		bodies.append(body)
	pass # Replace with function body.


func _on_approach_body_exited(body):
	if body is KinematicBody:
		bodies.erase(body)
		if bodies.size() < 1:
			var scrub = $AnimationPlayer.current_animation_length - $AnimationPlayer.current_animation_position
			$AnimationPlayer.play("close")
			$AnimationPlayer.seek(scrub)
	pass # Replace with function body.


func _on_pickup_body_entered(body):
	target = body
	if target is smiloid_script and !picked_up:
		#prints(target, " is smiloid script.")
		match pickup:
			"speed":
				speed()
			"rapidfire":
				rapidfire()
			"health":
				health()
				pass
		target.add_child(self) 
		disconnect("body_entered", self, "_on_Powerup_body_entered")
		picked_up = true
		target.emit_signal("powered_up", pickup)
		hide()
		pass # Replace with function body.

func _on_Timer_timeout():
	match pickup:
		"speed":
			remove_speed()
		"rapidfire":
			remove_rapidfire()
			pass
	target.emit_signal("powered_down", pickup)
	queue_free()
	pass # Replace with function body.


func rapidfire():
	attributes.append(target.fire_wait_time)
	target.rset("fire_wait_time", target.fire_wait_time / value)
	target.fire_wait_time = target.fire_wait_time / value
	prints("Attributes: ", attributes)
	$Timer.start(time)
	#$Timer.connect("timeout",self,"remove_rapidfire")
	pass

func remove_rapidfire():
	target.rset("fire_wait_time", attributes[0])
	target.fire_wait_time = attributes[0]
	attributes.clear()

func speed():
	attributes.append(target.max_speed)
	target.rset("max_speed", target.max_speed + value)
	target.max_speed = target.max_speed + value 
	#prints("player ", target, "'s new speed: ", target.speed)
	$Timer.start(time)
	#$Timer.connect("timeout",self,"remove_speed")
	pass

func remove_speed():
	target.rset("max_speed", attributes[0])
	target.max_speed = attributes[0]
	target.emit_signal("powered_down", "speed")
	attributes.clear()
	pass

func health():
	target.damage(target,-50)

func armor():
	pass
