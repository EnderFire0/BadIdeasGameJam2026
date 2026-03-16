extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.size = get_viewport().get_visible_rect().size;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
