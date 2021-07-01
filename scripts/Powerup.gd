extends Area

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var bodies = []
var open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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


func _on_Powerup_body_entered(body):
	pass # Replace with function body.
