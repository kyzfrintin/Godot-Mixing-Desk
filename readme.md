# Godot Mixing Desk 2.13.3

The Mixing Desk is a complete audio solution for the Godot Engine.
Godot already ships with some awesome audio capabilities - namely the bus system which is so intuitive for audio.
Generally speaking, this makes it easy to implement audio in Godot.
But for some more advanced features, a bit of coding is required.

That's where Mixing Desk comes in. A modular plugin, allowing for procedural audio and adaptive music in games, with just a couple of nodes and a line of code for each implementation.

# Mixing Desk: Music

The MDM was designed to make adaptive, interactive music easier to design within Godot. You contain songs within `song` nodes, each with their own individual properties and with any number of modular components. You can do anything between looping a single audio track, to creating a procedurally generated soundtrack completely dictated by the actions of your game, and with random elements spawned by chance.

>NOTE: Ensure that your audio files, whether they are intended to loop or not, are imported with `loop` disabled. MDM handles looping in its own way, and auto-looping tracks will mess things up!

### Setting up MDM

![Typical MDM instance](https://i.imgur.com/XmBi5Jz.png)

**Core Tracks**

Create a MixingDeskMusic, and place Song nodes for each of your songs, similar to in the image above. As you can see, the main song files are placed under a "CoreContainer", which plays all the audio nodes under it by default. As for the other nodes, they are overlays, and the blue-outlined nodes are AutoContainers, which we will come to shortly.

### You *must* fill in the properties in the song node!
![Typical properties](https://i.imgur.com/PgILEsy.png)

If you don't know the tempo of the music you're using, ask the composer. If you don't know the composer, check the website where you downloaded the music, or the readme in the sample pack you downloaded. If in doubt, try out BPM detection software such as here: https://www.conversion-tool.com/bpmdetector/?lang=en
Similar process for bars and beats in bar - but beats in bar will, most of the time, be 4, sometimes 3.
Transition beats is how long the fadeout should be when changing song or stopping. And auto-transition is useful for a codeless approach to adaptive music: point the song at the node which contains the desired signal, name the signal, and the song will be queued for transition when the signal is emitted. Transition type can be either beat or bar.
Each song can also be routed to its own bus, if desired. By default, it is set to "Music". Mixing Desk will automatically create the named bus if it does not exist, upon running the game, and route the audio to that bus. If this bus isn't "Music", the bus will be routed to "Music".

>TIP: All full-length tracks (I.E. all tracks but Concat and Rollover) may extend over the bar length of the track, allowing reverb/delay/decay tails. This ensures smoother looping with instruments that sound out after the play is finished.

![This export is fine!](https://i.imgur.com/ASV8hpl.png)

>TIP cont'd: Such as the above image - you may export your tracks beyond the actual length, to allow instruments to decay. Mixing Desk copies the tracks and plays, then deletes the copies. No awkward repeat cutoffs!

### Overlays (random, sequence, concat and rollover tracks)

![Example of an overlay setup](https://i.imgur.com/Uccm4IV.png)

Overlays are set up in much the same way as core tracks. Create a RandomContainer, and a random track from that folder will be played on each repeat, with a slight chance of no track playing depending on the value of the RandomContainer's `random_chance` - if the random number generated (between 0 and 1) each time song plays is lower than the value of `random_chance`, the track plays.
	
SeqContainers play the audio nodes in order, from top to bottom, and over again. Overlays must be equal length or shorter than the corresponding core tracks.

Use a ConcatContainer for a group of short tracks, particularly percussion, that you wish to play in random order over the top of the song. These tracks will be chosen randomly and each will immediately follow the previous. Good for randomising drums by the measure, or whichever length samples you choose to throw in.

Rollovers are semi-transitions within a loop. Think of a crash roll, or snare rush, or any build-up/wind-down clip that may "roll over" from near the end of your clip, to after the start of the next loop. Place a RolloverContainer and add 1 or more rollover clips beneath it, and edit the `crossover beat` with the beat number of the clip that should line up with the first beat after looping. If the clip is 9 beats long, and the apex of its climb, or timing of its impact, is on beat 5 - the number is 5. Remember, count from 0, otherwise it will be thrown off.



![Example of rollover properties](https://i.imgur.com/Hubj0Ls.png)

### Loading and hitting play

Once your nodetree is setup, you're all ready to play your music in Godot.

First, pick a play mode. It's a property of the MDM node.

![Play modes](https://i.imgur.com/3QqUAoT.png)

> Play Once: as the name suggests, it plays a song once and then stops

> Loop One: loop the currently playing song until you decide to stop or transition to another, which will then loop

> Shuffle: play a song, silence for a moment, then play another

> Endless Shuffle: seamlessly shuffle between all songs in the MDM instance

> Endless Loop: Loop the whole playlist without gaps in between

	note: all vertical/horizontal adaptive features are available in all play modes!

To have a song play first thing, you can easily set the `autoplay` export variable in MDM. Choose which song you'd like to autoplay, and you're ready to go. Otherwise, you can easily call it in code at the appropriate moment for your song to begin. To do this, simply call `init_song(song)` to load the track ready to play.
Then, call `play(song)` - track in both cases being either the name of the song node you wish to play, or its index, counting from 0. Either will work, though names are easier for us humans to remember, while index numbers are easier to do maths on - it's your call. To quickly initialise and play in one, call `quickplay(song)`.

### Adapting the music

Based on implementations of interactive music in [FMOD](https://www.fmod.com/) and [Wwise](https://www.audiokinetic.com/products/wwise/),  the MDM neatly covers the two major branches of adaptive music outlined by [Michael Sweet](https://www.designingmusicnow.com/2016/06/13/advantages-disadvantages-common-interactive-music-techniques-used-video-games/). 

### **Vertical Remixing/Layering**
MDM can fade individual tracks in and out using the `fade_in(track)` or `fade_out(track)` functions. It can also fade multiple tracks in/out at once with the `mute_below_layer(track)` and `mute_above_layer(track)` functions. Fading and muting both have toggles, too - `toggle_fade(song, track)` and `toggle_mute(song, track)`. To begin a track with a base layer only, the `start_alone(track, layer)` function can be used.

[Video Example](https://streamable.com/csjyi)

To control an track's (or group of tracks') volume constantly based on a parameter, however, is only slightly more tricky. An AutoFadeContainer will automatically change the volume of its child audio tracks to match the state of a selected variable. This can be done quite simply by dropping in the aforementioned container, and editing the properties to suit. Use `All` play style if you want all the tracks to play, `random` if you want a randomly selected single track to play. Check `toggle` if it is a simple true/false value for toggling the track on. `target_node` is the node that contains the desired value, and `target_property` is the variable you wish to use for volume modulation. Min/max range is self-explanatory - the range of values to use for modulation. Check invert if it is a value that should *increase* the volume as the value *decreases* - distance, for instance. Lastly, the `track_speed` is the number by which to increment volume to match the property value. Higher values mean quicker tracking.

![Example of AutoFadeContainer properties](https://i.imgur.com/khsoOCF.png)

The AutoLayerContainer works in a similar way, though treats its contained layers as a an arrangement in series of intensity. Use this container to fade in tracks according to an integer value, depending on the play mode you choose. With `additive`, you can fade in all tracks below a certain number, and fade them out above. With `single`, you can choose to fade in only a single one of the tracks. With `pad`, you can fade in tracks around the chosen number, by the pad number specified. That can either be done automatically, similarly to the AutoFadeContainer, by choosing a node and naming its property, and denoting the range of values to be expected, or manually through code, by changing the values of `layer_min` and `layer_max`.

![AutoLayerContainer properties](https://i.imgur.com/ATowf9n.png)

### **Horizontal Resequencing**

MDM consistently keeps track of beats and bars, and output signals accordingly. Aligning with this functionality is the ability to switch between songs on the fly, either on the beat or on the bar. A code-less approach is achieved using the auto-transition properties in the Song node itself. You can bind a song to an in-game signal. Just enable auto-transiiton, point the song to the right node in your scene, enter the name of the signal, and finally choose a transition type - beat or bar. When the signal is emitted, MDM will transition to the song at the specified musical demarcation. In the screenshot below, the song will play on the next bar when the level node emits the `combat_begin` signal.

![Auto-transition example](https://i.imgur.com/vJdWMGj.png)

In your game's code, however, it is rather simple to queue a transition more specifically. Wherever you need to queue a transition in code, you can easily do this using the `queue_beat_transition(song)` or `queue_bar_transition(song)` functions. Just as in `play()`, the `song` argument is the name o r index of the song to transition to.

You can also insert a clip in between the source and destination songs by calling `queue_sequence(sequence, type, on_end)`. The `sequence` variable is an array of two songnames; the first being the intervening clip, and the second being the destination song. `type` is a string, either "beat" or "bar", and denotes which signal to wait for before transitioning. Lastly, `on_end` is the play_mode of the final track, and can be either "play_once", "loop", or "shuffle".

[Video Example](https://streamable.com/1cx2w)

[Video example of both horizontal and vertical techniques in action](https://streamable.com/wzaze)

### Integrating the music and game

![MDM signals](https://i.imgur.com/3azVGMe.png)

MDM outputs beat and bar signals which can easily be connected to any other node in the scene. This way, you can time events in the game to the music. For example, a `yield(mdm, 'bar')` can delay actions until they're in sync with the next bar. MDM also outputs signals when a song ends, when the song is changed, and upon shuffling in a playlist. Here is a run-down of the signals and their connected variables:

```
bar(bar : int)

beat(beat : int)

end(song_num : int)

shuffle(old_song_num : int, new_song_num : int)

song_changed(old_song_num : int, new_song_num : int)
```

---

# Mixing Desk: Sound

The MDS is a fully-featured sound-playing plugin, allowing procedural playback of multiple layered and combined sounds through the use of handy containers that each treat their nested sounds in a different way. But there's no need to remember any special functions - just like AudioStreamPlayers, all MDS sound contianers can be started and stopped using `play()` and `stop()`. They can, of course, also be autostarted using the export variable `autoplay`.
Each SoundContainer has similar properties, but they behave in different ways. For example, all containers have the option to randomise pitch and volume, and will all play instanced (to alleviate sound-replay fatigue which is so common when repeating the same sound effect over and over). They also all have the option to spawn under a different node, using the `spawn-node` export. Their behaviour is, as noted, the key difference. Their functions are detailed below.


### Setting up MDS

MDS is slightly different to MDM - there are still container nodes, but no parent Mixing Desk. There are five kinds of MDS container:

- `PolySoundContainer` plays all sounds nested within.
- `RandomSoundContainer` plays 1 or more sounds nested within, chosen at random, the number of which is specified in the `play(num)` call, or in the sound number export variable.
- `ScatterSoundContainer` will 'scatter' multiple sounds at random times, by use of 1 or more timers. More on scattering below.
- `ConcatSoundContainer` plays a random sequence of nested sounds, the number of which is specified in the call, or in the export variable.
- `MultiSoundContainer` can contain any of the other containers, or AudioStreamPlayers, and will play all nodes nested within.

And, similar to the AudioStreamPlayers found natively in Godot, there is a Node (no position), 2D, and 3D type for each container.
To play a container, simply call `play()`! 

![A PolySoundContainer](https://i.imgur.com/xkDToeA.png)

Also note that each container has four export variables - autoplay, volume and pitch ranges, and sound number (which we will come to in a moment). Autoplay, as the name suggests, plays the sound the moment it is added to the scene. This is useful for bullets and other items that should make a sound on appearance. The volume and pitch ranges are the randomisation ranges of those respective properties, and is relative to the volume and pitch of the nested sounds.
For instance, an audioplayer set to -10db at a pitch scale of 1, under a container with volume range set to 2 and pitch range set to 0.3, will range between the volumes of -12 and -8 db, and the pitch scales of -0.7 and 1.3.
The sound number is only relevant for random containers and concat containers. This is the number of random sounds to play in the `play()` call.

![Volume and pitch range](https://i.imgur.com/7wHUErS.png)

### Sound scattering

Scattering sounds is great for ambience. Load up all the sounds you can imagine randomly occuring in a place - animal calls in a forest, shouting and cars in a city - and let MDS do the rest.

[An example of sound scattering in Hell Hal](https://streamable.com/l5sxx)

Achieved by calling the scatter function once in _ready()!

To scatter a group of sounds, arrange them nested in a container like usual.
If you want the sounds to begin scattering as soon as the scene is loaded, check `Autoplay` in the scatter sound container, and edit the properties in the inspector to how you'd like it.

![Scatter sound properties](https://i.imgur.com/WcLjKvA.png)

If you'd prefer to begin scattering at a different time, simply call play(), like any other sound container!
	
Either method will generate 'voices' number of timers, the timeouts of each being determined randomly between the floats 'min_time' and 'max_time'.
At each timer's timeout, it will randomly play a nested sound and begin again, its timeout once more randomised.
This will continue indefinitely, randomised timers calling randomised sounds, until you call `stop()`. This will delete all the timers.
`Timeout` is the number of seconds after which to end scattering. Set to 0 if you want scattering to continue indefinitely.

---

Feel free to contact me here on Github with any questions, or on Discord at irmoz#8586.