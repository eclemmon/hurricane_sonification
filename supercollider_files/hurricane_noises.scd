
Server.default.options.outDevice_("External Headphones");
s = Server.default.boot;
ServerOptions.outDevices;


(
~netaddress = NetAddr.new("127.0.0.1", 57120);


(
SynthDef(\noise1, {
	arg freq, amp=1;
	var lag = Lag2.kr(freq*1000, 0.5);
	var sig = LFNoise1.ar(lag, 0.2).dup;
	Out.ar(0, sig);
}).add;
);

(
SynthDef(\noise2, {
	arg freq, rq=0.05, amp=2;
	var lag = Lag2.kr(freq*1000, 0.5);
	var noise = BrownNoise.ar(0.1.dup);
	var sig = BPF.ar(noise, lag, rq: rq) * amp;
	Out.ar(0, sig);
}).add;
);


(
SynthDef(\global_wind_speed, {
	arg freq=4, amp=1, out=0;
	var noise = WhiteNoise.ar(0.2);
	var lag = Lag2.kr(freq*500, 0.5, mul:0.5);
	var filter = RLPF.ar(noise, lag, 0.1, amp).dup;
	Out.ar(out, filter);
}).add;
);

(
SynthDef(\h1, {
	arg pressure=1000, speed=440, out=0, amp=1;
	var lag = Lag.kr(speed, lagTime: 1);
	var trig = Impulse.kr(lag/100);
	var env = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime:0.2, level:0.5), gate: trig, doneAction: 0);
	// var sig = SinGrain.ar(trig, 300/speed, WhiteNoise.kr.range(200,220), mul:env*0.7).dup;
	var sig = SinOsc.ar(pressure, mul:env*0.7*amp);
	var pan = Pan2.ar(sig, pos:-1);
	Out.ar(out, pan);
}).add;
);

(
SynthDef(\h2, {
	arg pressure=1000, speed=440, out=0, amp=1;
	var lag = Lag.kr(speed, lagTime: 1);
	var trig = Impulse.kr(lag/100);
	var env = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime:0.2, level:0.5), gate: trig, doneAction: 0);
	// var sig = SinGrain.ar(trig, 300/speed, WhiteNoise.kr.range(200,220), mul:env*0.7).dup;
	var sig = (Saw.ar(pressure, mul:env*0.7*amp)*SinOsc.ar(pressure*3, mul:env*0.7*amp));
	var pan = Pan2.ar(sig, pos:0);
	Out.ar(out, pan);
}).add;
);

(
SynthDef(\h3, {
	arg pressure=1000, speed=440, out=0, amp=1;
	var lag = Lag.kr(speed, lagTime: 1);
	var trig = Impulse.kr(lag/100);
	var env = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime:0.2, level:0.5), gate: trig, doneAction: 0);
	// var sig = SinGrain.ar(trig, 300/speed, WhiteNoise.kr.range(200,220), mul:env*0.7).dup;
	var sig = (Pulse.ar(pressure/2, width:0.5, mul:env*0.7*amp));
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

/*
~reverb_h1 = Synth(\reverb_h1, [\in, 99, \out, 0]);
~h1 = Synth(\h1, [\pressure, 1000, \speed, 440, \out, 99]);
~h1.set(\speed, 900, \pressure, 400);

~reverb_h3 = Synth(\reverb_h3, [\in, 97, \out, 0]);
~h3 = Synth(\h3, [\pressure, 1000, \speed, 440, \out, 97]);
~h3.set(\speed, 300, \pressure, 200);

~reverb_h2 = Synth(\reverb_h2, [\in, 98, \out, 0]);
~h2 = Synth(\h2, [\pressure, 1000, \speed, 440, \out, 98]);
~h2.set(\speed, 300, \pressure, 200);
*/

(
// ~noise1 = Synth(\noise1, [\freq, 1000]);

// ~sinTone = Synth(\sinTone, [\freq,1000]);

~reverb_h1 = Synth(\reverb_h1, [\in, 99, \out, 0]);
~h1 = Synth(\h1, [\pressure, 1000, \speed, 440, \out, 99]);
~reverb_h3 = Synth(\reverb_h3, [\in, 97, \out, 0]);
~h3 = Synth(\h3, [\pressure, 1000, \speed, 440, \out, 97]);
~reverb_h2 = Synth(\reverb_h2, [\in, 98, \out, 0]);
~h2 = Synth(\h2, [\pressure, 1000, \speed, 440, \out, 98]);

~global_wind_speed = Synth(\global_wind_speed, [\freq, 4, \out, 98]);

OSCFunc({ |args|
	var h1_p, h1_s, h2_p, h2_s, h3_p, h3_s;
	"OSCFUNC received the following values:".postln;
	args[1..].postln;
	// (args[2]-3.5*500).postln;
	// (args[2]).postln;

	// ~sinTone.set(\freq, args[2]);
	h1_p = args[4].linlin(955, 1000, 980, 1000);
	h2_p = args[8].linlin(955, 1000, 980, 1000);
	h3_p = args[12].linlin(955, 1000, 980, 1000);

	h1_s = args[6].linlin(24, 70, 100, 1000);
	h2_s = args[10].linlin(35, 70, 100, 1000);
	h3_s = args[14].linlin(30, 70, 100, 1000);

	~global_wind_speed.set(\freq, args[2]-3.5, \amp, args[2]/2);

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
)

{SinOsc.ar(440, mul:0.5)}.play;

