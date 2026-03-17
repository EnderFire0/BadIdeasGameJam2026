extends Node

var screenSize : Vector2;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screenSize = get_viewport().get_visible_rect().size;
	$Camera2D.enabled = true;
	$Camera2D.position = $Player.position;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	moveCamera(delta);

func moveCamera(delta: float) -> void:
	$Camera2D.position = $Camera2D.position.lerp($Player.position, 4 * delta)
