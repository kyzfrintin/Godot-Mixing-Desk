extends Node2D

export var volume_range = 1.0
export var pitch_range = 0.1

# play all sounds under child 'sound' 


func _play_sound_full(sound, ran=true):
	var snd = get_child(sound)
	for i in snd.get_children():
		if ran:
			_randomise_pitch_and_vol(i)
		_iplay(i)
		
# play 'num' number of random sounds under child 'sound'

func _play_sound_random(sound, num, ran=true):
	var snd = get_child(sound)
	if num > 1:
		for i in range(0, num):
			var ransnd = get_ransnd(sound)
			_iplay(ransnd)
	else:
		var ransnd = get_ransnd(sound)
		_iplay(ransnd)
	
# play sound 0 under child 'sound', with 'num' number of random sounds

func _play_base_and_random(sound, num, ran=true):
	var snd = get_child(sound)
	_randomise_pitch_and_vol(snd)
	snd.get_child(0).play()
	for i in range(0, num):
		var ransnd = get_ransnd(sound)
		_iplay(ransnd)

# creates 'voices' number of timers for a group of sounds, with timeout range of tmin-tmax, and starts them

func _play_sound_scattered(sound, voices=5, tmin=1, tmax=5, ran=true):
	var snd = get_child(sound)
	var timeroot = Spatial.new()
	snd.add_child(timeroot)
	snd.timeroot = timeroot
	timeroot.name = 'timeroot' + str(get_index())
	for i in voices:
		var timer = Timer.new()
		timer.name = str('scat_timer_' + str(i))
		timeroot.add_child(timer)
		timer.start(rand_range(tmin,tmax))
		timer.connect("timeout", self, "_scatter_timeout", [sound, timer, tmin, tmax])

# plays a random sound on scatter timeout

func _scatter_timeout(sound, timer, tmin, tmax):
	_play_sound_random(sound, 1)
	timer.start(rand_range(tmin, tmax))

# deletes scatter timers in specified sound, thus ending the scattering

func _end_scatter(sound):
	get_child(sound).timeroot.queue_free()

# plays 'num' number of random sounds in sequence

func _play_ranseq(sound, num, ran=true):
	randomize()
	for i in range(0, num):
		var ransnd = get_ransnd(sound)
		ransnd.play()
		yield(ransnd, "finished")
		

# play multiple sounds together

func _play_multi_sound(sounds, ran=true):
	for i in sounds:
		_play_sound_random(i, randi() % (i.get_child_count() - 1), ran)

# play mutliple sounds together, each one chosen from a separate random pool

func _play_tree_sound(sound, ran=true):
	var snd = get_child(sound)
	for i in snd.get_children():
		var ransnd = i.get_child(randi() % i.get_child_count() - 1)
		if ran:
			_randomise_pitch_and_vol(ransnd)
		#ransnd.play()
		_iplay(ransnd)

# creates an instance of the specified sound, plays it, then deletes it when it's finished

func _iplay(sound):
	var snd = sound.duplicate()
	sound.add_child(snd)
	snd.play()
	yield(snd, "finished")
	snd.queue_free()
	
		
# changes pitch and volume of sound between the Vector2 ranges

func _randomise_pitch_and_vol(sound):
	var dvol = sound.get_parent().dvols[sound.get_index()]
	var dpitch = sound.get_parent().dpitches[sound.get_index()]
	var newvol = (dvol + rand_range(-volume_range,volume_range))
	var newpitch = (dpitch + rand_range(-pitch_range,pitch_range))
	if is_3d(sound):
		sound.unit_db = newvol
	else:
		sound.volume_db = newvol
	sound.pitch_scale = newpitch

# gets and returns a random sample under child 'sound'

func get_ransnd(sound, ran=true):
	var snd = get_child(sound)
	var scat = is_scattering(snd)
	var children = snd.get_child_count()
	if scat:
		children -= 1
	var chance = randi() % children
	var ransnd = snd.get_child(chance)
	if ran:
		_randomise_pitch_and_vol(ransnd)
	return ransnd

# checks if sound is 2d

func is_2d(sound):
	if sound.is_class("AudioStreamPlayer2D"):
		return true
	

# checks if the sound is 3d

func is_3d(sound):
	if sound.is_class("AudioStreamPlayer3D"):
		return true

# checks if sound is currently scattering

func is_scattering(sound):
	for i in sound.get_children():
		if 'timero' in i.name:
			return true