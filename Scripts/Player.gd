extends KinematicBody2D

export var thrust = 100
export var turn_spd = 2.6

onready var view_size = get_viewport_rect().size
onready var smoke = get_node("Smoke")

var vel = Vector2()
var rot = 0
var pos = Vector2()
var acc = Vector2()


func _ready():
	pos = position
	rot = rotation
	
	set_process(true)
	set_process_input(true)

func _process(delta):

	if Input.is_action_pressed("ui_left"):
		rot -= turn_spd * delta
		
	if Input.is_action_pressed("ui_right"):
		rot += turn_spd * delta
	
		
	if Input.is_action_pressed("ui_up"):
		acc = Vector2(thrust, 0).rotated(rot)
		smoke.emitting = 1
#		smoke.rotation_degrees = 0
#		smoke.rotate(rot)
	elif Input.is_action_pressed("ui_down"):
		acc = -Vector2(thrust, 0).rotated(rot)		
		smoke.emitting = 1
#		smoke.rotation_degrees = 180
#		smoke.rotate(rot)
	else:
		if(vel.length() >0):
			vel -= vel
		smoke.emitting = 0
#		smoke.rotation = 0
		
	
	rotation = rot
	vel += acc * delta

	move_and_slide(vel)
