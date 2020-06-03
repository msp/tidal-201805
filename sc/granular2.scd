// https://github.com/madskjeldgaard/awesome-supercollider#granular

// s.boot;

Mosca


(
~folder= "/System/Volumes/Data/Dropbox-spatial/Dropbox/spatial/music/AudioSources/oily-cart-awu-samples/segments";

// ~folder= "/System/Volumes/Data/Dropbox-spatial/Dropbox/spatial/music/AudioSources/oily-cart-awu-samples/beat";

~buffers.do{|x| x.free};

~buffers= (~folder+/+"*").pathMatch.collect{|x| Buffer.readChannel(s, x, channels:[0])};

"loading samples >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>".postln;
~buffers.do{|aFile|
	aFile.path.postln;
};

~buffers.size;
)

~buffers[0].play;

~buffers[0].query;

Env.sine(3).plot


//--load a sampler (a synth definition for playing a short grain of a buffer)
(
SynthDef(\avgrain, {|out= 14, buf, rate= 1, offset= 0, time= 0.1, amp= 0.1, pan= 0|
	var env= EnvGen.ar(Env.sine(time), doneAction:2);
	var src= PlayBuf.ar(1, buf, rate*BufRateScale.ir(buf), 1, offset*BufFrames.ir(buf), 1);
	// OffsetOut.ar(out, Pan2.ar(src*env*amp, pan));
	OffsetOut.ar(14, DirtPan.ar(src*env*amp, ~dirt.numChannels, pan));
}).add;
)

(
SynthDef(\avgrainDirt, {|out= 0, buf, rate= 1, offset= 0, time= 0.1, amp= 0.1, pan= 0|


	// var bufRate = rate*BufRateScale.ir(buf);
	// var bufRate = BufRateScale.kr(buf)*XLine.kr(0.3, 50, 10);

	// var bufRate = BufRateScale.kr(buf) * FSinOsc.kr(XLine.kr(0.2, 1, 3), 0, 3, 0.6);
	var bufRate = BufRateScale.kr(buf) * LFNoise2.kr(XLine.kr(1, 5, 2), 2);

	var trig = 1;
	// var trig = Impulse.kr(MouseY.kr(0.5, 200, 1));

	var startPos = offset*BufFrames.ir(buf);
	// var startPos = MouseX.kr(0, BufFrames.kr(buf));

	var loop = 1;

	var env= EnvGen.ar(Env.sine(time), doneAction:2);
	var src= PlayBuf.ar(1, buf, bufRate, trig, startPos, loop);

	// OffsetOut.ar(out, Pan2.ar(src*env*amp, pan));
	OffsetOut.ar(out, DirtPan.ar(src*env*amp, ~dirt.numChannels, pan));
}).add;
)

Synth(\avgrain, [\buf, ~buffers[0], \time, 0.3, \amp, 0.8])

~buffers[0].play;

//test
(
Pdef(\granulator, Pbind(\instrument, \avgrainDirt,
	\buf, Pseq(~buffers, inf),
	// \buf, ~buffers[0],
	\dur, 0.125,
	// \rate, 0.5,
	// \dur, 0.9,
	// \dur, Pseq([Prand([1, 0.2, 0.1, 0.3])], inf),
	// \time, Pseq([Prand([0.5, 0.2, 0.1, 0.3])], inf),
	\time, 0.125,
	\offset, 0,

	// \offset, Pseq([Prand([0, 0.1, 0.2, 0.5, 0.2, 0.1, 0.3])], inf),
	\amp, 0.15,
)).play;
)

//main granulator
(
Pdef(\granulator, Pbind(\instrument, \avgrain,
	\buf, Pwrand(~buffers, Pdefn(\weights, 1.dup(~buffers.size).normalizeSum), inf),
	// \dur, Pdefn(\dur, 0.125),
	\dur, Pdefn(\dur, 0.250),
	\time, Pkey(\dur)*Pdefn(\overlap, 2.5),
	\rate, Pdefn(\rate, Pwhite(1, 1, inf)),
	\offset, Pdefn(\offset, Pwhite(0.25, 0.5, inf)),
	\amp, 0.5*Pdefn(\amp, Pwhite(1, 1, inf))*Pwrand([1, 0], Pdefn(\density, [1, 0]), inf),
	\pan, Pgauss(0, Pdefn(\pan, 0.25)),
)).play;
)

//gui interface
(
var win= Window("granulator", Rect(10, 10, 800, 600));
var mul;
win.layout= VLayout(
	StaticText().string_("buffer weights / mixer:"),
	mul= MultiSliderView().value_(Pdefn(\weights).source).elasticMode_(1)
	.action_({|v| Pdefn(\weights, v.value.normalizeSum)}),
	StaticText().string_("scan through buffers:"),
	Slider().orientation_(\horizontal)
	.action_({|v| mul.valueAction_(({|i| abs(i/(~buffers.size-1)-v.value).max(0.001)** -2}!~buffers.size).normalizeSum)}),
	StaticText().string_("duration:"),
	Slider().orientation_(\horizontal).value_(Pdefn(\dur).source*10)
	.action= {|v| Pdefn(\dur, v.value*0.1+0.001)},
	StaticText().string_("rate range:"),
	RangeSlider().orientation_(\horizontal).lo_(0.5).hi_(0.5)
	.action= {|v| Pdefn(\rate, Pwhite(v.lo*2, v.hi*2, inf))},
	StaticText().string_("overlap:"),
	Slider().orientation_(\horizontal).value_(Pdefn(\overlap).source*0.05)
	.action= {|v| Pdefn(\overlap, v.value*40)},
	StaticText().string_("offset range:"),
	RangeSlider().orientation_(\horizontal).lo_(0.01).hi_(5)
	.action= {|v| Pdefn(\offset, Pwhite(v.lo, v.hi, inf))},
	StaticText().string_("density:"),
	Slider().orientation_(\horizontal).value_(1)
	.action= {|v| Pdefn(\density, [v.value, 1-v.value])},
	StaticText().string_("amplitude range:"),
	RangeSlider().orientation_(\horizontal).lo_(1).hi_(1)
	.action= {|v| Pdefn(\amp, Pwhite(v.lo, v.hi, inf))},
	StaticText().string_("panning spread:"),
	Slider().orientation_(\horizontal).value_(0.25)
	.action= {|v| Pdefn(\pan, v.value)}
);
CmdPeriod.doOnce({win.close});
win.front;
)

Pdefn(\x, Pbrown(0, 6, 0.01, inf));
Pbind(\note, Pdefn(\x), \dur, 0.3).play;
Pbind(\note, Pdefn(\x), \dur, 0.1, \ctranspose, 15).play;
// now change the definition
Pdefn(\x, Pseq([0, 3, 5, 7, 9, 11], inf));
Pdefn(\x, Pseq([0, 3, 3, 7], inf) + Pseq([0, [0, 3], [0, 5, 7]], inf));


Pdefn(\x, Pseq([1, 2, 5, 6, 7], inf));
Pdefn(\x); // omitting the second argument, we can access the proxy
Pdefn(\x).asStream.nextN(20); // ... play one event stream
Pdefn(\x).source.postcs; // ... and inspect the event pattern itself.

