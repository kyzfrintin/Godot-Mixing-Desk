extends KinematicBody2D

var speed = 4

const SMIN = 1.8
const SMAX = 4.5

func _process(delta):
	# set running or walking
	if Input.is_action_pressed("gp_run"):
		if speed < SMAX:
			speed = lerp(speed, SMAX, 0.1)
	else:
		if speed > SMIN:
			speed = lerp(speed, SMIN, 0.1)
	# move on input
	if Input.is_action_pressed("gp_up"):
		move_and_collide(Vector2(0,speed*-1))
	if Input.is_action_pressed("gp_left"):
		move_and_collide(Vector2(speed*-1, 0))
	if Input.is_action_pressed("gp_down"):
		move_and_collide(Vector2(0,speed))
	if Input.is_action_pressed("gp_right"):
		move_and_collide(Vector2(speed, 0))
	
	