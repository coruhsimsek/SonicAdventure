~sourceGrp = Group.new();// group of the sound generating synths that
~fxGrp = Group.new(~sourceGrp,\addAfter);//fx group

~bus = Bus.audio(s,2);// audio bus
~bus.scope;
~krBus = Bus.control(s, 1);// control bus
~krBus.scope;

// control
(
SynthDef(\ctl, {
	var ctl = LFNoise1.kr(\speed.kr(1)).range(-1, 1.0);
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
	Out.ar(0, Pan2.ar(sig, pan));
}).add;
)

(
SynthDef(\noiSynth, {
	arg freq1 = 100.0, amp = 0.1, release = 1;
	var sig, env, pan = LFNoise1.kr(0.5).range(-1, 1);
	env = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime: release), doneAction: 2);
	sig = LFNoise0.ar(freq: freq1, mul: amp);
	sig = sig * env * 0.5;
	Out.ar(0, Pan2.ar(sig, pan));
}).add;
)

(
SynthDef.new(\kick,{
	arg freqA=1000, freqB=50, freqC=10, freqDur1=0.01,freqDur2=0.2, freqC1=1, freqC2=(-1), atk=0.01, rel=1, c1=1, c2=(-12), amp=0.8, out=0;
	var sig, env, freqSweep, pan=LFNoise1.kr(0.5).range(-1,1);
	freqSweep = Env([freqA, freqB, freqC], [freqDur1, freqDur2], [freqC1, freqC2]).ar;
	env= Env([0, 1, 0], [atk,rel], [c1,c2]).kr(2);
	sig = SinOsc.ar(freqSweep,pi/2);
	sig = sig* env;

	Out.ar(out, Pan2.ar(sig,pan));
}).add;
)

(
SynthDef.new(\linDec,{
arg freq=50, phase= 100, hop=8,min=100,max=500;
var mod,on,env,sig,pan=LFNoise1.kr(0.5).range(-1,1);
	mod=LFNoise0.kr(hop).exprange(min,max);
	env=EnvGen.kr(Env.linen(attackTime: 10, releaseTime: 25),doneAction: 2);


	sig=Pulse.ar(mod,SinOsc.ar(XLine.kr(1, phase, 10), 0, 2pi/2)) *0.5;
	on=Pan2.ar(sig, pan, level: 0.5)*env*0.1;
	Out.ar(0,on);


	}).add;
)
////////////////////////////////////////


(
SynthDef(\reverb,{
	| in = 0,out =0 , mix =0.5|
	var input , wetSig;
	input = In.ar( in ,2);
	wetSig = FreeVerb.ar(in: input,mix: mix);
	Out.ar(out,wetSig);
}
).add;
)

(
~sub = Synth(\SubSynth,[ \out, ~bus],~sourceGrp);
~noiSynth=Synth(\noiSynth,[ \out, ~bus],target: ~sourceGrp);
~pulSynth = Synth(\pulSynth,[ \out, ~bus],target:~sourceGrp);

~fx = Synth(\reverb,[\in, ~bus],~fxGrp);
)



(
~subby = Pbind(\instrument,\SubSynth,\dur,Prand([0.1,0.25,0.5,1],inf),\freq1,Prand([50.0,100.0,150.0,250.0],inf)).play;

~kick = Pbind(\instrument, \kick,\dur, Prand([0.125,0.25,0.5,1],inf),\freqA, Prand([50.0,100.0,150.0,250.0],inf),\atk, 0.001,\rel, 1,\amp, 0.8).play;
~linDec = Pbind(\instrument,\linDec,\dur,Prand([5,10,15,20],inf),\freq,Prand([50.0,100.0,150.0,250.0],inf)).play;
)
~fxGrp.set(\mix, 1);