(
SynthDef(\sally, {arg freq=220, out=0, amp=0.7, res=0.5;
	var sig, env;
	sig = LFPulse.ar(Line.ar(freq, freq/4, Rand(0.01, 0.1)), 0, Rand(0.01, 0.99), amp);
	sig = RLPF.ar(sig, freq*5*Line.kr(1, 0, Rand(0.1, 0.9)), res);
	env = Env.perc(0.001, Rand(0.1, 0.8)).kr(2);
	sig = (sig * env * 2).softclip;
	sig = Pan2.ar(sig, Rand(-0.5, 0.5));
	Out.ar(out, sig);
}).add;


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

var scale = Scale.harmonicMinor;
var time = 1.2;   // beat length in seconds multiplied by

p = Pbind(
	\instrument, \pls,
	\dur, Prand([time/8, time/4], inf),
	\scale, scale,
	\degree, Pbrown(0, 12, Prand([1, 2, 3], inf)),
	\octave, 4,
	\freq, Pseq([110, 220, 330], inf),
).play
)

p.stop

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\freq, Pexprand(50, 4000, inf).trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pexprand(0.01, 0.2, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
).play
)
