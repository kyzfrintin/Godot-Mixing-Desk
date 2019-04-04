extends Node

var tempo
var bars
var beats_in_bar
var transition_beats
var loop
var can_shuffle = true

export(int) var play_mode = 1

onready var songs = get_children()

const default_vol = -10

var players = []
var time = 0.0
var beat = 1.0
var b2bar = 0
var bar = 1.0
var beats_in_sec = 0.0
var can_beat = true
var can_bar = true
var playing = false
var current_song_num = 0
var current_song
var beat_tran = false
var bar_tran = false
var old_song
var new_song = 0
var repeats = 0

var binds = []
var params = []

signal beat
signal bar
signal end
signal shuffle
signal song_changed

func _ready():
	var shuff = Timer.new()
	shuff.name = 'shuffle_timer'
	add_child(shuff)
	#yeahh
	shuff.connect("timeout", self, "_shuffle_songs")
	for song in songs:
		for i in song.get_children():
			if i.cont == "core":
				for o in i.get_children():
					var tween = Tween.new()
					tween.name = 'Tween'
					o.add_child(tween)
				
#loads a song and gets ready to play
func _init_song(track):
	track = songname_to_int(track)
	var song = songs[track]
	var root = song.get_core()
	current_song_num = track
	current_song = songs[track].get_core()
	var inum = 0
	repeats= 0
	for i in root.get_children():
		var bus = AudioServer.get_bus_count()
		AudioServer.add_bus(bus)
		AudioServer.set_bus_name(bus,"layer" + str(inum))
		AudioServer.set_bus_send(bus, "Music")
		if song.fading_out:
			i.get_child(0).stop(i)
			song.fading_out = false
		i.set_volume_db(default_vol)
		i.set_bus("layer" + str(inum))
		players.append(i)
		inum += 1
	if song.muted_tracks.size() > 0:
		for i in song.muted_tracks:
			_mute(current_song_num, i)
	root.get_child(0).connect("finished", self, "_song_finished")
	tempo = song.tempo
	bars = song.bars
	loop = song.loop
	beats_in_bar = song.beats_in_bar
	beats_in_sec = 60000.0/tempo
	transition_beats = (beats_in_sec*song.transition_beats)/1000

#unloads a song
func _clear_song(track):
	track = songname_to_int(track)
	players.clear()
	print('clearing song "' + str(songs[track].name) + '"')
	var song = songs[track].get_core()
	var inum = 0
	for i in song.get_children():
		var bus = AudioServer.get_bus_index("layer" + str(inum))
		AudioServer.remove_bus(bus)
		inum += 1
	song.get_child(0).disconnect("finished", self, "_song_finished")
		
#updates place in song and detects beats/bars
func _process(delta):
	if playing:
		time = current_song.get_child(0).get_playback_position()
		beat = ((time/beats_in_sec) * 1000.0) + 1.0
		_fade_binds()
		if fmod(beat, 1.0) < 0.1:
			beat = floor(beat)
			_beat()
			
			

#start a song with only one track playing
func _start_alone(song, layer):
	song = songname_to_int(song)
	layer = trackname_to_int(song, layer)
	current_song_num = song
	current_song = songs[song].get_core()
	for i in current_song.get_children():
		i.set_volume_db(-60.0)
	current_song.get_child(layer).set_volume_db(default_vol)
	_play(song)

#play in isolation - to be integrated
func _iplay(track):
	track = songname_to_int(track)
	var trk = track.duplicate()
	track.add_child(trk)
	trk.play()
	yield(trk, "finished")
	trk.queue_free()

#check if ref is string or int
func songname_to_int(ref):
	if typeof(ref) == TYPE_STRING:
		return get_node(ref).get_index()
	else:
		return ref

func trackname_to_int(song, ref):
	songname_to_int(song)
	if typeof(ref) == TYPE_STRING:
		return songs[song].get_core().get_node(ref).get_index()
	else:
		return ref
	
