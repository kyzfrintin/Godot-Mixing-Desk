extends Node2D

export(AudioStreamSample) var layer1
export(AudioStreamSample) var layer2
export(AudioStreamSample) var layer3
export(AudioStreamSample) var layer4
export(AudioStreamSample) var layer5
export(AudioStreamSample) var layer6
export(AudioStreamSample) var layer7
export(AudioStreamSample) var layer8

export var tempo = 0
export var bars = 0
export var beats_in_bar = 4.0
export var transition_beats = 4.0

onready var tweens = [get_node("Tween")] 
onready var met = get_node("beat_tone")
onready var layers = [layer1, layer2, layer3, layer4, layer5, layer6, layer7, layer8]
onready var audioplayer = preload("res://Scenes/Layer.tscn")

var players = []
var num = 0
var time = 0.0
var beat = 1.0
var bar = 1.0
var beats_in_sec = 0.0
var can_beat = true
var can_bar = true
var playing = false
var beat_tran = false
var bar_tran = false
var fadeins = []
var fadeouts = []

signal beat
signal bar


func _ready():
	beats_in_sec = 60000.0/tempo
	transition_beats = (beats_in_sec*4)/10000
	for i in layers:
		var player = audioplayer.instance()
		var bus = AudioServer.get_bus_count()
		var tween = get_node("Tween").duplicate()
		player.set_stream(layers[num])
		players.append(player)
		tweens.append(tween)
		AudioServer.add_bus(bus)
		AudioServer.set_bus_name(bus,"layer" + str(num))
		AudioServer.set_bus_send(bus, "Music")
		player.set_bus("layer" + str(num))
		add_child(player,true)
		add_child(tween,true)
		num += 1
		
	
func _process(delta):
	time = players[0].get_playback_position()
	beat = ((time/beats_in_sec) * 1000.0) + 1.0
	bar = beat/beats_in_bar + 0.75
	
	if playing:
		if fmod(beat, 1.0) < 0.1:
			
			if fmod(bar, 1.0) < 0.24:
				bar = floor(bar)
				_bar()
			
			beat = floor(beat)
			_beat()
			
			

func _startAlone(layer):
	for i in players:
		i.set_volume_db(-60.0)
	players[layer].set_volume_db(0)
	_play()

func _play():
	if !playing:
		playing = true
		for i in players:
			i.play()
	_beat()
	_bar()

func _muteAboveLayer(layer):
	for i in range(0, layer):
        _fadeIn(i)
	for i in range(layer + 1, layers.size()):
        _fadeOut(i)

func _muteBelowLayer(layer):
	for i in range(layer, layers.size()):
        _fadeIn(i)
	for i in range(0, layer - 1):
        _fadeOut(i)

func _mute(layer):
	players[layer].set_volume_db(-60.0)
	
func _unMute(layer):
	players[layer].set_volume_db(0.0)

func _fadeIn(layer):
	var target = players[layer]
	var in_from = target.get_volume_db()
	tweens[layer].interpolate_property(target, 'volume_db', in_from, 0.0, transition_beats, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tweens[layer].start()
	
func _fadeOut(layer):
	var target = players[layer]
	var in_from = target.get_volume_db()
	tweens[layer].interpolate_property(target, 'volume_db', in_from, -60.0, transition_beats, Tween.TRANS_SINE, Tween.EASE_OUT)
	tweens[layer].start()

func _queueBarTransition(faders):
	bar_tran = true
	for i in faders:
		fadeins.append(i)

func _queueBeatTransition(faders):
	beat_tran = true
	for i in faders:
		fadeins.append(i)
	
func _stop():
	if playing:
		playing = false
		for i in players:
			i.stop()

func _bar():
	if can_bar:
		if bar_tran:
			for i in fadeins:
				_fadeIn(i)
				fadeins.remove(i)
			bar_tran = false
		can_bar = false
		get_node("kill_bar").start()

func _beat():
	if can_beat:
		if beat_tran:
			for i in fadeins:
				_fadeIn(i)
				fadeins.remove(i)
			beat_tran = false
		can_beat = false
		get_node("kill_beat").start()

func _reenableBeat():
	can_beat = true

func _reenableBar():
	can_bar = true
