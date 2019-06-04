(

SynthDef(\msp808, {|out, speed=1, sustain=1, pan, voice=0, att = 0.01, n |
    var env, sound, kick, synth, freq, freqCurve;
    n = ((n>0)*n) + ((n<1)*3);
    freq = (n*10).midicps;

    env = EnvGen.ar(Env.linen(att, 0, 1, 1, -3), timeScale:sustain, doneAction:2);

    // sound = LPF.ar(SinOscFB.ar(XLine.ar(freq.expexp(10, 2000, 1000, 8000), freq, 0.025/speed), voice), 9000);


    freqCurve = XLine.ar(freq.expexp(10, 2000, 1000, 8000), freq, 0.025/speed);

    kick = LPF.ar(SinOscFB.ar(freqCurve, voice), 9000);

    // synth = DynKlank.ar(`[[800, 1071, 1353, 3723], nil, [0.1, 0.1, 0.1, 1]], PinkNoise.ar([0.007, 0.007])) * 0.6;

    // sound = Mix.new([ kick, synth ]);
    sound = kick;

    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
}).add;

// a moog-inspired PWM synth; pulses multiplied by phase-shifted pulses, double filtering with an envelope on the second
// "voice" controls the phase shift rate
(
	SynthDef(\mspsuperpwm, {|out, rate=1, decay=0, sustain=1, pan, accelerate, freq,
		voice=0.5, semitone=12, resonance=0.2, lfo=1, pitch1=1, att = 0.05|
        var decay_t = att + 0.15;
		var env = EnvGen.ar(Env.pairs([[0,0],[att,1],[decay_t,1-decay],[0.95,1-decay],[1,0]], -3), timeScale:sustain, doneAction:2);
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


//adapted+modified from snare2.pd pure data patch by user ichabod of pdpatchrepo
SynthDef(\mspdxkSd3, {|t_trig = 1, basefreq = 150, att = 0.001, len = 0.3, lopfreq = 1200, rq = 0.3, tone = 0.7, snare = 0.5, amp = 1, pan = 0, out = 0, env|
	var freqs, rqs, bpmuls, fenv, drumhead, snares, noise, nmul, lonoise, hinoise, output, nenv, rand,  lofreq, hifreq, loenv, hienv, lomul;

	//random number
	rand = TIRand.kr(0,101, t_trig);

	freqs = basefreq * [1, 2.03, 3.26, 4.6];
	rqs = rq * [1/2, 1, 1/2, 1/2];
	bpmuls = 3 * [8.333, 10, 5, 1];
	fenv = EnvGen.ar(Env.perc(att, len), t_trig, doneAction: 2);
	noise = WhiteNoise.ar(1.4)+1.4;
	noise = Select.ar(noise, [DC.ar(-1), DC.ar(0), DC.ar(1)]);
	nmul = rand/800.0 + 0.875;
	nenv = EnvGen.ar(Env.perc(att, len*0.46, nmul), t_trig);
	noise = noise * nenv;

	//drum head formants
	drumhead = Resonz.ar(LPF.ar(noise, lopfreq), freqs, rqs, bpmuls);
	drumhead = drumhead * tone;

	//snares
	lofreq = rand + 900;
	hifreq = lofreq* 0.95;
	lonoise = LPF.ar(noise, lofreq);
	lomul = (rand/500.0) + 0.4;
	loenv = EnvGen.ar(Env.perc(att, len*0.66,lomul), t_trig);
	lonoise = lonoise * loenv;
	hinoise = HPF.ar(noise, hifreq);
	hienv = EnvGen.ar(Env.perc(att, len*0.466), t_trig);
	hinoise = hinoise * hienv;
	snares = lonoise + hinoise;
	snares = snares * snare;
	output = drumhead + snares;
	output = Pan2.ar(output, pan);
    // Out.ar(out, output);

    OffsetOut.ar(out, DirtPan.ar(output, ~dirt.numChannels, pan))
}).add;



SynthDef(\mspsawpluck, {
    |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
    var line = Line.ar(begin, end, sustain, doneAction:2);
    var env = Env([0, 1, 0.333, 0],[500, 70, 1000]);
    var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
    var sound = Saw.ar(freq*abs(speed));
    Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add;

SynthDef(\mspvibsawpluck, {
    |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
    var line = Line.ar(begin, end, sustain, doneAction:2);
    var env = Env([0, 1, 0.333, 0],[900, 70, 1000]);
    var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
    var sound = Saw.ar(freq*abs(speed)+(SinOsc.ar(10)*(freq*0.06)*line*line));
    sound = RLPF.ar(sound, Clip.ar(envGen*freq*48, 0, 20000), 0.5);
    Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add;


SynthDef(\mspplucklead, {
    |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
    var line = Line.ar(begin, end, sustain, doneAction:2);
    var env = Env([0, 1, 0.333, 0],[5, 70, 1000]);
    var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
    var speedFreq = freq*abs(speed);
    var pulseLfo = SinOsc.ar(Rand(-1,1));
    var sound = RLPF.ar(Pulse.ar([speedFreq*Rand(0.99,1.01)*2,speedFreq*Rand(0.99,1.01)*2],pulseLfo)*0.5+Saw.ar(speedFreq), (20000*(envGen**2.8))+DC.ar(10), 0.5);
    Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add;

)

Env([0, 1, 0.333, 0],[500, 700, 1000]).plot