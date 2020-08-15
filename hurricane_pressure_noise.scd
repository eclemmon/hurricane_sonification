s = Server.default.boot;

~netaddress = NetAddr.new("127.0.0.1", 57120)

(
SynthDef(\noise1, {
	arg freq;
	var lag = Lag2.kr(freq, 0.5);
	var sig = LFNoise1.ar(lag);
	Out.ar(0, sig);
}).add;
)

(
SynthDef(\sinTone, {
	arg freq;
	var lag = Lag2.kr(freq, 0.5);
	var sig = SinOsc.ar(lag, mul: 0.7);
	Out.ar(0, sig);
}).add;
)

~noise1 = Synth(\noise1, [\freq, 1000]);

~noise1.set(\freq, 10000);




(
// ~noise1 = Synth(\noise1, [\freq, 1000]);
~sinTone = Synth(\sinTone, [\freq,1000]);

OSCFunc({ |args|
	"OSCFUNC received the following values:".postln;
	args[1..].postln;
	args[2].postln;
	// ~noise1.set(\freq, args[2]);
	~sinTone.set(\freq, args[2]);
}, '/s_new');
)
