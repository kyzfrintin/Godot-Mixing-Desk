extends Node2D

var dvols = []
var dpitches = []
var soundlist = []
var root
export(NodePath) var spawn_node
export var autoplay : bool
export var volume_range : float
export var pitch_range : float
export var sound_number : int

func _ready():
	for i in get_children():
		dvols.append(i.volume_db)
		dpitches.append(i.pitch_scale)
		soundlist.append(i)
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
	root.add_child(snd)
	if spawn_node:
		snd.position = global_position
	snd.play()
	snd.set_script(preload("res://addons/mixing-desk/sound/2d/spawn_sound.gd"))
	snd.setup()

func play(num=0):
	if num == 0:
		num = sound_number
	randomize()
	for i in range(0, num):
		var ransnd = _get_ransnd()
		ransnd.play()
		yield(ransnd, "finished")
		
func _get_ransnd(ran=true):
	var chance = randi() % soundlist.size()
	var ransnd = soundlist[chance]
	if ran:
		_randomise_pitch_and_vol(ransnd)
	return ransnd
		
func _randomise_pitch_and_vol(sound):
	var dvol = sound.get_parent().dvols[sound.get_index()]
	var dpitch = sound.get_parent().dpitches[sound.get_index()]
	var newvol = (dvol + rand_range(-volume_range,volume_range))
	var newpitch = (dpitch + rand_range(-pitch_range,pitch_range))
	sound.volume_db = newvol
	sound.pitch_scale = newpitch
