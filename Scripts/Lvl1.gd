extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		pass
