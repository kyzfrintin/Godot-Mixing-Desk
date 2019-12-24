extends Node

var dvols = []
var dpitches = []
var soundlist = []
var timeroot
var root
var scattering : bool = false
export(NodePath) var spawn_node
export var autostart : bool = true
export var volume_range : float = 1.0
export var pitch_range : float= 1.0
export var voices : int = 5
export var min_time : float = 1
export var max_time : float = 5
export var timeout : float = 7
export var randomise : bool = true

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
	if autostart:
		play()

func _iplay(sound):
	var snd = sound.duplicate()
	root.add_child(snd)
	snd.play()
	snd.set_script(preload("res://addons/mixing-desk/sound/nonspatial/spawn_sound.gd"))
	snd.setup()
	
func play():
	if scattering:
		return
	scattering = true
	var timeroot = Node.new()
	timeroot.name = 'timeroot'
	add_child(timeroot)
	for i in voices:
		var timer = Timer.new()
		timer.name = str('scat_timer_' + str(i))
		timeroot.add_child(timer)
		timer.start(rand_range(min_time,max_time))
		timer.connect("timeout", self, "_scatter_timeout", [timer, min_time, max_time])
	if rand_range(0,1) > 0.7:
		_scatter()
	if timeout != 0:
		var timeouttimer = Timer.new()
		timeouttimer.wait_time= timeout
		add_child(timeouttimer)
		timeouttimer.start()
		timeouttimer.connect("timeout", self, "stop")
		
func _scatter_timeout(timer, min_time, max_time):
	_scatter()
	timer.start(rand_range(min_time, max_time))
	
func stop():
	scattering = false
	if has_node("timeroot"):
		$timeroot.queue_free()
	
func _scatter():
	var ransnd = _get_ransnd()
	_iplay(ransnd)
		
func _get_ransnd():
	var chance = randi() % soundlist.size()
	var ransnd = soundlist[chance]
	if randomise:
		_randomise_pitch_and_vol(ransnd)
	return ransnd
		
func _randomise_pitch_and_vol(sound):
	var dvol = sound.get_parent().dvols[sound.get_index()]
	var dpitch = sound.get_parent().dpitches[sound.get_index()]
	var newvol = (dvol + rand_range(-volume_range,volume_range))
	var newpitch = (dpitch + rand_range(-pitch_range,pitch_range))
	sound.volume_db = newvol
	sound.pitch_scale = newpitch

func _range(item : float) -> float:
	return rand_range(-item,item)
