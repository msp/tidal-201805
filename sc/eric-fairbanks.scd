(
    SynthDef(\donk, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0], [0.01, 1], curve:-3);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		var modulator = (SinOsc.ar(freq*[1.0001,0.9999]*abs(speed))*2).tanh;
		var carrier = (SinOsc.ar((freq/4)+(modulator*1000*envGen))*0.8).tanh;
		var sound = DirtPan.ar(carrier, ~dirt.numChannels, pan, envGen);
		Out.ar(out, sound);
	}).add;
	SynthDef(\wub, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0],[1,5], curve:2);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		// --- //
		var speedFreq = freq*abs(speed)/4;
		var mod = Latch.ar((SinOsc.ar(speedFreq*[7,11,13,5])*5).tanh*2000*envGen, Saw.ar(21000*envGen));
		var car =  Latch.ar(((SinOsc.ar(speedFreq+mod)*10)+(SinOsc.ar(speedFreq)!2)).tanh, Saw.ar(21000*envGen));
		var sound = LPF.ar(car, DC.ar(20000)*envGen+DC.ar(10))*(-11.dbamp);
		Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
	}).add;
	SynthDef(\sawpluck, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0.333, 0],[5, 70, 1000]);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		var sound = Saw.ar(freq*abs(speed));
		Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
	}).add;
	SynthDef(\vibsawpluck, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0.333, 0],[5, 70, 1000]);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		var sound = Saw.ar(freq*abs(speed)+(SinOsc.ar(10)*(freq*0.06)*line*line));
		sound = RLPF.ar(sound, Clip.ar(envGen*freq*48, 0, 20000), 0.5);
		Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
	}).add;
	(
		SynthDef(\plucklead, {
			|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
			var line = Line.ar(begin, end, sustain, doneAction:2);
			var env = Env([0, 1, 0.333, 0],[5, 70, 1000]);
			var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
			var speedFreq = freq*abs(speed);
			var pulseLfo = SinOsc.ar(Rand(-1,1));
			var sound = RLPF.ar(Pulse.ar([speedFreq*Rand(0.99,1.01)*2,speedFreq*Rand(0.99,1.01)*2],pulseLfo)*0.5+Saw.ar(speedFreq), (20000*(envGen**2.8))+DC.ar(10), 0.5);
			Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
		}).add;
	);
	SynthDef(\wob, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0],[1, 1]);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		// --- //
		var speedFreq = freq*abs(speed)/4;
		var mod = Latch.ar((SinOsc.ar(speedFreq*[7,11,13,5])*5).tanh*2000*envGen, Saw.ar(21000*envGen));
		var car =  Latch.ar(((SinOsc.ar(speedFreq+mod)*10)+(SinOsc.ar(speedFreq)!2)).tanh, Saw.ar(21000*envGen));
		var sound = car*(-10.dbamp);
		Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
	}).add;
	SynthDef(\noisebuild, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0],[127, 1],curve:4);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		// --- //
		var sound = HPF.ar(BPF.ar(WhiteNoise.ar()*envGen, 10+(20000*envGen), 0.8), 1000);
		Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
	}).add;
)