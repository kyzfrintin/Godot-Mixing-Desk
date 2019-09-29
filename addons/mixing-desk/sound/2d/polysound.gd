extends Node2D

var dvols = []
var dpitches = []
var root
export(NodePath) var spawn_node
export var autoplay : bool
export var volume_range : float
export var pitch_range : float

func _ready():
	for i in get_children():
		dvols.append(i.volume_db)
		dpitches.append(i.pitch_scale)
	if spawn_node:
		if typeof(spawn_node) == TYPE_NODE_PATH:
			root = get_node(spawn_node)
		elif typeof(spawn_node) == TYPE_OBJECT:
			root = spawn_node
	else:
		root = Node2D.new()
		add_child(root)
		root.name = "root"
	if autoplay:
		play()

func stop():
	for i in root.get_children():
		i.queue_free()

func _iplay(sound):
	var snd = sound.duplicate()
	if spawn_node:
		snd.position = global_position
	root.add_child(snd)
	snd.play()
	snd.set_script(preload("res://addons/mixing-desk/sound/2d/spawn_sound.gd"))
	snd.setup()
	
func play(ran=true):
	for i in get_children():
		if i.name == "root": return
		if ran:
			_randomise(i)
		_iplay(i)
		
func _randomise(sound):
	var dvol = dvols[sound.get_index()]
	var dpitch = dpitches[sound.get_index()]
	var newvol = (dvol + _range(volume_range))
	var newpitch = (dpitch + _range(pitch_range))
	sound.volume_db = newvol
	sound.pitch_scale = newpitch
	
func _range(item : float) -> float:
	return rand_range(-item,item)
