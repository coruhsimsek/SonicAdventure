s.reboot;
s.meter;
s.scope;

~bus = Bus.audio(s, 1);// audio bus
~krBus = Bus.control(s, 1);// control bus
~krBus.scope

SynthDef(\fx,{
	|
}

(
SynthDef(\ctl, {
	var ctl = LFNoise1.kr(\speed.kr(1)).range(-1, 1.0);
	Out.kr(~krBus, ctl);
}).play;
)


(
SynthDef.new(\pulSynth,{
	arg ampHz=2, fund=40, maxPartial=6, width=0.01,freq1;
	var amp1, amp2, freq2, sig1, sig2,env;
	amp1 = LFPulse.kr(4, 0, 0.12) * 0.75;
	amp2 = LFPulse.kr(4, 0.5, 0.12) * 0.75;
	env = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime: 2),doneAction: 2);
	freq1 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8, add:1);
	freq2 = freq2 * LFPulse.kr(6, add:1);
	sig1 = Pulse.ar(freq1, width, amp1)*env;
	sig2 = Pulse.ar(freq2, width, amp2)*env;
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
	Out.ar(0, sig1);
	Out.ar(1, sig2);
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
SynthDef(\SubSynth,~subSynth = {
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
	env=EnvGen.kr(Env.linen(attackTime: 10, releaseTime: 25),doneAction: 0);


	sig=Pulse.ar(mod,SinOsc.ar(XLine.kr(1, phase, 10), 0, 2pi/2)) *0.5;
	on=Pan2.ar(sig, pan, level: 0.5)*env*0.1;
	Out.ar(0,on);


	}).add;
)



~groupSynth = Group.new();

(
~noiSynth=Synth(\noiSynth,target: ~groupSynth);


~pulSynth = Synth(\pulSynth,target:~groupSynth);

~pulSynth = Synth(\SubSynth,target:~groupSynth);



)
~groupSynth.set(\width, 0.25,\maxPartial, 12 ,\fund, 100,\freq1,30);

~decSynth = Synth(\linDec);
~decSynth.set(\width, 0.1,\hop, 6,\fund, 100,\freq1,30)

~nois = Pbind(\instrument,\noiSynth,\dur,Prand([0.1,0.25,0.5,1],inf),\freq1,Prand([500.0,1000.0,2500.0,5000.0],inf),\release,Pseq([0.5,1,1.5,2],inf)).play;
~pulse = Pbind(\instrument,\pulSynth,\dur,Prand([0.1,0.25,0.5,1],inf),\freq1,Prand([50.0,100.0,250.0,500.0],inf)).play;

(
~sub = Pbind(\instrument,\SubSynth,\dur,Prand([0.1,0.25,0.5,1],inf),\freq1,Prand([50.0,100.0,150.0,250.0],inf)).play;

~kick = Pbind(\instrument, \kick,\dur, Prand([0.125,0.25,0.5,1],inf),\freqA, Prand([50.0,100.0,150.0,250.0],inf),\atk, 0.001,\rel, 1,\amp, 0.8).play;
~linDec = Pbind(\instrument,\linDec,\dur,Prand([5,10,15,20],inf),\freq,Prand([50.0,100.0,150.0,250.0],inf)).play;
)

~pulse.stop;
~sub.stop;
~kick.stop;
~nois.stop;
~linDec.stop;



Synth(\linDec).map(2,~krbus);
Synth(\kick).map(