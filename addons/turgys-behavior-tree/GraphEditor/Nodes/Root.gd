tool
extends GraphNode

signal delete_node(node)
var tag = "root"
var slot_counter = 0;
var slot_array = [];

func _ready():
	pass

func _on_Root_close_request():
	self.clear_slot(0);
	emit_signal("delete_node",self)
	self.queue_free()
	pass # Replace with function body.
