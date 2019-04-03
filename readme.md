# Mixing Desk 2.0.2 for Godot

The Mixing Desk is a complete audio solution for the Godot Engine.
Godot already ships with some awesome audio capabilities - namely the bus system which is so intuitive for audio.
Generally speaking, this makes it easy to implement audio in Godot.
But for some more advanced features, a bit of coding is required.

That's where Mixing Desk comes in. A modular plugin, allowing for procedural audio and adaptive music in games, with just a couple of nodes and a line of code for each implementation.

# Mixing Desk: Music

The MDM was designed to make adaptive,interactive music easier to design within Godot.

### Setting up MDM

![Typical MDM instance](https://i.imgur.com/nit8A97.png)

**Core Tracks**

Create a MixingDeskMusic, and place Song nodes for each of your songs, similar to in the image above. As you can see, the main song files are placed under a "CoreContainer", which plays all the audio nodes under it by default. As for the other nodes, they are overlays, which we will come to shortly. Here's a sample layout:

### You *must* fill in the properties in the song node!
![Typical properties](https://i.imgur.com/DS97YEI.png)

If you don't know the tempo of the music you're using, ask the composer. If you don't know the composer, check the website where you downloaded the music, or the readme in the sample pack you downloaded. If in doubt, try out BPM detection software such as here: https://www.conversion-tool.com/bpmdetector/?lang=en
Similar process for bars and the other properties.


### Overlays (random & sequence tracks)

![Example of an overlay setup](https://i.imgur.com/Yr3suBT.png)

Overlays are set up in much the same way as core tracks. Create a RandomContainer, and a random track from that folder will be played on each repeat, with a slight chance of no track playing depending on the value of `random_chance` - if the random number generated each time song plays is lower than the value of `random_chance`, the track plays.
	
SeqContainers play the audio nodes in order, from top to bottom, and over again. Overlays must be equal length or shorter than the corresponding core tracks.

Use a ConcatContainer for a group of short tracks, particularly percussion, that you wish to play in random order over the top of the song. These tracks will be chosen randomly and each will immediately follow the previous. Good for randomising drums by the measure, or whichever length samples you choose to throw in.

### Loading and hitting play

Once your nodetree is setup, you're all ready to play your music in Godot.

First, pick a play mode. It's a property of the MDM node.

> 0: play once

> 1: loop

> 2: shuffle

	note: all vertical/horizontal adaptive features are available in all play modes!

Now, in your scene, simply call `_init(track)` to load the track ready to play.
Then, call `_play(track)` - track in both cases being either the name of the song node you wish to play, or its index, counting from 0. Either will work, though names are easier for us humans to remember, while index numbers are easier to do maths on - it's your call.

### Adapting the music in code

Based on implementations of interactive music in [FMOD](https://www.fmod.com/) and [Wwise](https://www.audiokinetic.com/products/wwise/),  the MDM neatly covers the two major branches of adaptive music outlined by [Michael Sweet](https://www.designingmusicnow.com/2016/06/13/advantages-disadvantages-common-interactive-music-techniques-used-video-games/).

### **Vertical Remixing/Layering**
MDM can fade individual tracks in and out using the `_fade_in(track)` or `_fade_out(track)` functions. It can also fade multiple tracks in/out at once with the `_mute_below_layer(track)` and `_mute_above_layer(track)` functions. To begin a track with a base layer only, the `_start_alone(track, layer)` function can be used.

[Video Example](https://streamable.com/csjyi)

To control an individual track's volume constantly based on a parameter, however, is only slightly more tricky. The `_bind_to_param(track,param)` is called to initialise the process. Of course, 'track' refers to which musical layer to control. 'Param' is the initial value to initialise with. For example, you may use it to fade a layer in and out over distance. To keep this up, you will need to call the `_feed_param(param,val)` function in a process function in your game's code. 'Param' is the index of the parameter you wish to modulate, which will be in the order which you set up the parameters. If it is the first, then it would be index 0. 'Val' is the value to send to MDM to affect the volume. This has to be a normalised value between 0 and 1 - 0 being silent, 1 being full volume. To achieve this, simply divide the current value by the max possible value - for example, the max range from an enemy at which to apply tension.

### **Horizontal Resequencing**
MDM consistently keeps track of beats and bars, and output signals accordingly. Aligning with this functionality is the ability to switch between songs on the fly, either on the beat or on the bar. This is easily achieved using the `_queue_beat_transition(track)` or `_queue_bar_transition(track)` functions.

[Video Example](https://streamable.com/1cx2w)

[Video example of both horizontal and vertical techniques in action](https://streamable.com/wzaze)

### Integrating the music and game

![MDM signals](https://i.imgur.com/3azVGMe.png)

MDM outputs beat and bar signals which can easily be connected to any other node in the scene. This way, you can time events in the game to the music. For example, a `yield(mdm, 'bar')` can delay actions until they're in sync with the next bar.

---

# Mixing Desk: Sound

The MDS is a fully-featured sound-playing plugin, allowing procedural playback of multiple layered and combined sounds through the gratuitous use of the _iplay(sound) function!


### Setting up MDS

MDS is slightly different to MDM - there are still container nodes, but no parent Mixing Desk. There are 4 kinds of MDS container:

- `PolySoundContainer` plays all sounds nested within.
- `RandomSoundContainer` plays 1 or more sounds nested within, chosen at random, the number of which is specified in the _play(num) call.
- `ScatterSoundContainer` will 'scatter' multiple sounds at random times, by use of 1 or more timers. More on scattering below.
- `ConcatSoundContainer` plays a random sequence of nested sounds, the number of which is specified in the call.

And, similar to the AudioStreamPlayers found natively in Godot, there is a Node (no position), 2D, and 3D type for each container.
To play a container, simply call _play()! 

![A PolySoundContainer](https://i.imgur.com/xkDToeA.png)

Also note that each container two export variables - volume range, and pitch range. This is the randomisation range of those respective properties, and is relative to the volume and pitch of the nested sounds.
For instance, an audioplayer set to -10db at a pitch scale of 1, under a container with volume range set to 2 and pitch range set to 0.3, will range between the volumes of -12 and -8 db, and the pitch scales of -0.7 and 1.3.

![Volume and pitch range](https://i.imgur.com/h3fhaZr.png)

### Sound scattering

Scattering sounds is great for ambience. Load up all the sounds you can imagine randomly occuring in a place - animal calls in a forest, shouting and cars in a city - and let MDS do the rest.

[An example of sound scattering in Hell Hal](https://streamable.com/l5sxx)

Achieved by calling the scatter function once in _ready()!

To scatter a group of sounds, arrange them nested in a container like usual.
At the point you want to begin scattering - if for ambience, this will likely be `_ready()` - simply call:

	_begin(voices, tmin, tmax, ran)
	
This will generate 'voices' number of timers, the timeouts of each being determined randomly between the floats 'tmin' and 'tmax'.
At each timer's timeout, it will randomly play a nested sound and begin again, its timeout once more randomised.
This will continue indefinitely, randomised timers calling randomised sounds, until you call `_end()`. This will delete all the timers.

---

Feel free to contact me here on Github with any questions, or on Discord at Irmoz#8586.