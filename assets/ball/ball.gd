tool
extends RigidBody2D

var collided : bool = false
export(Color) var colour

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.modulate = colour
	linear_velocity.x = rand_range(-75,75)
	linear_velocity.y = rand_range(-75,75)
	angular_velocity = rand_range(0,70)
	
func _physics_process(delta):
	var colliders = get_colliding_bodies()
	if colliders.size() > 0:
		if !collided:
			print('boop')
			$sounds._play_sound_full(0)
			collided = true
	else:
		collided = false
	colliders.clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
