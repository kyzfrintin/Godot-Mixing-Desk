extends Node

var tempo
var bars
var beats_in_bar
var transition_beats
var loop
var can_shuffle = true

export(int) var play_mode = 1

onready var songs = get_children()

const default_vol = 0

var players = []
var time = 0.0
var beat = 1.0
var last_beat = -1
var suppress_beat = 0.0
var b2bar = 0
var bar = 1.0
var beats_in_sec = 0.0
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
	shuff.one_shot = true
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
func init_song(track):
	track = _songname_to_int(track)
	var song = songs[track]
	var root = song._get_core()
	current_song_num = track
	current_song = songs[track]._get_core()
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
			mute(current_song_num, i)
	root.get_child(0).connect("finished", self, "_song_finished")
	tempo = song.tempo
	bars = song.bars
	loop = song.loop
	beats_in_bar = song.beats_in_bar
	beats_in_sec = 60000.0/tempo
	transition_beats = (beats_in_sec*song.transition_beats)/1000

#unloads a song
func clear_song(track):
	track = _songname_to_int(track)
	players.clear()
	binds.clear()
	params.clear()
	print('clearing song "' + str(songs[track].name) + '"')
	var song = songs[track]._get_core()
	var inum = 0
	for i in song.get_children():
		var bus = AudioServer.get_bus_index("layer" + str(inum))
		AudioServer.remove_bus(bus)
		inum += 1
	song.get_child(0).disconnect("finished", self, "_song_finished")
		
#updates place in song and detects beats/bars
func _process(delta):
	if suppress_beat > 0:
		suppress_beat -= delta
		return
	if playing:
		time = current_song.get_child(0).get_playback_position()
		beat = int(floor(((time/beats_in_sec) * 1000.0) + 1.0))
		_fade_binds()
		if beat != last_beat && (beat - 1) % int(bars * beats_in_bar) + 1 != last_beat:
			_beat()
		last_beat = beat
			
			