#play a song
func _play(song):
	song = songname_to_int(song)
	time = 0
	bar = 1
	beat = 1
	if !playing:
		emit_signal("bar", bar)
		playing = true
	for i in songs[song].get_children():
		if i.cont == "core":
#			print('playing song "' + str(songs[song].name) + '"')
			for o in i.get_children():
				o.play()
		if i.cont == "ran":
			randomize()
			var rantrk = get_rantrk(i)
			if rand_range(0,1) <= songs[song].random_chance:
				rantrk.play()
		if i.cont == "seq":
			var seqtrk = repeats
			if repeats == i.get_child_count():
				seqtrk = 0
				repeats = 0
			i.get_child(seqtrk).play()
		if i.cont == "concat":
			if repeats < 1:
				play_concat(i)
			songs[song].concats.append(i)
	
	if bar_tran:
		bar_tran = false
	if beat_tran:
		beat_tran = false

#play short random tracks in sequence in 'song'
func play_concat(concat):
	var rantrk = get_rantrk(concat)
	print(rantrk.name)
	rantrk.play()
	rantrk.connect("finished", self, "concat_fin", [concat])

func concat_fin(concat):
	for i in concat.get_children():
		if i.is_connected("finished", self, "concat_fin") :
			i.disconnect("finished", self, "concat_fin")
	play_concat(concat)

#mute all layers above specified layer, and fade in all below
func _mute_above_layer(song, layer):
	song = songname_to_int(song)
	layer = trackname_to_int(song, layer)
	if songs[song].get_core().get_child_count() < 2:
		return
	for i in range(0, layer + 1):
		_fade_in(song, i)
	for i in range(layer + 1, songs[song].get_core().get_child_count()):
		_fade_out(song, i)

#mute all layers below specified layer, and fade in all below
#use _mute_below_layer(0) to fade all tracks in
func _mute_below_layer(song, layer):
	song = songname_to_int(song)
	layer = trackname_to_int(song, layer)
	for i in range(layer, songs[song].get_core().get_child_count()):
        _fade_in(song, i)
	if layer > 0:
		for i in range(0, layer - 1):
    	    _fade_out(song, i)
		if layer == 1:
			_fade_out(song, 0)
			
#mute all layers aside from specified layer
func _solo(song, layer):
	song = songname_to_int(song)
	layer = trackname_to_int(song, layer)
	for i in range(layer + 1, songs[song].get_core().get_child_count()):
        _fade_out(song, i)
	if layer > 0:
		for i in range(0, layer - 1):
    	    _fade_out(song, i)
		if layer == 1:
			_fade_out(song, 0)

#mute only the specified layer
func _mute(song, layer):
	song = songname_to_int(song)
	layer = trackname_to_int(song, layer)
	var target = songs[song].get_core().get_child(layer)
	target.set_volume_db(-60.0)
	var pos = songs[song].muted_tracks.find(layer)
	if pos == null:
		songs[song].muted_tracks.append(layer)

#unmute only the specified layer
func _unmute(song, layer):
	song = songname_to_int(song)
	layer = trackname_to_int(song, layer)
	var target = songs[song].get_core().get_child(layer)
	target.set_volume_db(default_vol)
	var pos = songs[song].muted_tracks.find(layer)
	if pos != -1:
		songs[song].muted_tracks.remove(pos)

#slowly bring in the specified layer
func _fade_in(song, layer):
	song = songname_to_int(song)
