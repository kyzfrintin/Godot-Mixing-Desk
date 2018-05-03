extends KinematicBody2D

export var thrust = 300
export var max_spd = 6
export var turn_spd = 2.6

onready var view_size = get_viewport_rect().size
onready var smoke = get_node("Smoke")

var vel = Vector2()
var rot = 0
var pos = Vector2()
var acc = Vector2()


func _ready():
	pos = view_size / 2
	pass

func _process(delta):

	if Input.is_action_pressed("gp_turn_left"):
		rot -= turn_spd * delta
		
	if Input.is_action_pressed("gp_turn_right"):
		rot += turn_spd * delta
	
		
	if Input.is_action_pressed("gp_forwards"):
		acc = Vector2(thrust, 0).rotated(rot)
		#smoke.emitting = 1
	else:
		acc = Vector2(0,0)
		#smoke.emitting = 0
	
	rotation = rot
	vel += acc * delta
	pos += vel * delta
	position = pos
