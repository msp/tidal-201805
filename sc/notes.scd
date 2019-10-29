MethodOverride.printAll

Quarks.gui

Quarks.folder

// List audio interfaces
ServerOptions.devices

s.meter

s.boot

s.quit

Platform.userConfigDir


~dirt.start

~dirt.stop;

~dirt.free;


/* MID CTRL */
MIDIClient.init;

~midiOut = MIDIOut.newByName("Analog Four", "Elektron MIDI");
pSNa
~dirt.soundLibrary.addMIDI(\ana4, ~midiOut);

~midiOut.latency = 0;

/* END MID CTRL */

/* INIT TX MODULAR */
TXSystem1.start;


// Trace OSC
OSCFunc.trace(true, true); // see if network messages are coming in from tidal
OSCFunc.trace(false); // stop tracing


// Extension directory
Platform.userExtensionDir

// View MIDI devices
(
MIDIClient.init;
MIDIClient.list; // to check, which are there, you can query them
)

// tidal synths
// Not sure loading these this way is correct as it seems to overload the server. Inspect with plotTree..
"/data/development/tidal-cycles/vendor/tidal-synths/loadAll.scd".load();


(
SynthDef(\msprhodes, {|out, sustain=1, pan, freq, attack=0.001 |
	var sig, in, delay, pitch, detune, hammer, amp, env;
	amp = 0.9;


	"MSP --------".postln;
	amp.postln;
	freq = freq.cpsmidi;
	hammer = Decay2.ar(Impulse.ar(0.001), 0.008, 0.04, LFNoise2.ar([2000,4000].asSpec.map(amp), 0.25));
	sig = Mix.ar(Array.fill(3, { arg i;
			detune = #[-0.04, 0, 0.03].at(i);
			delay = (1/(freq + detune).midicps);
			CombL.ar(hammer, delay, delay, 50 * amp)
		}) );

	sig = HPF.ar(sig,50);
    env = EnvGen.ar(Env.perc(attack,sustain,amp * 4, 1), doneAction:2);
    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;

)

(
SynthDef(\kick2, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (HPF.ar(Hasher.ar(WhiteNoise.ar), 20) * Env.perc(0.003, 0.3).ar * 0.5);
    snd = snd + (SinOsc.ar(XLine.ar(750, 161, 0.02)) * Env.perc(0.0005, 0.52).ar);
    snd = snd + (SinOsc.ar(XLine.ar(167, 52, 0.04)) * Env.perc(0.0005, 0.60).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;
)

Synth(\kick2);

Synth(\fmCont, [amp: 0.6]);

// FM7 ======== by neiL
// controls:
// a1,d1,s1,r1 = attack, decay, sustain & release of envelope 1
// m1  = mod amp of envelope 1
// e12 = envelope used to modulate osc 1 with osc 2
// v1  = volume of osc 1
// p1  = pan of osc 1
// f1  = fixed freq of osc1 as MIDI note, if -- then ratio of MIDI In
// u1  = detune osc1
// t1  = transpose osc1 (only if f1 is not fixed)
// ============

Synth(\LNX_Saw1, [amp: 0.6, a1: 0.5, d1: 0.5, s1: 0.5, r1: 0.5, v1: 0.6, out: 1]);





// View running synths
Server.local.plotTree;

// View envelope shapes
Env.perc(0.4, 4,  1, 1).test.plot

Env.triangle.plot;

s.meter

s.makeWindow
