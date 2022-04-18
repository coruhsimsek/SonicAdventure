s.reboot;


(
SynthDef.new(\pulSynth,{
	arg ampHz=2, fund=40, maxPartial=6, width=0.01,freq1;
	var amp1, amp2, freq2, sig1, sig2,env;
	amp1 = LFPulse.kr(4, 0, 0.12) * 0.75;
	amp2 = LFPulse.kr(4, 0.5, 0.12) * 0.75;
	env = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime: 2));
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
	sig = SinOsc.ar(freq: freq1, mul: amp);
	sig = sig * env;
	Out.ar(0, Pan2.ar(sig, pan));
}).add;
)






~groupSynth = Group.new();

(
//~noiSynth=Synth(\noiSynth,target: ~groupSynth);


~pulSynth = Synth(\pulSynth,target:~groupSynth);
)
~groupSynth.set(\width, 0.25,\maxPartial, 12 ,\fund, 100,\freq1,30);

~groupSynth.value;

Pbind(\instrument,\noiSynth,\dur,Prand([0.1,0.25,0.5,1],inf),\freq1,Prand([500.0,1000.0,2500.0,5000.0],inf),\release,Pseq([0.5,1,1.5,2],inf)).play;
Pbind(\instrument,\pulSynth,\dur,Prand([0.1,0.25,0.5,1],inf),\freq1,Prand([500.0,1000.0,2500.0,5000.0],inf)).play;

