extends Node

var dvols = []
var dpitches = []
var timeroot

export var volume_range = 1.0
export var pitch_range = 1.0

func _ready():
	for i in get_children():
		dvols.append(i.volume_db)
		dpitches.append(i.pitch_scale)

func _iplay(sound):
	var snd = sound.duplicate()
	sound.add_child(snd)
	snd.play()
	yield(snd, "finished")
	snd.queue_free()
	
func begin(voices=5, tmin=1, tmax=5, ran=true):
	var timeroot = Node.new()
	timeroot.name = 'timeroot' + str(get_index())
	for i in voices:
		var timer = Timer.new()
		timer.name = str('scat_timer_' + str(i))
		timeroot.add_child(timer)
		timer.start(rand_range(tmin,tmax))
		timer.connect("timeout", self, "_scatter_timeout", [timer, tmin, tmax])
		
func _scatter_timeout(timer, tmin, tmax):
	_play(1)
	timer.start(rand_range(tmin, tmax))
	
func end():
	timeroot.queue_free()
	
func _play(num, ran=true):
	if num > 1:
		for i in range(0, num):
			var ransnd = _get_ransnd()
			_iplay(ransnd)
	else:
		var ransnd = _get_ransnd()
		_iplay(ransnd)
		
func _get_ransnd(ran=true):
	var children = get_child_count()
	var chance = randi() % children
	var ransnd = get_child(chance)
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

func _range(item : float) -> float:
	return rand_range(-item,item)