extends Area

# Declare member variables here. Examples:
var speed = 10
var creator = null
var from_player
var start_point = Vector3()
var max_distance = 512
var color
var outline
export var damage = 1

var has_hit = false
var bodies = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var forward = global_transform.basis.z.normalized()
	global_translate(forward * speed * delta)
	
	if global_transform.origin.distance_to(start_point) > max_distance:
		rpc("queue_free()")
		queue_free()
	pass

sync func _on_ball_body_entered(body):
	#prints(body, " : ", creator)
	#prints("Body entered: ", body)
	
	if (body != creator):
		#prints(body, " is not creator, ", creator)
		if body.has_method("damage") and !has_hit:
			#prints("Hit body: ", body)
			body.rpc("damage",creator, damage)
			body.damage(creator, damage)
		has_hit = true
		disconnect("_on_body_entered", self, "_on_ball_body_entered")
		$color.get_node(color).get_node("ball").hide()
		$color.get_node(color).get_node("splat").show()
		$outline.get_node(outline).get_node("ball").hide()
		$outline.get_node(outline).get_node("splat").show()
		$AudioStreamPlayer3D.play(0.0)
		$Timer.start(0.1)
		
		"""$RayCast.force_raycast_update()
		var up = Vector3(0, 1, 0)
		var normal = $RayCast.get_collision_normal()
		var axis = up.cross(normal).normalized()
		var angle = up.angle_to(normal)
		rotate(axis, angle)"""
		
		
		speed = 0

func kill():
	rpc("queue_free()")
	queue_free()

func _on_Timer_timeout():
	kill()
	pass # Replace with function body.


func _on_ball_body_shape_entered(body_id, body, body_shape, area_shape):
	pass # Replace with function body.
