s.meter;

~bus = Bus.audio(s,2);// audio bus
~bus.scope;
~krBus = Bus.control(s, 1);// control bus
~krBus.scope;

~sourceGrp = Group.new();// group of the sound generating synths that
~fxGrp = Group.new(~sourceGrp,\addAfter);//fx group

// control
(
SynthDef(\ctl, {
	var ctl = SinOsc.kr(\speed.kr(1)).range(-1, 1.0);
	Out.kr(~krBus, ctl);
}).play;
)

// Synths
(
SynthDef(\SubSynth, {
	arg freq1 = 100.0, amp = 0.1, release = 5;
	var sig, env, pan = LFNoise1.kr(0.5).range(-1, 1);
	env = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime: release), doneAction: 2);
	sig = SinOsc.ar(freq: freq1, mul: amp);
	sig = sig * env;
	sig = FreeVerb.ar(sig, 0.7, 0.8, 0.25);
	Out.ar(~bus, Pan2.ar(sig, pan));
}).add;
)

(
SynthDef(\noiSynth, {
	arg freq1 = 100.0, amp = 0.1, release = 0.5;
	var sig, env, pan = LFNoise1.kr(0.5).range(-1, 1);
	env = EnvGen.kr(Env.perc(attackTime: 0.001, releaseTime: release), doneAction: 2);
	sig = LFNoise0.ar(freq: freq1, mul: amp);
	sig = sig * env * 0.5;
	Out.ar(~bus, Pan2.ar(sig, pan));
}).add;
)

(
SynthDef.new(\kick,{
	arg freqA=1000, freqB=50, freqC=10, freqDur1=0.01,freqDur2=0.2, freqC1=1, freqC2=(-1), atk=0.01, rel=1, c1=1, c2=(-12), amp=0.8;
	var sig, env, freqSweep, pan=LFNoise1.kr(0.5).range(-1,1);
	freqSweep = Env([freqA, freqB, freqC], [freqDur1, freqDur2], [freqC1, freqC2]).ar;
	env= Env([0, 1, 0], [atk,rel], [c1,c2]).kr(2);
	sig = SinOsc.ar(freqSweep,pi/2);
	sig = sig* env;

	Out.ar(0, Pan2.ar(sig,pan));
}).add;
)

(
SynthDef(\acid, { arg freq = 1000, gate = 1, pan = 1, cut = 4000, rez = 0.8, amp = 1;
    Out.ar(~bus,
        Pan2.ar(
            RLPF.ar(
                Saw.ar(freq, 0.05),
            cut, rez),
        pan) * EnvGen.kr(Env.linen(0.01, 1, 0.3), gate, amp, doneAction: Done.freeSelf);
    )
}).add;
)

(
SynthDef.new(\perc,{
	arg freqA=1000, freqB=50, freqC=10, freqDur1=0.01,freqDur2=0.2, freqC1=1, freqC2=(-1), atk=0.01, rel=1, c1=1, c2=(-12), amp=0.8, pan=0, out=0;
	var sig, env, freqSweep;
	freqSweep = Env([freqA, freqB, freqC], [freqDur1, freqDur2], [freqC1, freqC2]).ar;
	env= Env([1, 1, 0], [atk,rel], [c1,c2]).kr(2);
	sig = LFNoise0.ar(freqSweep,pi/2);
	sig = sig* env;
	sig = Pan2.ar(sig, pan,amp);
	Out.ar(~bus, sig);
}).add;
)



// variations of linDec synth
(
SynthDef.new(\linDec,{
arg freq=50, phase= 100, hop=8,min=100,max=500;
var mod,on,env,sig,pan=LFNoise1.kr(0.5).range(-1,1);
	mod=LFNoise0.kr(hop).exprange(min,max);
	env=EnvGen.kr(Env.linen(attackTime: 10, releaseTime: 25),doneAction: 2);
	sig=SinOsc.ar(mod,SinOsc.ar(XLine.kr(1, phase, 10), 0, 2pi/2)) *0.5;
	on=Pan2.ar(sig, pan, level: 0.5)*env*0.1;
	Out.ar(~bus,on);


	}).add;
)

