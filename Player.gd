extends KinematicBody2D

var velocity = Vector2(0, 0)
var speed = 0
var boostPower = 1000
var jumpCount = 2
var firstJump = -900 + (speed/2)
var secondJump = -900
const GRAVITY = 75
const BASE_SPEED = 450
const POLE_MODIFIER = 350

enum States {ON_GROUND, IN_AIR}

var _state = States.ON_GROUND

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
		
	if(is_on_floor()):
		if(_state != States.ON_GROUND):
			_state = States.ON_GROUND
			jumpCount = 2
		$AnimatedSprite.play('idle')		

	if(Input.is_action_just_pressed("jump") && jumpCount != 0):
		_state = States.IN_AIR
		velocity.y = -1
		if(jumpCount == 2):
			velocity.y += firstJump
		else:
			velocity.y += secondJump
		
		jumpCount -= 1
		if(!$AnimatedSprite.flip_h && speed == 0):
			speed = BASE_SPEED
		elif($AnimatedSprite.flip_h && speed == 0):
			speed = -BASE_SPEED
	
	if(Input.is_action_pressed("boost") && boostPower > 0 && speed != 0):
		boostPower -= 10
		$BoostBar.value = boostPower
		increase_speed(10, $AnimatedSprite.flip_h)
	
	set_velocity()
	
	
	if(speed > BASE_SPEED && normal.x == 0):
		slow_down()
		
	$Speed.text = str(speed)
	
#	tricks
	if(Input.is_action_just_pressed("backflip") && !is_on_floor()):
		$AnimatedSprite.play('backflip')
	
#func body_enter(body):
#	print('pole stuff')
#	var isPole = body.is_in_group("pole")
#	var direction = $AnimatedSprite.flip_h
#	if(isPole):
#		if(!direction):
#			speed = (BASE_SPEED + POLE_MODIFIER)
#		else:
#			speed = -(BASE_SPEED + POLE_MODIFIER)
			
func increase_speed(modifier, direction):
	if(!direction):
		speed += modifier
	else:
		speed += -modifier

func set_velocity():
	velocity.y += GRAVITY
	velocity.x = speed
	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.x = lerp(velocity.x,0,0.2)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
#		body_enter(collision.collider)
		
func assign_rotation(normal, degrees):
	var offset: float = deg2rad(degrees)
	if(normal.x > 0):
		speed += 5
	return normal.angle() + offset
	
func slow_down():
	if($Timer.time_left == 0):
			speed -= 50
			$Timer.start()


func _on_AnimatedSprite_animation_finished():
	if($AnimatedSprite.animation == 'backflip'):
		if(boostPower <= 700):
			boostPower += 300
			$BoostBar.value = boostPower
		else:
			boostPower += (1000 - boostPower)
			$BoostBar.value = boostPower
		$AnimatedSprite.play('idle')
		
