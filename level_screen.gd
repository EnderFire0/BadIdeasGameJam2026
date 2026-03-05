extends Node

@export var geometry : Array[Rect2] = [Rect2(Vector2(100, 200), Vector2(100, 50))];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.size = get_viewport().get_visible_rect().size;
	draw_geometry();

func draw_geometry() -> void:
	for shape : Rect2 in geometry:
		var body : StaticBody2D = StaticBody2D.new();
		var new_shape : CollisionShape2D = CollisionShape2D.new();
		var rect : RectangleShape2D = RectangleShape2D.new();
		rect.size = shape.size;
		new_shape.set_shape(rect);
		new_shape.position = shape.position;
		body.add_child(new_shape);
		add_child(body);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
