extends Area2D

@export var playerMaxSpeed : float = 200;
@export var playerBaseAccel : float = 300;
var playerVel : Vector2;
var onGround : bool;
var isJumping : bool;
var isCrouching : bool;
var facing : String;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerVel = Vector2.ZERO;
	onGround = true;
	isJumping = false;
	isCrouching = false;
	facing = "right";
	$AnimatedSprite2D.animation = "moveRight";
	pass # Replace with function body.

func get_velocity_sign() -> int:
	if (playerVel.x < 0):
		return -1;
	elif (playerVel.x > 0):
		return 1;
	else:
		return 0;

func movement(delta: float) -> void:
	# movement in the x-direction
	var playerXAccel : float;
	var speedDecaySign : float = 0;
	if (Input.is_action_pressed("move_left") && Input.is_action_pressed("move_right")):
		playerXAccel = -playerBaseAccel * sign(playerVel.x) * delta;
	elif (Input.is_action_pressed("move_left")):
		playerXAccel = -playerBaseAccel * delta;
		facing = "left";
	elif (Input.is_action_pressed("move_right")):
		playerXAccel = playerBaseAccel * delta;
		facing = "right";
	else:
		speedDecaySign = -get_velocity_sign();
		playerXAccel = 1.5 * playerBaseAccel * speedDecaySign * delta;
	#for when player starts to crouch
	if (abs(playerVel.x) > playerMaxSpeed):
		playerVel.x = max(playerMaxSpeed, (abs(playerVel.x) - 0.75 * playerBaseAccel * delta)) * get_velocity_sign();
	else:
		playerVel.x = clampf(playerVel.x + (playerXAccel), -playerMaxSpeed, playerMaxSpeed);
	#for cases where speed is small enough to not decay to 0(it fixes smth, idk)
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

func update_animation() -> void:
	if (facing == "left"):
		if (isCrouching):
			$AnimatedSprite2D.animation = "crouchLeft";
		else:
			$AnimatedSprite2D.animation = "moveLeft";
	else:
		if (isCrouching):
			$AnimatedSprite2D.animation = "crouchRight";
		else:
			$AnimatedSprite2D.animation = "moveRight";

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("crouch") && onGround):
		isCrouching = true;
		playerMaxSpeed /= 2;
	if (Input.is_action_just_released("crouch") && isCrouching):
		isCrouching = false;
		playerMaxSpeed *= 2;
	movement(delta);
	update_animation();
