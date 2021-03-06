// Boot Server
(
s = Server.default.boot;
ServerOptions.outDevices;
~netaddress = NetAddr.new("127.0.0.1", 57120);
)
// Run Program
(
// Below here loads the SynthDefs into server memory.
(
SynthDef(\noise1, {
	arg freq, amp=1;
	var lag = Lag2.kr(freq*1000, 0.05);
	var sig = LFNoise1.ar(lag, 0.2).dup;
	Out.ar(0, sig);
}).add;
);

(
SynthDef(\noise2, {
	arg freq, rq=0.05, amp=2;
	var lag = Lag2.kr(freq*1000, 0.1);
	var noise = BrownNoise.ar(0.1.dup);
	var sig = BPF.ar(noise, lag, rq: rq) * amp;
	Out.ar(0, sig);
}).add;
);

(
SynthDef(\h1, {
	arg pressure=1000, speed=440, out=0, amp=5, rq=0.01;
	var lag = Lag.kr(speed*1.7, lagTime: 0.1);
	var noise = BrownNoise.ar(0.3);
	var sig = BPF.ar(in: noise, freq: lag, rq: rq)*amp;
	var pan = Pan2.ar(sig, pos:-1);
	Out.ar(out, pan);
}).add;
);

(
SynthDef(\h2, {
	arg pressure=1000, speed=440, out=0, amp=4, rq=0.01;
	var lag = Lag.kr(speed*1, lagTime: 0.1);
	var noise = BrownNoise.ar(0.3);
	var sig = BPF.ar(in: noise, freq: lag, rq: rq)*amp;
	var pan = Pan2.ar(sig, pos:0);
	Out.ar(out, pan);
}).add;
);

(
SynthDef(\h3, {
	arg pressure=1000, speed=440, out=0, amp=5, rq=0.01;
	var lag = Lag.kr(speed*0.4737, lagTime: 0.1);
	var noise = BrownNoise.ar(0.3);
	var sig = BPF.ar(in: noise, freq: lag, rq: rq)*amp;
	var pan = Pan2.ar(sig, pos: 1.0);
	Out.ar(out, pan);
}).add;
);

(
SynthDef(\reverb_h1, {
	| in = 99, out = 0 |
	var input = In.ar(in, 2);
	var reverb = FreeVerb.ar(input, mix: 0.67, room: 0.33);
	var pan = Pan2.ar(reverb, -1.0);
	Out.ar(out, pan);
}).add;
);

(
SynthDef(\reverb_h2, {
	| in = 98, out = 0 |
	var input = In.ar(in, 2);
	var reverb = FreeVerb.ar(input, mix: 0.67, room: 0.33);
	var pan = Pan2.ar(reverb, 0);
	Out.ar(out, pan);
}).add;
);

(
SynthDef(\reverb_h3, {
	| in = 97, out = 0 |
	var input = In.ar(in, 2);
	var reverb = FreeVerb.ar(input, mix: 0.67, room: 0.33);
	var pan = Pan2.ar(reverb, pos: 1.0);
	Out.ar(out, pan);
}).add;
);

(
// Initializes the Synths
~reverb_h1 = Synth(\reverb_h1, [\in, 99, \out, 0]);
~h1 = Synth(\h1, [\pressure, 1000, \speed, 440, \out, 99, \amp, 0]);
~reverb_h3 = Synth(\reverb_h3, [\in, 97, \out, 0]);
~h3 = Synth(\h3, [\pressure, 1000, \speed, 440, \out, 97, \amp, 0]);
~reverb_h2 = Synth(\reverb_h2, [\in, 98, \out, 0]);
~h2 = Synth(\h2, [\pressure, 1000, \speed, 440, \out, 98, \amp, 0]);

// OSCFunc accepts OSC messages from python
OSCFunc({ |args|
	var h1_p, h1_s, h2_p, h2_s, h3_p, h3_s;
	"OSCFUNC received the following values:".postln;
	args[1..].postln;

	// function changes the parameters here
	h1_p = args[4].linlin(955, 1000, 980, 1000);
	h2_p = args[8].linlin(955, 1000, 980, 1000);
	h3_p = args[12].linlin(955, 1000, 980, 1000);

	h1_s = args[6].linlin(24, 70, 100, 1000);
	h2_s = args[10].linlin(35, 70, 100, 1000);
	h3_s = args[14].linlin(30, 70, 100, 1000);

	// Elegantly turn off synths when hurricane is not
	// a hurricane (wind speed drops below threshhold).
	if(args[6]==0.0) {
		~h1.set(\amp, 0);
	} {
		~h1.set(\pressure, h1_p, \speed, h1_s, \amp, 1);
	};

	if(args[10]==0.0) {
		~h2.set(\amp, 0);
	} {
		~h2.set(\pressure, h2_p, \speed, h2_s, \amp, 1);
	};

	if (args[14]==0.0) {
		~h3.set(\amp, 0);
	} {
		~h3.set(\pressure, h3_p, \speed, h3_s, \amp, 1);
	};
}, '/s_new');
);

OSCFunc({ |args|
	// Turns recording on and off...via OSC from python.
	"OSCFUNC received the following values:".postln;
	args[1..].postln;

	if (args[1] == 1) {
		s.record;
	} {
		s.stopRecording;
	};
}, '/record');
)