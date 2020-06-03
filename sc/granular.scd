Quarks.gui

TGrains2


b = Buffer.read(s,Platform.resourceDir +/+ "sounds/a11wlk01.wav");

//three different possible grains
(

{
	var singrain1, singrain2, sfgrain;

	singrain1=SinOsc.ar(440,0,XLine.kr(1.0, 0.0001, 0.05));

	singrain2=FSinOsc.ar(800, 0.0, Line.kr(1.0,0,0.05).squared);

	sfgrain=(PlayBuf.ar(1,b.bufnum, BufRateScale.kr(b.bufnum)))*EnvGen.kr(Env([0,1,1,0],[0.01,0.01,0.01], -4));

	[singrain1,singrain2,sfgrain]
}.plot(0.1,s)
)


(
SynthDef(\sinegrain, {arg pan, freq, amp; var grain;

grain= SinOsc.ar(freq, 0, amp)*(XLine.kr(1.001,0.001,0.1,doneAction:2)-0.001);

Out.ar(0,Pan2.ar(grain, pan))}).add;
)

Synth(\sinegrain,[\freq,rrand(100,10000),\amp, exprand(0.05,0.1), \pan, 1.0.rand2]);

(
{
100.do{arg i;

	Synth(\sinegrain,[\freq,rrand(100,10000),\amp, exprand(0.05,0.1), \pan, 1.0.rand2]);
	0.1.wait
};
}.fork
)

//schedule 200 random grains over time, decreasing the range of allowed random frequencies and lowering the density over time
(
{
	200.do{arg i;
		var timeprop = (i/199.0)**3;

		Synth(\sinegrain,[\freq,exprand(100,5000-(20*i)),\amp, exprand(0.05,0.1), \pan, 1.0.rand2]);
		rrand((timeprop*0.1).max(0.01),timeprop*0.3).wait
	};
}.fork
)

//simple playbuf grain synthdef - note the all important doneAction
(
SynthDef(\sfgrain, {arg bufnum=0, pan=0.0, startPos=0.0, amp=0.1, dur=0.04;
var grain;

grain= PlayBuf.ar(1,bufnum, BufRateScale.kr(bufnum), 1, BufFrames.ir(bufnum)*startPos, 0)*(EnvGen.kr(Env.perc(0.01,dur),doneAction:2)-0.001);

Out.ar(0,Pan2.ar(grain, pan))}).add;
)


b = Buffer.read(s,Platform.resourceDir +/+ "sounds/a11wlk01.wav");


//individual grain
Synth(\sfgrain,[\bufnum, b.bufnum, \startPos,rrand(0.0,1.0),\amp, exprand(0.005,0.1), \pan, 1.0.rand2]);


//schedule 200 random soundfile playback grains over time, with random offset positions into the soundfile and lowering the density over time
(
{
200.do{arg i;
var timeprop = (i/199.0)**3;

	Synth(\sfgrain,[\bufnum, b.bufnum, \startPos,rrand(0.0,timeprop),\amp, exprand(0.005,0.1), \pan, 1.0.rand2]);
	rrand((timeprop*0.1).max(0.01),timeprop*0.4).wait
};
}.fork
)


(
{
	var b = 10, trate, dur, rate;
	trate = MouseY.kr(2,200,1);
	dur = 4 / trate;
	rate = Dseq([10, 1, 1, 0.5, 0.5, 0.2, 0.1], inf);
	TGrains.ar(2, Impulse.ar(trate), b, rate, MouseX.kr(0,BufDur.kr(b)), dur, Dseq([-1, 1], inf), 0.1, 2);
}.scope(zoom: 4);
)

(
{
	var b = 10, trate, dur, clk, pos, pan;
	trate = MouseY.kr(8,120,1);
	dur = 12 / trate;
	clk = Impulse.kr(trate);
	pos = MouseX.kr(0,BufDur.kr(b)) + TRand.kr(0, 0.01, clk);
	pan = WhiteNoise.kr(0.6);
	TGrains.ar(2, clk, b, 1, pos, dur, pan, 0.1);
}.scope(zoom: 4);
)

(
{
	var b = 10, trate, dur, clk, pos, pan;
	trate = MouseY.kr(8,120,1);
	dur = 12 / trate;
	clk = Impulse.kr(trate);
	pos = MouseX.kr(0,BufDur.kr(b)) + TRand.kr(0, 0.01, clk);
	pan = WhiteNoise.kr(0.6);
	TGrains.ar(4, clk, b, 1, pos, dur, pan, 0.1);
}.scope(4, zoom: 4);
)


// demand ugens as inputs
(
{
	var trate, dur, z, d;
	trate = MouseX.kr(1, 100, 1);
	d = { Dwhite(0.1, 0.2, 1) };
	z = {
		Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))])
	};
	TGrains.ar(2,
		Impulse.ar(trate),
		bufnum: 10,
		rate: Dseq([1, 1, z.value, 0.5, 0.5, 0.2, 0.1, 0.1, 0.1, 0.1], inf) * 2 + 1,
		centerPos: Dseq(z.dup(8), inf),
		dur: Dseq([1, d.value, 1, z.value, 0.5, 0.5, 0.1, z.value] * 2, inf) / trate,
		pan: Dseq([1, 1, 1, 0.5, 0.2, 0.1, 0, 0, 0], inf) * 2 - 1,
		amp: Dseq([1, 0, z.value, 0, 2, 1.0, 1, 0.1, 0.1], inf)
	);
}.scope(zoom: 4);
)

