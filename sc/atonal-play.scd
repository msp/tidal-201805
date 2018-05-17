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
SynthDef(\d_sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0.5, out=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.perc(0.01, 0.1), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(out, sig);
}).add;

SynthDef(\kckbak, {arg freq=10, out=2, amp=0.9;
	var sig, env;
	// sig = SinOsc.ar(Line.ar(freq, freq/4, Rand(0.01, 0.1)), 0, 0.5, amp);
	sig = SinOsc.ar(freq);
	env = Env.perc(0.001, Rand(0.8, 1), 0.5).kr(2);
	sig = sig * env;
	sig = Pan2.ar(sig, Rand(-0.3, 0.3));
	Out.ar(out, sig);
}).add;

SynthDef(\kckmsp, {arg freq=220, out=0, amp=0.9;
	var sig, env;
	sig = SinOsc.ar(Line.ar(freq, freq/4, Rand(0.01, 0.1)), 0, 0.5, amp);
	sig = RLPF.ar(sig, freq*8*Line.kr(1, 0, Rand(0.01, 0.3)));
	env = Env.perc(0.001, Rand(0.8, 0.9), 0.5).kr(2);
	sig = (sig * env * 4).softclip;
	sig = Pan2.ar(sig, Rand(-0.3, 0.3));
	// Out.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;


)


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

Pdef (
	\sinepat,
	Pbind(
		\instrument, \sine,
		\dur, Pwhite(0.05, 0.5, inf),
		// \midinote, Pseq([40], inf),
		// \harmonic, Pexprand(1, 50, inf).round,
		\freq, Pexprand(300, 600, inf),
		\atk, Pwhite(0.1, 0.3, inf),
		\rel, Pwhite(5.0, 10.0, inf),
		// \amp, Pkey(\harmonic).reciprocal * 0.4,
		\amp, Pexprand(0.01, 0.15, inf),
		\pan, Pwhite(-0.9, 0.9, inf),
	);
).play;


)

p.stop


// debug
(
q.stop;

a = Pexprand(0.1, 0.5, inf);

q = Pbind(
	\instrument, \d_sine,
	\dur, a,
	\midinote, a.linlin(a.lo, a.hi, 55, 75),
	\amp, Pkey(\dur) * 2
).play
)


q.stop