#start a song with only one track playing
func start_alone(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	current_song_num = song
	current_song = songs[song]._get_core()
	for i in current_song.get_children():
		i.set_volume_db(-60.0)
	current_song.get_child(layer).set_volume_db(default_vol)
	play(song)

#play in isolation - to be integrated
func _iplay(track):
	track = _songname_to_int(track)
	var trk = track.duplicate()
	track.add_child(trk)
	trk.play()
	yield(trk, "finished")
	trk.queue_free()

#check if ref is string or int
func _songname_to_int(ref):
	if typeof(ref) == TYPE_STRING:
		return get_node(ref).get_index()
	else:
		return ref

func _trackname_to_int(song, ref):
	_songname_to_int(song)
	if typeof(ref) == TYPE_STRING:
		return songs[song]._get_core().get_node(ref).get_index()
	else:
		return ref
	
#play a song
func play(song):
	song = _songname_to_int(song)
	time = 0
	bar = 1
	beat = 1
	last_beat = -1
	suppress_beat = beats_in_sec / 1000.0 * 0.5
	if !playing:
		last_beat = 1
		emit_signal("bar", bar)
		_beat()
		playing = true
	for i in songs[song].get_children():
		if i.cont == "core":
#			print('playing song "' + str(songs[song].name) + '"')
			for o in i.get_children():
				o.play()
		if i.cont == "ran":
			randomize()
			var rantrk = _get_rantrk(i)
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
				_play_concat(i)
			songs[song].concats.append(i)
	
	if bar_tran:
		bar_tran = false
	if beat_tran:
		beat_tran = false

#play short random tracks in sequence in 'song'
func _play_concat(concat):
	var rantrk = _get_rantrk(concat)
	print(rantrk.name)
	rantrk.play()
	rantrk.connect("finished", self, "concat_fin", [concat])

func _concat_fin(concat):
	for i in concat.get_children():
		if i.is_connected("finished", self, "concat_fin") :
			i.disconnect("finished", self, "concat_fin")
	_play_concat(concat)

#mute all layers above specified layer, and fade in all below
func mute_above_layer(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	if songs[song]._get_core().get_child_count() < 2:
		return
	for i in range(0, layer + 1):
		fade_in(song, i)
	for i in range(layer + 1, songs[song]._get_core().get_child_count()):
		fade_out(song, i)

#mute all layers below specified layer, and fade in all below
#use mute_below_layer(0) to fade all tracks in
func mute_below_layer(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	for i in range(layer, songs[song]._get_core().get_child_count()):
        fade_in(song, i)
	if layer > 0:
		for i in range(0, layer - 1):
    	    fade_out(song, i)
		if layer == 1:
			fade_out(song, 0)
			
#mute all layers aside from specified layer
func solo(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	for i in range(layer + 1, songs[song]._get_core().get_child_count()):
        fade_out(song, i)
	if layer > 0:
		for i in range(0, layer - 1):
    	    fade_out(song, i)
		if layer == 1:
			fade_out(song, 0)

#mute only the specified layer
func mute(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	var target = songs[song]._get_core().get_child(layer)
	target.set_volume_db(-60.0)
	var pos = songs[song].muted_tracks.find(layer)
	if pos == null:
		songs[song].muted_tracks.append(layer)

#unmute only the specified layer
func unmute(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	var target = songs[song]._get_core().get_child(layer)
	target.set_volume_db(default_vol)
	var pos = songs[song].muted_tracks.find(layer)
	if pos != -1:
		songs[song].muted_tracks.remove(pos)

#mutes a track if not mutes, or vice versa
func toggle_mute(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	var target = songs[song]._get_core().get_child(layer)
	if target.volume_db < 0:
		unmute(song, layer)
	else:
		mute(song, layer)

#slowly bring in the specified layer
func fade_in(song, layer):
	song = _songname_to_int(song)
#	layer = _trackname_to_int(track, layer)
	var target = songs[song]._get_core().get_child(layer)
	var tween = target.get_node("Tween")
	var in_from = target.get_volume_db()
	tween.interpolate_property(target, 'volume_db', in_from, default_vol, transition_beats, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	var pos = songs[song].muted_tracks.find(layer)
	if pos != -1:
		songs[song].muted_tracks.remove(pos)

#slowly take out the specified layer
func fade_out(song, layer):
	song = _songname_to_int(song)
#	layer = _trackname_to_int(track, layer)
	var target = songs[song]._get_core().get_child(layer)
	var tween = target.get_node("Tween")
	var in_from = target.get_volume_db()
	tween.interpolate_property(target, 'volume_db', in_from, -60.0, transition_beats, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()

#fades a track in if silent, fades out if not
func toggle_fade(song, layer):
	song = _songname_to_int(song)
	var target = songs[song]._get_core().get_child(layer)
	if target.volume_db < 0:
		fade_in(song, layer)
	else:
		fade_out(song, layer)
#binds a track's volume to an object's parameter
func bind_to_param(track,param):
	track = _songname_to_int(track)
	binds.append(track)
	params.append(param)

#called externally. used to input a normalised value and convert to volume_db for bindings.
func feed_param(param, val):
	params[param] = (val*60) - 60
#	print('fade val: ' + str(params[param]))

#remove selected track's bindings
func unbind_track(track):
	track = _songname_to_int(track)
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
func queue_bar_transition(song):
	song = _songname_to_int(song)
	old_song = current_song_num
	songs[old_song].fading_out = true
	new_song = song
	bar_tran = true
	
#change to the specified song at the next beat
func queue_beat_transition(song):
	song = _songname_to_int(song)
	old_song = current_song_num
	songs[old_song].fading_out = true
	new_song = song
	beat_tran = true

#play two tracks in order, either ending, looping or shuffling on the second
func queue_sequence(sequence : Array, type : String, on_end : String):
	match type:
		"beat":
			queue_beat_transition(sequence[0])
		"bar":
			queue_bar_transition(sequence[0])
	play_mode = 0
	yield(self,"song_changed")
	yield(self,"end")
	init_song(sequence[1])
	play(sequence[1])
	match on_end:
		"play_once":
			play_mode = 0
		"loop":
			play_mode = 1
		"shuffle":
			play_mode = 3

#unload and stops the current song, then initialises and plays the new one
func _change_song(song):
	song = _songname_to_int(song)
	clear_song(old_song)
	init_song(song)
	for i in songs[old_song].get_children():
		if i.cont == "core":
			if songs[old_song].transition_beats >= 1:
				for o in i.get_child_count():
					fade_out(old_song, o)
		if 'ran' or 'seq' or 'concat' in i.cont:
			for o in i.get_children():
				o.stop()
	play(song)

#stops playing
func stop(song):
	song = _songname_to_int(song)
	if playing:
		playing = false
		for i in songs[song].get_children():
			for o in i.get_children():
				o.stop()
	clear_song(current_song_num)

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
				play(current_song_num)
				repeats += 1
			emit_signal("end")
		yield(get_tree().create_timer(0.5), "timeout")
		can_bar = true
	
#called every beat
func _beat():
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
	emit_signal("beat", (beat - 1) % int(bars * beats_in_bar) + 1)

#gets a random track from a song and returns it
func _get_rantrk(song):
	song = _songname_to_int(song)
	var chance = randi() % song.get_child_count()
	var rantrk = song.get_child(chance)
	return rantrk
		
#choose new song randomly
func shuffle_songs():
	if playing:
		stop(current_song)
		clear_song(current_song_num)
	randomize()
	var song = randi() % (songs.size() - 1)
	init_song(song)
	play(song)
	emit_signal("shuffle")
	can_shuffle = true

#called when the song finishes
func _song_finished():
	if play_mode == 2 and can_shuffle:
		$shuffle_timer.start(rand_range(0,2))
		can_shuffle = false