#	layer = trackname_to_int(track, layer)
	var target = songs[song].get_core().get_child(layer)
	var tween = target.get_node("Tween")
	var in_from = target.get_volume_db()
	tween.interpolate_property(target, 'volume_db', in_from, default_vol, transition_beats, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	var pos = songs[song].muted_tracks.find(layer)
	if pos != -1:
		songs[song].muted_tracks.remove(pos)

#slowly take out the specified layer
func _fade_out(song, layer):
	song = songname_to_int(song)
#	layer = trackname_to_int(track, layer)
	var target = songs[song].get_core().get_child(layer)
	var tween = target.get_node("Tween")
	var in_from = target.get_volume_db()
	tween.interpolate_property(target, 'volume_db', in_from, -60.0, transition_beats, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()

	
#binds a track's volume to an object's parameter
func _bind_to_param(track,param):
	track = songname_to_int(track)
	binds.append(track)
	params.append(param)

#called externally. used to input a normalised value and convert to volume_db for bindings.
func _feed_param(param, val):
	params[param] = (val*60) - 60
#	print('fade val: ' + str(params[param]))

#remove selected track's bindings
func _unbind_track(track):
	track = songname_to_int(track)
	var bind = binds.find(track,0)
	binds.remove(bind)
	params.remove(bind)

#fade track volume to match bound parameter
func _fade_binds():
	if binds.size() > 0:
		for i in binds:
			var num = binds.find(i)
			var target = current_song.get_child(i)
			target.volume_db = params[num]
#			print('vol: ' + str(target.volume_db))

#change to the specified song at the next bar
func _queue_bar_transition(song):
	song = songname_to_int(song)
	old_song = current_song_num
	songs[old_song].fading_out = true
	new_song = song
	bar_tran = true
	
#change to the specified song at the next beat
func _queue_beat_transition(song):
	song = songname_to_int(song)
	old_song = current_song_num
	songs[old_song].fading_out = true
	new_song = song
	beat_tran = true

#unload and stops the current song, then initialises and plays the new one
func _change_song(song):
	song = songname_to_int(song)
	_clear_song(old_song)
	_init_song(song)
	for i in songs[old_song].get_children():
		if i.cont == "core":
			if songs[old_song].transition_beats >= 1:
				for o in i.get_child_count():
					_fade_out(old_song, o)
		if 'ran' or 'seq' or 'concat' in i.cont:
			for o in i.get_children():
				o.stop()
	_play(song)

#stops playing
func _stop(song):
	song = songname_to_int(song)
	if playing:
		playing = false
		for i in songs[song].get_children():
			for o in i.get_children():
				o.stop()
	_clear_song(current_song_num)

#called every bar
func _bar():
	if can_bar:
		can_bar = false
		
		if bar_tran:
			if current_song_num != new_song:
				_change_song(new_song)
				emit_signal("song_changed")
		#at end of song
		if bar >= bars + 1:
#			for i in songs[current_song_num].concats:
#				for o in i.get_children():
#					if o.is_playing():
#						o.stop()
			songs[current_song_num].concats.clear()
			if play_mode == 1 and loop:
				_play(current_song_num)
				repeats += 1
			emit_signal("end")
		yield(get_tree().create_timer(0.5), "timeout")
		can_bar = true
	
#called every beat
func _beat():
	if can_beat:
		if beat_tran:
			if current_song_num != new_song:
				_change_song(new_song)
				emit_signal("song_changed", new_song)
		if b2bar == beats_in_bar:
			b2bar = 1
			bar += 1
			_bar()
			emit_signal("bar", bar)
		else:
			b2bar += 1
		can_beat = false
		emit_signal("beat", beat)
		yield(get_tree().create_timer((beats_in_sec/1000)*0.9), 'timeout')
		can_beat = true

#gets a random track from a song and returns it
func get_rantrk(song):
	song = songname_to_int(song)
	var chance = randi() % song.get_child_count()
	var rantrk = song.get_child(chance)
	return rantrk
		
#choose new song randomly
func _shuffle_songs():
	if playing:
		_stop(current_song)
	_clear_song(current_song_num)
	randomize()
	var song = randi() % (songs.size() - 1)
	_init_song(song)
	_play(song)
	emit_signal("shuffle")
	can_shuffle = true

#called when the song finishes
func _song_finished():
	if play_mode == 2 and can_shuffle:
		$shuffle_timer.start(rand_range(0,2))
		can_shuffle = false