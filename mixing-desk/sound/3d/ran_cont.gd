extends Spatial

var dvols = []
var dpitches = []

export var volume_range : float
export var pitch_range : float

func _ready():
	for i in get_children():
		dvols.append(i.unit_db)
		dpitches.append(i.pitch_scale)

func _iplay(sound):
	var snd = sound.duplicate()
	sound.add_child(snd)
	snd.play()
	yield(snd, "finished")
	snd.queue_free()
	
func play(num, ran=true):
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
		_randomise(ransnd)
	return ransnd
		
func _randomise(sound):
	var dvol = dvols[sound.get_index()]
	var dpitch = dpitches[sound.get_index()]
	var newvol = (dvol + _range(volume_range))
	var newpitch = (dpitch + _range(pitch_range))
	sound.volume_db = newvol
	sound.pitch_scale = newpitch
	
func _range(item : float) -> float:
	return rand_range(-item,item)