// SYNTH //////////////////////////////////////////////////////
(
SynthDef(\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0, out=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1 -1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(out, sig);
}).add;
)

(
// A vaguely 808-ish kick drum
// "n" controls the chirp frequency, "sustain" the overall timescale, "speed" the filter sweep speed,
// and "voice" the sinewave feedback
(
	SynthDef(\super808, {|out, speed=1, sustain=1, pan, voice=0, n |
		var env, sound, freq;
		n = ((n>0)*n) + ((n<1)*3);
		freq = (n*10).midicps;
		env = EnvGen.ar(Env.linen(0.01, 0, 1, 1, -3), timeScale:sustain, doneAction:2);
		sound = LPF.ar(SinOscFB.ar(XLine.ar(freq.expexp(10, 2000, 1000, 8000), freq, 0.025/speed), voice), 9000);
		OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
	}).add
);
// phased saws
// "decay" and "accelerate" used as in some synths above, for envelope shaping and pitch bend, respectively
// "slide" here is how fast it moves through the phase (default 1)
// "detune" is for oscillator detuning and defaults to 1

SynthDef(\superzow_msp, {|out, sustain=1, pan, accelerate, freq, attack=0.5, decay=0.5, slide=1, detune=1 |

	var env = EnvGen.ar(Env.pairs([[0,0],[attack,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -1), timeScale:sustain, doneAction:2);

	// var env = EnvGen.kr(Env.adsr(0, 0.7, 0.7, 0.8, 1, -4), timeScale:sustain, doneAction: 2);

	var basefreq = freq * Line.kr(1, 1+accelerate, sustain);
	var sound = VarSaw.ar(basefreq, 0, Line.ar(0,0.5,sustain*20/slide));
	var sound2 = VarSaw.ar(basefreq*(detune/100+1), 0, Line.ar(0,0.5,sustain*20/slide));
	var sound3 = VarSaw.ar(basefreq*(-1*detune/100+1), 0, Line.ar(0,0.5,sustain*20/slide));
	sound = sound - DelayN.ar(sound2,0.2, Line.ar(0,1,5*sustain/slide)/basefreq)
	+ DelayN.ar(sound3,0.2, Line.ar(0,1,20*sustain/slide)/basefreq);
	OffsetOut.ar(out, DirtPan.ar(sound/2, ~dirt.numChannels, pan, env));
}).add



)

var decay = 0;

decay.postln


Env.pairs([[0,0],[0.7,1],[0.2,1-0.5],[0.95,1-0.5],[1,0]], -1).plot

Env.adsr(0, 0.7, 0.7, 0.25, 1, -2).plot;


// SEQUENCE ///////////////////////////////////////////////////

(


Pdef (
	\kckpat,
	Pbind(
		\instrument, \kckmsp,
		\dur, 2,
		\freq, 150,
		\out, 3,
		\amp, 0.7
	);
).stop;

p = Pdef (
	\testpat,
	Pbind(
		\instrument, \superpiano,
		// \dur, Pwhite(0.05, 0.5, inf),
		// \midinote, Pseq([40], inf),
		// \harmonic, Pexprand(1, 50, inf).round,
		// \freq, Pexprand(800, 10000, inf),
		// \atk, Pwhite(0.1, 0.7, inf),
		// \rel, Pwhite(5.0, 10.0, inf),
		// \amp, Pkey(\harmonic).reciprocal * 0.4,
		// \amp, Pexprand(0.01, 0.15, inf),
		// \pan, Pwhite(-0.9, 0.9, inf),
	);
).play;
)

p.stop

(
p = Pdef (
	\testsine,
	Pbind(
		\instrument, \sine,
		// \dur, Pwhite(0.05, 0.5, inf),
		// \midinote, Pseq([50, 60, 80], inf),
		\note, Pseq([3], inf),
		// \harmonic, Pexprand(1, 50, inf).round,
		// \freq, Pexprand(800, 10000, inf),
		// \atk, Pwhite(0.1, 0.7, inf),
		// \rel, Pwhite(5.0, 10.0, inf),
		// \amp, Pkey(\harmonic).reciprocal * 0.4,
		\amp, Pexprand(0.01, 0.15, inf),
		\pan, Pwhite(-0.9, 0.9, inf),
	);
).play;
)

p.stop

(
SynthDef(\Pdefhelp, { arg out, freq, sustain=1, amp=1, pan;
    var env = EnvGen.kr(Env.perc(0.01, sustain), 1, doneAction: Done.freeSelf);
    Out.ar(out, Pan2.ar(SinOsc.ar(freq, 0.5pi, amp * env), pan));
}).add;
)

// event pattern as an argument
Pdef(\x, Pbind(\instrument, \Pdefhelp, \note, Pbrown(0, 6, 0.1, inf), \dur, 0.2));
Pdef(\x); // omitting the second argument, we can access the proxy
Pdef(\x).play; // ... play one event stream
Pdef(\x).source.postcs; // ... and inspect the event pattern itself.
