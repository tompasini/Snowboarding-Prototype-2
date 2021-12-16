extends KinematicBody2D

var velocity = Vector2(0, 0)
var speed = 0
var JUMPFORCE = -900 + (speed/2)
const GRAVITY = 75
const BASE_SPEED = 450
const POLE_MODIFIER = 350

func _physics_process(delta):
	var normal: Vector2 = get_floor_normal()
	if(normal):	
		$AnimatedSprite.rotation = assign_rotation(normal, 90)
	if (Input.is_action_pressed("right") && speed <= 0):
		speed = BASE_SPEED
		$AnimatedSprite.flip_h = false
	elif(Input.is_action_pressed("left") && speed >= 0):
		speed = -BASE_SPEED
		$AnimatedSprite.flip_h = true
	elif(Input.is_action_pressed("reset")):
		get_tree().reload_current_scene()

	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y = JUMPFORCE
		if(!$AnimatedSprite.flip_h && speed == 0):
			speed = BASE_SPEED
		elif($AnimatedSprite.flip_h && speed == 0):
			speed = -BASE_SPEED
	
	set_velocity()
	
	if(speed > BASE_SPEED && normal.x == 0):
		slow_down()
		
	$Speed.text = str(speed)
	
func body_enter(body):
	var isPole = body.is_in_group("pole")
	var direction = $AnimatedSprite.flip_h
	if(isPole):
		if(!direction):
			speed = (BASE_SPEED + POLE_MODIFIER)
		else:
			speed = -(BASE_SPEED + POLE_MODIFIER)
			
func set_velocity():
	velocity.y += GRAVITY
	velocity.x = speed
	velocity = move_and_slide(velocity, Vector2.UP)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		body_enter(collision.collider)
		
func assign_rotation(normal, degrees):
	var offset: float = deg2rad(degrees)
	if(normal.x > 0):
		speed += 5
	return normal.angle() + offset
	
func slow_down():
	if($Timer.time_left == 0):
			speed -= 50
			$Timer.start()
