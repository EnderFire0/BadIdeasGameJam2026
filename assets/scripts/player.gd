extends Area2D

@export var playerMaxSpeed : float = 200;
@export var playerBaseAccel : float = 300;
var playerVel : Vector2;
var onGround : bool;
var isJumping : bool;
var isCrouching : bool;
var facing : String;
var colliding : Dictionary = {
	"bottom" : 0,
	"crouchLeft" : 0,
	"crouchRight" : 0,
	"crouchTop" : 0,
	"defaultLeft" : 0,
	"defaultRight" : 0,
	"defaultTop" : 0
}

const playerSize : Vector2 = Vector2(48, 26);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerVel = Vector2.ZERO;
	onGround = false;
	isJumping = false;
	isCrouching = false;
	facing = "right";
	$AnimatedSprite2D.animation = "moveRight";

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("crouch") && onGround):
		isCrouching = true;
		playerMaxSpeed /= 2;
	if (!Input.is_action_pressed("crouch") && isCrouching && !colliding["defaultTop"]):
		isCrouching = false;
		playerMaxSpeed *= 2;
	movement(delta);
	update_animation();

func get_velocity_x_sign() -> int:
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
		playerXAccel = -playerBaseAccel * delta * (1 if get_velocity_x_sign() == -1 else 2);
		facing = "left";
	elif (Input.is_action_pressed("move_right")):
		playerXAccel = playerBaseAccel * delta * (1 if get_velocity_x_sign() == 1 else 2);
		facing = "right";
	else:
		speedDecaySign = -get_velocity_x_sign();
		playerXAccel = 1.5 * playerBaseAccel * speedDecaySign * delta;
	#for when player starts to crouch
	if (abs(playerVel.x) > playerMaxSpeed):
		playerVel.x = max(playerMaxSpeed, (abs(playerVel.x) - 0.75 * playerBaseAccel * delta)) * get_velocity_x_sign();
	else:
		playerVel.x = clampf(playerVel.x + (playerXAccel), -playerMaxSpeed, playerMaxSpeed);
	#for cases where speed is small enough to not decay to 0(it fixes smth, idk)
	if (sign(playerVel.x) == speedDecaySign):
		playerVel.x = 0;
	
	# movement in the y-direction
	if (onGround):
		if (Input.is_action_just_pressed("jump")):
			isJumping = true;
			playerVel.y = -playerBaseAccel * 1.2;
			onGround = false;
		else:
			playerVel.y = 0;
	elif (Input.is_action_just_released("jump")):
		isJumping = false;
		if (playerVel.y < 0):
			playerVel.y = 0;
			playerVel.y = min(playerVel.y + playerBaseAccel * delta, playerBaseAccel * 4);
	else:
		playerVel.y = min(playerVel.y + playerBaseAccel * 2 * delta, playerBaseAccel * 4);
	
	if (!isCrouching):
		if (colliding["defaultLeft"]):
			playerVel.x = max(0, playerVel.x);
		if (colliding["defaultRight"]):
			playerVel.x = min(0, playerVel.x);
		if (colliding["defaultTop"]):
			playerVel.y = max(0, playerVel.y);
	else:
		if (colliding["crouchLeft"]):
			playerVel.x = max(0, playerVel.x);
		if (colliding["crouchRight"]):
			playerVel.x = min(0, playerVel.x);
		if (colliding["crouchTop"]):
			playerVel.y = max(0, playerVel.y);
	if (!isJumping):
		if (colliding["bottom"]):
			playerVel.y = min(0, playerVel.y);
	
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

func _on_body_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var collisionBox = shape_owner_get_owner(shape_find_owner(local_shape_index));
	var bodyShapeNode : CollisionShape2D = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index));
	var bodyRect : Rect2 = bodyShapeNode.get_shape().get_rect();
	
	if (collisionBox == $CrouchCollisionTop):
		colliding["crouchTop"] += 1;
	elif (collisionBox == $CrouchCollisionLeft):
		position.x = bodyShapeNode.position.x + (bodyRect.size.x / 2) + (playerSize.x / 2);
		colliding["crouchLeft"] += 1;
	elif (collisionBox == $CrouchCollisionRight):
		position.x = bodyShapeNode.position.x - (bodyRect.size.x / 2) - (playerSize.x / 2);
		colliding["crouchRight"] += 1;
	elif (collisionBox == $DefaultCollisionTop):
		colliding["defaultTop"] += 1;
	elif (collisionBox == $DefaultCollisionLeft):
		if (!isCrouching):
			position.x = bodyShapeNode.position.x + (bodyRect.size.x / 2) + (playerSize.x / 2);
		colliding["defaultLeft"] += 1;
	elif (collisionBox == $DefaultCollisionRight):
		if (!isCrouching):
			position.x = bodyShapeNode.position.x - (bodyRect.size.x / 2) - (playerSize.x / 2);
		colliding["defaultRight"] += 1;
	elif ((collisionBox == $CollisionBottom) && (position.y - playerVel.y) < (bodyShapeNode.position.y - (bodyRect.size.y / 2))):
		colliding["bottom"] += 1;
		position.y = bodyShapeNode.position.y - (bodyRect.size.y / 2) - (playerSize.y / 2);
		onGround = true;

func _on_body_shape_exited(_body_rid: RID, _body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	var collisionBox : CollisionShape2D = shape_owner_get_owner(shape_find_owner(local_shape_index));

	if (collisionBox == $CrouchCollisionTop):
		colliding["crouchTop"] -= 1;
	elif (collisionBox == $CrouchCollisionLeft):
		colliding["crouchLeft"] -= 1;
	elif (collisionBox == $CrouchCollisionRight):
		colliding["crouchRight"] -= 1;
	elif (collisionBox == $DefaultCollisionTop):
		colliding["defaultTop"] -= 1;
	elif (collisionBox == $DefaultCollisionLeft):
		colliding["defaultLeft"] -= 1;
	elif (collisionBox == $DefaultCollisionRight):
		colliding["defaultRight"] -= 1;
	elif (collisionBox == $CollisionBottom):
		colliding["bottom"] -= 1;
		onGround = false;
