// a supercollider port of Coloscope's Pure-data organ.

SynthDef(\benoit, {
	arg out=0, amp=0.5, freq=440, semione=12, semitwo=24, trackingmul=2, gate=1, sus=1, rel=1;
	var env, sig, sig1, sig2, sig3, ringmod, tracking, sig4;

	sig1 = Pulse.ar(freq, 0.17);
	sig2 = Pulse.ar((freq.cpsmidi - semione).midicps, 0.17);
	sig3 = Pulse.ar((freq.cpsmidi + semitwo).midicps, 0.17);

	sig4 = LFTri.ar((freq.cpsmidi - semitwo).midicps);

	env = EnvGen.ar(Env.linen(0,sus,rel), gate, doneAction:2);

	tracking = ((freq * 1) + freq) * trackingmul;
	sig = sig1 + sig2 + sig3 + (sig4 * 2);


	sig = RLPF.ar(sig, tracking, 1, 0.33);
	sig = FreeVerb.ar(sig, 0.12);
	sig = sig.tanh;
	sig = sig * env;


	Out.ar(out, (sig * amp));

}).add;