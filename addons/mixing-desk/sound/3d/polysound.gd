extends Spatial

var dvols = []
var dpitches = []
var root
export(NodePath) var spawn_node
export var autoplay : bool
export var volume_range : float
export var pitch_range : float

func _ready():
	for i in get_children():
		if i.get("unit_db") != null:
			dvols.append(i.unit_db)
			dpitches.append(i.pitch_scale)
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
	root.add_child(snd)
	if spawn_node:
		snd.global_transform.origin = global_transform.origin
	snd.play()
	snd.set_script(preload("res://addons/mixing-desk/sound/3d/spawn_sound.gd"))
	snd.setup()
	
func play(ran=true):
	for i in get_children():
		if i.name == "root": return
		if ran:
			_randomise_pitch_and_vol(i)
		_iplay(i)
		
func _randomise_pitch_and_vol(sound):
	var dvol = sound.get_parent().dvols[sound.get_index()]
	var dpitch = sound.get_parent().dpitches[sound.get_index()]
	var newvol = (dvol + rand_range(-volume_range,volume_range))
	var newpitch = (dpitch + rand_range(-pitch_range,pitch_range))
	sound.unit_db = newvol
	sound.pitch_scale = newpitch
