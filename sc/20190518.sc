
// a moog-inspired PWM synth; pulses multiplied by phase-shifted pulses, double filtering with an envelope on the second
// "voice" controls the phase shift rate
(
	SynthDef(\mspsuperpwm, {|out, rate=1, decay=0, sustain=1, pan, accelerate, freq,
		voice=0.5, semitone=12, resonance=0.2, lfo=1, pitch1=1|
		var env = EnvGen.ar(Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3), timeScale:sustain, doneAction:2);
		var env2 = EnvGen.ar(Env.pairs([[0,0.1],[0.1,1],[0.4,0.5],[0.9,0.2],[1,0.2]], -3), timeScale:sustain/rate);
		var basefreq = freq * Line.kr(1, 1+accelerate, sustain);
		var basefreq2 = basefreq / (2**(semitone/12));
		var lfof1 = min(basefreq*10*pitch1, 22000);
		var lfof2 = min(lfof1 * (lfo + 1), 22000);
		var sound = 0.7 * PulseDPW.ar(basefreq) * DelayC.ar(PulseDPW.ar(basefreq), 0.2, Line.kr(0,voice,sustain)/basefreq);
		sound = 0.3 * PulseDPW.ar(basefreq2) * DelayC.ar(PulseDPW.ar(basefreq2), 0.2, Line.kr(0.1,0.1+voice,sustain)/basefreq) + sound;
		sound = MoogFF.ar(sound, SinOsc.ar(basefreq/32*rate, 0).range(lfof1,lfof2), resonance*4);
		sound = MoogFF.ar(sound, min(env2*lfof2*1.1, 22000), 3);
		sound = sound.tanh*5;
		OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
	}).add
);

// feedback PWM
// can use "accelerate" "voice" and "detune" parameters
// try `d1 $ s "supertron" # octave 3 # accelerate "0.2"`
(
SynthDef(\mspsupertron, {|out, pan, freq, sustain, voice, detune, accelerate, att = 0.05|
	var sound, aenv, s1, s2;
    // aenv = EnvGen.ar(Env.linen(0.05, 0.85, 0.1, 1, 'lin'), timeScale:sustain, doneAction:2);
	aenv = EnvGen.ar(Env.linen(att, 0.2, 0.4, 1, 'lin'), timeScale:sustain, doneAction:2);
    freq = freq * XLine.ar(1, exp(accelerate), sustain);
	sound = LocalIn.ar(1);
	sound = Mix.ar( Pulse.ar(freq+[1+detune,-1-detune], RLPF.ar(sound, freq/6.1, 1.5).range(0,1-(voice/1.5))) );
	sound = LeakDC.ar(sound);
	LocalOut.ar(sound);
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, aenv))
}).add;
);

// Vaguely Reese-like synth
// can use "accelerate" "voice" and "detune" parameters
(
SynthDef(\mspsuperreese,  {|out, pan, freq, sustain, accelerate, detune=0, voice=0, att = 0.05|
	var sound;
	var env = EnvGen.ar(Env.linen(att, 0.8, 0.95), timeScale:sustain, doneAction:2);
	var q1 = voice.linlin(0, 2, 3.0, 0.5);
	var q2 = voice.linlin(0, 2, 2.0, 7.0);
	freq = freq * XLine.ar(1, exp(accelerate), sustain);
	sound = Splay.ar( VarSaw.ar(freq*[-1*detune/100+0.99,detune/100+1.01], [0.7,0.5], [0.01,0.02]), 0.2, 1, levelComp:false );
	sound = RLPF.ar(sound, freq*10, 1.0/q1);
	sound = sound.clip2(1.0/5.0)* 5.0;
	sound = 0.35*RLPF.ar(sound, freq*20, 1.0/q2);
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;
);