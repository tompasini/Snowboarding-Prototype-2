extends KinematicBody2D

var velocity = Vector2(0, 0)
var speed = 0
var boostPower = 0
var maxBoostPower = 500
var jumpCount = 2
var jumpHeight = -700
var boostJumped
var timer = 10
const GRAVITY = 75
const BASE_SPEED = 300
const POLE_MODIFIER = 175

enum States {ON_GROUND_IDLE, ON_GROUND_RIDING, IN_AIR}

var _state = States.ON_GROUND_IDLE

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
		set_ground_state(normal)

	if(Input.is_action_just_pressed("jump") && jumpCount != 0):
		jump()
	
	if(Input.is_action_pressed("boost") && boostPower > 0 && speed != 0):
		if(Input.is_action_just_pressed("jump") && jumpCount > 0):
			boostJumped = true
		if(boostJumped && _state == States.IN_AIR):
			$AnimatedSprite.play("jump")
		else:
			$AnimatedSprite.play("squat")
		boostPower -= 10
		$BoostBar.value = boostPower
		increase_speed(10, $AnimatedSprite.flip_h)
	
	set_velocity()
	
	
	if(speed > BASE_SPEED && normal.x == 0):
		slow_down()
		
	$Speed.text = str(speed)
	
#	tricks
	if(_state == States.IN_AIR):
		if(Input.is_action_just_pressed("360")):
			$AnimatedSprite.play('360')
		if(Input.is_action_pressed('grab') && Input.is_action_pressed('right')):
			$AnimatedSprite.play('nose grab')
			continuous_boost_power_modifier(5)
		if(Input.is_action_pressed('christ') && Input.is_action_pressed('right')):
			$AnimatedSprite.play('christ')
			
func continuous_boost_power_modifier(modifier):
	boostPower += modifier
	$BoostBar.value = boostPower
	
func _on_AnimatedSprite_animation_finished():
	if($AnimatedSprite.animation == '360'):
		boostPower = (maxBoostPower / 2)
		$BoostBar.value = boostPower
	if($AnimatedSprite.animation == 'christ'):
		boostPower = maxBoostPower
		$BoostBar.value = boostPower
	
#func body_enter(body):
##	print('pole stuff')
##	var isPole = body.is_in_group("pole")
##	var direction = $AnimatedSprite.flip_h
##	if(isPole):
##		if(!direction):
##			speed = (BASE_SPEED + POLE_MODIFIER)
##		else:
##			speed = -(BASE_SPEED + POLE_MODIFIER)
			
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
	if($SlowDownTimer.time_left == 0):
			speed -= 50
			$SlowDownTimer.start()
		
func jump():
	velocity.y = -1
	_state = States.IN_AIR
	if(jumpCount == 2):
		velocity.y += (jumpHeight + -(speed/2))
	else:
		velocity.y += jumpHeight
	jumpCount -= 1
	$AnimatedSprite.play('jump')
	if(!$AnimatedSprite.flip_h && speed == 0):
		speed = BASE_SPEED
	elif($AnimatedSprite.flip_h && speed == 0):
		speed = -BASE_SPEED
		
func set_ground_state(normal):
	if(boostJumped):
		boostJumped = false
	if(_state != States.ON_GROUND_RIDING || _state != States.ON_GROUND_IDLE):
		if(speed || normal):
			_state = States.ON_GROUND_RIDING
			$AnimatedSprite.play("riding")
		else:
			_state = States.ON_GROUND_IDLE
			$AnimatedSprite.play("idle")
		if(jumpCount != 2):
			jumpCount = 2


func _on_FinishFlag_body_exited(body):
	if(body.is_in_group('player')):
		speed = 0
		$Countdown.start()
		

func _on_Countdown_timeout():
	SceneManager.next_level()
