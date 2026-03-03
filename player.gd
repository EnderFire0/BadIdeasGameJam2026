extends Area2D

@export var playerMaxSpeed : float = 200;
@export var playerBaseAccel : float = 300;
var playerVel : Vector2;
var onGround : bool;
var isJumping : bool;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerVel = Vector2.ZERO;
	onGround = true;
	isJumping = false;
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# movement in the x-direction
	var playerXAccel : float;
	var speedDecaySign : float;
	if (Input.is_action_pressed("move_left") && Input.is_action_pressed("move_right")):
		playerXAccel = -playerBaseAccel * sign(playerVel.x) * delta;
	elif (Input.is_action_pressed("move_left")):
		playerXAccel = -playerBaseAccel * delta;
		$AnimatedSprite2D.animation = "moveLeft";
	elif (Input.is_action_pressed("move_right")):
		playerXAccel = playerBaseAccel * delta;
		$AnimatedSprite2D.animation = "moveRight";
	else:
		if (playerVel.x < 0):
			speedDecaySign = 1;
		elif (playerVel.x > 0):
			speedDecaySign = -1;
		else:
			speedDecaySign = 0;
		playerXAccel = 1.5 * playerBaseAccel * speedDecaySign * delta;
	playerVel.x = clampf(playerVel.x + (playerXAccel), -playerMaxSpeed, playerMaxSpeed);
	if (sign(playerVel.x) == speedDecaySign):
		playerVel.x = 0;
	
	# movement in the y-direction
	if (onGround):
		if (Input.is_action_pressed("jump")):
			isJumping = true;
			playerVel.y = -playerBaseAccel;
			onGround = false;
		else:
			playerVel.y = 0;
	elif (Input.is_action_just_released("jump") && (playerVel.y < 0)):
		playerVel.y = 0;
		playerVel.y = min(playerVel.y + playerBaseAccel * delta, playerBaseAccel * 4);
	else:
		playerVel.y = min(playerVel.y + playerBaseAccel * delta, playerBaseAccel * 4);
	
	position += playerVel * delta;
