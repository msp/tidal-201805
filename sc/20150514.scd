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
SynthDef(\super808msp, {|out, speed=1, sustain=1, pan, voice=0, n |
	var env, sound, freq;
	n = ((n>0)*n) + ((n<1)*3);
	freq = (n*10).midicps;
	env = EnvGen.ar(Env.linen(0.01, 0, 1, 1, -3), timeScale:sustain, doneAction:2);
	sound = LPF.ar(SinOscFB.ar(XLine.ar(freq.expexp(10, 2000, 1000, 8000), freq, 0.025/speed), voice), 9000);
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
}).add;

// a moog-inspired square-wave synth; variable-width pulses with filter frequency modulated by an LFO
// "voice" controls the pulse width (exactly zero or one will make no sound)
(
	SynthDef(\supersquaremsp, {|out, speed=1, decay=0, sustain=1, pan, accelerate, freq,
		voice=0.5, semitone=12, resonance=0.2, lfo=1, pitch1=1|
		var env = EnvGen.ar(Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3), timeScale:sustain, doneAction:2);
		var basefreq = freq* Line.kr(1, 1+accelerate, sustain);
		var basefreq2 = basefreq / (2**(semitone/12));
		var lfof1 = min(basefreq*10*pitch1, 22000);
		var lfof2 = min(lfof1 * (lfo + 1), 22000);
		var sound = (0.7 * Pulse.ar(basefreq, voice)) + (0.3 * Pulse.ar(basefreq2, voice));
		sound = MoogFF.ar(
			sound,
			SinOsc.ar(basefreq/64*speed, 0).range(lfof1,lfof2),
			resonance*4);
		sound = sound.tanh * 2;
		OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
	}).add
);

)


// SEQUENCE ///////////////////////////////////////////////////

(


Pdef (
	\kckpat,
	Pbind(
		\instrument, \kckmsp,
		\dur, 2,
		\freq, 550,
		\out, 3,
		\amp, 0.7
	);
).stop;

p = Pdef (
	\sinepat,
	Pbind(
		\instrument, \sine,
		\dur, Pwhite(0.05, 0.5, inf),
		// \midinote, Pseq([40], inf),
		// \harmonic, Pexprand(1, 50, inf).round,
		\freq, Pexprand(800, 1000, inf),
		\atk, Pwhite(0.1, 0.3, inf),
		\rel, Pwhite(5.0, 10.0, inf),
		// \amp, Pkey(\harmonic).reciprocal * 0.4,
		\amp, Pexprand(0.01, 0.15, inf),
		\pan, Pwhite(-0.9, 0.9, inf),
        \out , 18,
	);
).play;


)

p.stop
