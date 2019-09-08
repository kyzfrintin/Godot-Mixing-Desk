extends Node2D

var dvols = []
var dpitches = []
var dlocs = []
var timeroot
var root
var scattering : bool = false

export var autostart : bool = true
export var volume_range : float = 1.0
export var pitch_range : float= 1.0
export var scatter_range : float = 1.0
export var voices : int = 5
export var min_time : float = 1
export var max_time : float = 5
export var timeout : float = 7
export var randomise : bool = true

func _ready():
	for i in get_children():
		dvols.append(i.volume_db)
		dpitches.append(i.pitch_scale)
		dlocs.append(i.position)
	if autostart:
		play()
	root = Node2D.new()
	add_child(root)
	root.name = "root"
	
func _iplay(sound):
	var snd = sound.duplicate()
	root.add_child(snd)
	snd.play()
	#yield(snd, "finished")
	snd.connect("finished", self, "_snd_finished", [snd])
	#snd.queue_free()

func _snd_finished(snd):
	snd.disconnect("finished",self,"_snd_finished")
	snd.queue_free()

func play():
	if scattering: 
		return
	scattering = true
	var timeroot = Node.new()
	timeroot.name = 'timeroot'
	add_child(timeroot)
	if rand_range(0,1) > 0.7:
		_scatter()
	for i in voices:
		var timer = Timer.new()
		timer.name = str('scat_timer_' + str(i))
		timeroot.add_child(timer)
		timer.start(rand_range(min_time,max_time))
		timer.connect("timeout", self, "_scatter_timeout", [timer, min_time, max_time])
	if timeout != 0:
		yield(get_tree().create_timer(timeout), "timeout")
		end()
		
func _scatter_timeout(timer, min_time, max_time):
	_scatter()
	timer.start(rand_range(min_time, max_time))
	
func end():
	scattering = false
	$timeroot.queue_free()
	
func _scatter():
	var ransnd = _get_ransnd()
	_iplay(ransnd)
		
func _get_ransnd(ran=true):
	var children = get_child_count()
	var chance = randi() % (children - 2)
	var ransnd = get_child(chance)
	if ran:
		_randomise(ransnd)
	return ransnd

func _randomise(sound):
	var dvol = dvols[sound.get_index()]
	var dpitch = dpitches[sound.get_index()]
	var dloc = dlocs[sound.get_index()]
	var newvol = (dvol + _range(volume_range))
	var newpitch = (dpitch + _range(pitch_range))
	var newloc = (dloc + Vector2(_range(scatter_range), _range(scatter_range)))
	sound.volume_db = newvol
	sound.pitch_scale = newpitch
	sound.position = newloc
	
func _range(item : float) -> float:
	return rand_range(-item,item)