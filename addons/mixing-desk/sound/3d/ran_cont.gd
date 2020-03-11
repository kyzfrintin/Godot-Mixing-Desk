extends Spatial

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
		dvols.append(i.unit_db)
		dpitches.append(i.pitch_scale)
		soundlist.append(i)
	if spawn_node:
		if typeof(spawn_node) == TYPE_NODE_PATH:
			root = get_node(spawn_node)
		elif typeof(spawn_node) == TYPE_OBJECT:
			root = spawn_node
	else:
		root = Spatial.new()
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
		snd.global_transform.origin = global_transform.origin
	root.add_child(snd)
	snd.play()
	snd.set_script(preload("res://addons/mixing-desk/sound/3d/spawn_sound.gd"))
	snd.setup()
	
func play(num=0, ran=true):
	if num == 0:
		num = sound_number
	if num > 1:
		for i in range(0, num):
			var ransnd = _get_ransnd()
			_iplay(ransnd)
	else:
		var ransnd = _get_ransnd()
		_iplay(ransnd)
		
func _get_ransnd(ran=true):
	var chance = randi() % soundlist.size()
	var ransnd = soundlist[chance]
	if ran:
		_randomise(ransnd)
	return ransnd
		
func _randomise(sound):
	var dvol = dvols[sound.get_index()]
	var dpitch = dpitches[sound.get_index()]
	var newvol = (dvol + _range(volume_range))
	var newpitch = (dpitch + _range(pitch_range))
	sound.unit_db = newvol
	sound.pitch_scale = newpitch
	
func _range(item : float) -> float:
	return rand_range(-item,item)
