extends TextureButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_facemaze_icon_pressed():
	get_tree().get_root().get_node("UI/Windows/lobby").popup_centered()


func _on_facemaze_icon_button_down():
	
	get_tree().get_root().get_node("UI/Windows/lobby").popup_centered()
	pass # Replace with function body.
