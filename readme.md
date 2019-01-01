# Mixing Desk for Godot

The Mixing Desk is a complete audio solution for the Godot Engine.
Godot already ships with some awesome audio capabilities - namely the bus system which is so intuitive for audio.
Generally speaking, this makes it easy to implement audio in Godot.
But for some more advanced features, a bit of coding is required.

That's where Mixing Desk comes in. A modular plugin, allowing for procedural audio and adaptive music in games, with just a couple of nodes and a line of code for each implementation.

## Mixing Desk: Music

The MDM was designed to make adaptive,interactive music easier to design within Godot.

### Setting up MDM

![Typical MDM instance](https://i.imgur.com/DvY1zy8.png)

**Core Tracks**

Instance MDM into your scene, or build a node tree similar to the one in the image above. As you can see, the main song files are placed in a 'core' folder beneath their song title. As for the other folders, they are overlays, which we will come to shortly. Here's a sample layout if you wish to delete the example songs and create your own:
```
MDM (mixing_desk_music.gd)
>SONGS
>>SONG1 (songprops.gd)
>>>core
>>>>LAYER1.OGG
>>>>LAYER2.OGG
>>>ranperc
>>>>HATS1.OGG
>>>>HATS2.OGG
>>>>TOMS.OGG
>>SONG2 (songprops.gd)
>>>core
>>>>LAYER1.OGG
>>>>LAYER2.OGG
>>>>LAYER3.OGG
```

### You *must* fill in the properties in `songprops.gd`!
![Typical properties in songprops.gd](https://i.imgur.com/5qV3Urm.png)

If you don't know the tempo of the music you're using, ask the composer. If you don't know the composer, check the website where you downloaded the music, or the readme in the sample pack you downloaded. If in doubt, try out BPM detection software such as here: https://www.conversion-tool.com/bpmdetector/?lang=en
Similar process for bars and the other properties.


### Overlays (random & sequence tracks)

![Example of an overlay setup](https://i.imgur.com/DX0wTpg.png)

Overlays are set up in much the same way as core tracks. Create a node folder with `ran` in its name, and a random track from that folder will be played on each repeat, with a slight chance of no track playing depending on the value of `random padding`.
	
	The 'random padding' is added to a random integer that picks which track plays.
	If the number is too high (has no corresponding audio track), nothing plays.
	
A node folder with `seq` in its name plays in order, from top to bottom, and over again. Overlays must be equal length or shorter than the corresponding core tracks. 

### Loading and hitting play

Once your nodetree is setup, you're all ready to play your music in Godot.

First, pick a play mode. It's an export int in `mixing_desk_music.gd`.

> 0: play once

> 1: loop

> 2: shuffle

	note: all vertical/horizontal adaptive features are available in all play modes!

Now, in your scene, simply call `_init(track)` to load the track ready to play.
Then, call `_play(track)` - track in both cases being the index of the song you want to play, counting from 0.

### Adapting the music in code

Based on implementations of interactive music in [FMOD](https://www.fmod.com/) and [Wwise](https://www.audiokinetic.com/products/wwise/),  the MDM neatly covers the two major branches of adaptive music outlined by [Michael Sweet](https://www.designingmusicnow.com/2016/06/13/advantages-disadvantages-common-interactive-music-techniques-used-video-games/).

### **Vertical Remixing/Layering**
MDM can fade individual tracks in and out using the `_fade_in(track)` or `_fade_out(track)` functions. It can also fade multiple tracks in/out at once with the `_mute_below_layer(track)` and `_mute_above_layer(track)` functions. To begin a track with a base layer only, the `_start_alone(track, layer)` function can be used.

[Video Example](https://streamable.com/csjyi)

### **Horizontal Resequencing**
MDM consistently keeps track of beats and bars, and output signals accordingly. Aligning with this functionality is the ability to switch between songs on the fly, either on the beat or on the bar. This is easily achieved using the `_queue_beat_transition(track)` or `_queue_bar_transition(track)` functions.

[Video Example](https://streamable.com/1cx2w)


## Mixing Desk: Sound
Documentation coming soon...