extends Spatial

var dvols = []
var dpitches = []
var dlocs = []
var timeroot

export var volume_range : float = 1.0
export var pitch_range : float= 1.0
export var scatter_range : float = 1.0
export var voices : int = 5
export var min_time : float = 1
export var max_time : float = 5

export var randomise : bool = true
export var autostart : bool = true

func _ready():
	for i in get_children():
		dvols.append(i.unit_db)
		dpitches.append(i.pitch_scale)
		dlocs.append(i.translation)
	if autostart:
		begin()

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
		timer.start(rand_range(min_time,max_time))
		timer.connect("timeout", self, "_scatter_timeout", [timer, min_time, max_time])
		
func _scatter_timeout(timer, min_time, max_time):
	_play()
	timer.start(rand_range(min_time, max_time))
	
func end():
	timeroot.queue_free()
	
func _play():
	var ransnd = _get_ransnd()
	_iplay(ransnd)
		
func _get_ransnd(ran=true):
	var children = get_child_count()
	var chance = randi() % (children - 1)
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
	var newloc = (dloc + Vector3(_range(scatter_range), _range(scatter_range),_range(scatter_range)))
	sound.unit_db = newvol
	sound.pitch_scale = newpitch
	sound.translation = newloc
	
func _range(item : float) -> float:
	return rand_range(-item,item)