(
SynthDef.new(\linDec,{
arg freq=50, phase= 100, hop=8,min=100,max=500;
var mod,on,env,sig,pan=LFNoise1.kr(0.5).range(-1,1);
	mod=SinOsc.kr(hop).exprange(min,max);
	env=EnvGen.kr(Env.linen(attackTime: 10, releaseTime: 25),doneAction: 2);


	sig=SinOsc.ar(mod,SinOsc.ar(XLine.kr(1, phase, 10), 0, 2pi/2)) *0.5;
	on=Pan2.ar(sig, pan, level: 0.5)*env*0.1;
	Out.ar(~bus,on);


	}).add;
)

(
SynthDef.new(\linDec,{
arg freq=50, phase= 100, hop=8,min=100,max=500;
var mod,on,env,sig,pan=LFNoise1.kr(0.5).range(-1,1);
	mod=SinOsc.kr(hop).exprange(min,max);
	env=EnvGen.kr(Env.linen(attackTime: 10, releaseTime: 25),doneAction: 2);


	sig=Pulse.ar(mod,SinOsc.ar(XLine.kr(1, phase, 10), 0, 2pi/2)) *0.5;
	on=Pan2.ar(sig, pan, level: 0.5)*env*0.1;
	Out.ar(~bus,on);


	}).add;
)
////////////////////////////////////////


(
SynthDef(\reverb,{
	| in = 0,out =0 , mix =0.5|
	var input , wetSig;
	input = In.ar( in ,2);
	wetSig = FreeVerb.ar(input, mix, 0.8, 0.25);
	Out.ar(out,wetSig);
}
).add;
)

(
~sub = Synth(\SubSynth,[ \out, ~bus],~sourceGrp);
~noiSynth=Synth(\noiSynth,[ \out, ~bus],target: ~sourceGrp);
~modSynth = Synth(\linDec,[\out,~bus],target: ~sourceGrp);

~fx = Synth(\reverb,[\in, ~bus,\mix,~krbus]);
)

(
~linDec = Pbind(
	\instrument,\linDec,
	\dur,Prand([5,10,15,20],inf),
	\freq,Prand([50.0,100.0,150.0,250.0],inf)
).play;
)

(
~subby = Pbind(\instrument,\SubSynth,
	\dur,Prand([0.1,0.25,0.5,1],inf),
	\freq1,Prand([50.0,100.0,150.0,250.0],inf)
).play;

~kick = Pbind(\instrument, \kick,
	\dur, Prand([0.125,0.25,0.5,1],inf),
	\freqA, Prand([50.0,100.0,150.0,250.0],inf),
	\atk, 0.001,
	\rel, 1,
	\amp, 0.8).play;

)
(
~nois = Pbind(\instrument,\noiSynth,
	\dur,Prand([0.1,0.25,0.5,1],inf),
	\freq1,Prand([500.0,1000.0,2500.0,5000.0],inf),
	\release,Pseq([0.5,1,1.5,2],inf)).play;
)
(
~seq = Pbind(\instrument, \acid,
	\dur, Pseq([0.25, 0.5, 0.25], inf),
	\root, -12,
	\degree, Pseq([0, 3, 12, 7, 5, 11, 9, 1], inf),
	\pan, Pfunc({1.0.rand2}),
	\cut, Prand([1000, 500, 2000, 300], inf),
	\rez, Pfunc({0.7.rand +0.3}), \amp, 0.2).play;
)

(
~perc= Pbind(
	\instrument, \perc,
	\dur, 0.125,
	\freqA, Prand([1000,1500,2000,2500,],inf),
	\atk, 0.001,
	\rel, 0.01,
	\amp, 0.02,
	\out, 0
).play
)

~linDec.stop;

~nois.stop;

~seq.stop;

~kick.stop;

~subby.stop;

~perc.stop;


~fx.map(\mix,~krbus);

(
fork {
	loop{
		~fx.set(\mix, Prand([0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1]));
		5.wait;
}
}
)