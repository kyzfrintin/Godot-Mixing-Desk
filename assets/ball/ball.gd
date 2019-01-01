tool
extends RigidBody2D

export(Color) var colour

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.modulate = colour
	linear_velocity.x = rand_range(-75,75)
	linear_velocity.y = rand_range(-75,75)
	angular_velocity = rand_range(0,70)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
