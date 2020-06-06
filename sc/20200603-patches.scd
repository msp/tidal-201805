// synthdef.art ////////////////////////////////////////////////////////////////

(
    play {
        l = LocalIn.ar(8);
	// o = {|i| Pulse.ar(l[i]*16 + 95, 0.9.rand) } ! 8;
     	o = {|i| Pulse.ar(l[i]*16 + rrand(64,66), 0.9.rand) } ! 8;
        LocalOut.ar(o.reverse.tanh);
        w = BLowShelf.ar(_, 447, 1, _);
        p = BPeakEQ.ar(_, 285, 1, _);
        h = BHiShelf.ar(_, 1200, 1, _);
        o = Splay.ar(o);
        o = h.(w.(p.(o, 48), -48), -48);
	    o = GVerb.ar(tanh(o)).flop.mean;


	    s = LeakDC.ar(Limiter.ar(h.(w.(p.(o, -48), 48), 48)));
	    OffsetOut.ar(~out15, DirtPan.ar(s, ~dirt.numChannels, 0, 0.31));

    }
)


(
    play {
        c = LFDNoise1.ar(_,0.5,0.5);
        o = Saw.ar(_);
        e = SelectX;
    x = [1,2,3,4.5].collect {|i|
		// r = i * 195;
		r = i * 50;
            e.ar(c.(1/7), [
                e.ar(c.(1/3), o.(r*[3,2])),
                e.ar(c.(1/5), o.(r*[9/8,4/3])),
            ]) * LFPulse.ar([0.5,0.51]).range(0, 1).lag(0.05);
        };
        x = Splay.ar(x.sum);
        x = x * 0.5 + RLPF.ar(GVerb.ar(x.sum*0.1,60,10),7e3);

	    s = tanh(x);
	    OffsetOut.ar(~out15, DirtPan.ar(s, ~dirt.numChannels, 0, 0.1));
    }
)

(
play {
    o = SinOsc;
    d = Decay;
    x = (0..2).collect {|i|
        TDuty.ar(1/8, 0, Dseq(scramble([1, 1] ++ (0!(9+i))), inf))
    };

    k = d.ar(x[0], 2);
    m = d.ar(x[1]);

    s = Limiter.ar(
        9 * [
            o.ar(80*k).tanh * k,
            o.ar(2*80*m).sin * m,
            GVerb.ar(o.ar(999) * d.ar(Impulse.ar(1/8)),99,10),
            (BPF.ar(WhiteNoise.ar(2))).sin * d.ar(x[2],0.5)
        ].sum.sin
    );

	OffsetOut.ar(~out15, DirtPan.ar(s, ~dirt.numChannels, 0, 0.2));
}
)