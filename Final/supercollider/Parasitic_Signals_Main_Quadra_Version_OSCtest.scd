/*

Parasitic Signals by Sabina Ann
Sonification Engines created by Twelve-Lab (Kyriakos Charalampides and Michele Abolaffio) for Sabina Ahn in May 2021

This is the code main file. From here you can run the code and change basic parameters

QUADRAPHONIC - VERSION
*/



//Run this fork to get started
(
fork{


//define bark frequencirs and Qs
~barkScale = [50, 150, 250, 350, 450, 570, 700, 840, 1000, 1170, 1370, 1600, 1850, 2150, 2500, 2900, 3400, 4000, 4800, 5800, 7000, 8500, 10500, 13500];
~barkRq = [ 0.8, 0.5, 0.33333333333333, 0.25, 0.2156862745098, 0.19047619047619, 0.18181818181818, 0.16304347826087, 0.14814814814815, 0.1496062992126, 0.14189189189189, 0.13953488372093, 0.14, 0.13793103448276, 0.14074074074074, 0.14285714285714, 0.14864864864865, 0.15909090909091, 0.16981132075472, 0.171875, 0.16883116883117, 0.18947368421053, 0.20833333333333, 0.2258064516129 ]/2;
~barkCoeff = Array.fill(24, {arg i; (1/~barkRq[i])*(1/24.0)});
s.sync;

// bark filter bank with feedback
	Ndef(\barkFeedback, {arg amp = 1, offset = 100, rq = 0.02, pan = 0, feedback = 0, rate = 1, revTime = 0.1, delTime = 0.01, fedAmp = 1;
		//define variables
	var input, bp, coefficients, feedbackDelay, panning;
		//use PinkNoise as
	input = PinkNoise.ar(1);
		//lag the pan
	pan = pan.lag(0.1);
		//lag the fdbk
	feedback = feedback.lag(0.1);
		//lag the delat time
	delTime = delTime.lag(0.1);
		//Actual feedback loop
	feedbackDelay = DelayC.ar(Ndef(\barkFeedback).ar(1),0.2, delTime); //delay line on the feedback
		//Additional Reverbarated fdbk loop (the output part)
	feedbackDelay = feedbackDelay + (AdCVerb.ar(feedbackDelay, revTime, 0.5, 1)*(-10.dbamp));
		//Compres for stabilization
	feedbackDelay = Compander.ar(feedbackDelay, feedbackDelay, 0.7, 1, 0.2, clampTime:0.01, relaxTime: 0.1);
		//Use panning to map the relationship of the barks
	panning = PanAz.ar(~barkScale.size, DC.ar(1), pan*2, width: 1, orientation: 0.5);
		//Apply the mapping
	coefficients = Array.fill(~barkScale.size, {arg i; ~barkCoeff.at(i) * panning.at(i)});
		// Output values
	bp = Mix.fill(~barkScale.size, {arg i;
			//Each bark is a filter
	BPF.ar(input, ~barkScale.at(i), ~barkRq.at(i), coefficients.at(i));});
		// Define output
	bp = bp + (feedbackDelay*feedback*0.6);
		// Amplify output
	bp = bp*1 * fedAmp;
		//Avoid trouble
	Limiter.ar(bp * amp);

}).play(numChannels: 4);
s.sync;

b = Buffer.readChannel(s, thisProcess.nowExecutingPath.dirname++"/Asteroid_Deformation.wav", channels:0, startFrame: 0, numFrames: 44100 );

Ndef(\Phisem, {
	//define arguments
	arg density = 10, pitch = 1, gateEnv = 1, phPitch = 1, amp = 7, phAmp = 1, pitchR = 0, phPan = 0;
	//define variables
    var dur, trig, grain, envelope, out, rev, shifter;
	// lag the Pitch
	pitchR = pitchR.lag(0.6);
	//Define the duration of each grain
    dur = 4 / density; //four times the grain period
	//Pass each grain from a Schidt envelope
	envelope = Schmidt.kr(gateEnv, 0.90, 4.0);
	//Classic ADSR for actual controll
	envelope = EnvGen.ar(Env.adsr(0.04, 0.3, 0.5, 2), envelope);
	// Mapp the parameter from CSV to pitch
	pitch = phPitch;
	// trigger at density
	trig = Dust.ar(density);
	//Granulate
	grain = TGrains.ar(2, trig, b, pitch, TRand.ar(0,BufDur.kr(b), trig), dur, phPan, 0.1, 4);
	//Apmplify
	grain = grain *12.dbamp;
	//Pitch Shift
	shifter = PitchShift.ar(grain, 0.01, pitchR, 0.1);
	//Add reverb
	rev = (shifter *( -5.dbamp) )  + (grain *( -5.dbamp) ) + (AdCVerb.ar(grain, 2, 0.98, 2, 0.1) * (-34.dbamp));
	// Filter the output
	out = HPF.ar( (rev * envelope), 600) ;
	//Output amplification
	out = (out * amp) * phAmp;
	//Avoid trouble
	Limiter.ar(out);
	}).play(numChannels: 2);
s.sync;

	Ndef(\PhisemBack, {
	//define arguments
	arg density = 9, pitch = 0.8, gateEnv = 1, phPitch = 0.6, amp = 7, phAmp = 1, pitchR = 0.3, phPan = 0;
	//define variables
    var dur, trig, grain, envelope, out, rev, shifter, mainout;
	// lag the Pitch
	pitchR = pitchR.lag(0.6);
	//Define the duration of each grain
    dur = 4 / density; //four times the grain period
	//Pass each grain from a Schidt envelope
	envelope = Schmidt.kr(gateEnv, 0.90, 4.0);
	//Classic ADSR for actual controll
	envelope = EnvGen.ar(Env.adsr(0.04, 0.3, 0.5, 2), envelope);
	// Mapp the parameter from CSV to pitch
	pitch = phPitch;
	// trigger at density
	trig = Dust.ar(density);
	//Granulate
	grain = TGrains.ar(2, trig, b, pitch, TRand.ar(0,BufDur.kr(b), trig), dur, phPan, 0.1, 4);
	//Apmplify
	grain = grain *12.dbamp;
	//Pitch Shift
	shifter = PitchShift.ar(grain, 0.01, pitchR, 0.1);
	//Add reverb
	rev = (shifter *( -5.dbamp) )  + (grain *( -5.dbamp) ) + (AdCVerb.ar(grain, 2, 0.98, 2, 0.1) * (-34.dbamp));
	// Filter the output
	out = HPF.ar( (rev * envelope), 600) ;
	//Output amplification
	out = (out * amp) * phAmp;
	//Avoid trouble
	mainout = Limiter.ar(out);
	Out.ar(2, mainout);
	Silent.ar(2);
	}).play(numChannels: 4);
s.sync;



(
c = Buffer.readChannel(s, thisProcess.nowExecutingPath.dirname++"/Raber_Low.wav", channels:0, startFrame: 0, numFrames: -1 );


Ndef(\Rubber, {
	//define arguments
	arg rubdensity = 10, pitch = 1, gateEnv = 1, rubPitch = 1, amp = 18, phAmp = 1, pitchRub = 0, phPan = 0;
	//define variables
    var dur, trig, grain, envelope, out, rev, shifter, mainout;
	// lag the Pitch
	pitchRub = pitchRub.lag(0.6);
	//Define the duration of each grain
    dur = 4 / rubdensity; //four times the grain period
	//Pass each grain from a Schidt envelope
	envelope = Schmidt.kr(gateEnv, 0.90, 4.0);
	//Classic ADSR for actual controll
	envelope = EnvGen.ar(Env.adsr(0.05, 0.3, 0.8, 5), envelope);
	// Mapp the parameter from CSV to pitch
	pitch = rubPitch;
	// trigger at density
	trig = Dust.ar(rubdensity);
	//Granulate
	grain = TGrains.ar(2, trig, c, pitch, TRand.ar(0,BufDur.kr(c), trig), dur, phPan, 0.1, 4);
	//Apmplify
	grain = grain *12.dbamp;
	//Pitch Shift
	shifter = PitchShift.ar(grain, 0.01, pitchRub, 0.1);
	//Add reverb
	rev = (shifter *( -5.dbamp) )  + (grain *( -5.dbamp) ) + (AdCVerb.ar(grain, 2, 0.98, 2, 0.1) * (-34.dbamp));
	// Filter the output
	out = HPF.ar( (rev * envelope), 600) ;
	//Output amplification
	out = (out * amp) * phAmp;
	//Avoid trouble
	Limiter.ar(out);

	}).play(numChannels: 2);
s.sync;



Ndef(\RubberBack, {
	//define arguments
	arg rubdensity = 8, pitch = 1, gateEnv = 1, rubPitch = 0.5, amp = 17, phAmp = 1, pitchRub = 0.7, phPan = 0;
	//define variables
    var dur, trig, grain, envelope, out, rev, shifter, mainout;
	// lag the Pitch
	pitchRub = pitchRub.lag(0.6);
	//Define the duration of each grain
    dur = 4 / rubdensity; //four times the grain period
	//Pass each grain from a Schidt envelope
	envelope = Schmidt.kr(gateEnv, 0.90, 4.0);
	//Classic ADSR for actual controll
	envelope = EnvGen.ar(Env.adsr(0.05, 0.3, 0.8, 5), envelope);
	// Mapp the parameter from CSV to pitch
	pitch = rubPitch;
	// trigger at density
	trig = Dust.ar(rubdensity);
	//Granulate
	grain = TGrains.ar(2, trig, c, pitch, TRand.ar(0,BufDur.kr(c), trig), dur, phPan, 0.1, 4);
	//Apmplify
	grain = grain *12.dbamp;
	//Pitch Shift
	shifter = PitchShift.ar(grain, 0.01, pitchRub, 0.1);
	//Add reverb
	rev = (shifter *( -5.dbamp) )  + (grain *( -5.dbamp) ) + (AdCVerb.ar(grain, 2, 0.98, 2, 0.1) * (-34.dbamp));
	// Filter the output
	out = HPF.ar( (rev * envelope), 600) ;
	//Output amplification
	out = (out * amp) * phAmp;
	//Avoid trouble
	mainout = Limiter.ar(out);
	Out.ar(2, mainout);
	Silent.ar(2);
		}).play(numChannels:4);
s.sync;

6.wait; //dramatic pause

	~playSequence.stop;
	// self contained
	x = CSVFileReader.read(thisProcess.nowExecutingPath.dirname++"/Y_voltage_force.csv");
	x = x.flop;
	s.sync;
	~playSequence = Task({
		var oldValue = 0;
		x.do({
			arg item, i;
			item.do(
				{arg value, i;
					var density, pitch, feedback, pan, revTime, delTime, phPitch, fedAmp, phAmp, pitchR, phPan, rubPitch,rubdensity, pitchRub;
					value = value.asFloat;


//uncommend this to print the value

						// value.postln;

//Mapping and scaling the values linearly
					density = value.linlin(-19, 32, 2, 30);
					pan = value.linlin(-19, 32, 0.1, 0.6);
					feedback = value.linlin(-19, 32, 0.9, 0);
					revTime = value.linlin(-19, 32, 10, 0.1);
					delTime = value.linlin(-19, 32, 0.01, 0.2);
					phPitch = value.linlin(-19, 32, 0.8, 3);
					pitchR = value.linlin(-19, 32, 0, 4);
					phPan = value.linlin(-19, 32, -1, 1);
					fedAmp = value.linlin(-19, 32, 1, 0.95);
					phAmp = value.linlin(-19, 32, 0.2, 1.5);

					rubPitch = value.linlin(-19, 32, 3, 0.1);
					rubdensity = value.linlin(-19, 32, 2, 30);
					pitchRub = value.linlin(-19, 32, 0.1, 3);


//map to Phisem engine
					Ndef(\Phisem).set(\phPitch, phPitch);
					Ndef(\Phisem).set(\density, density);
					Ndef(\Phisem).set(\phAmp, phAmp);
					Ndef(\Phisem).set(\phPan, phPan);
					Ndef(\Phisem).set(\gateEnv, (value-oldValue).abs);
//map to the back Phisem engine
					Ndef(\PhisemBack).set(\phPitch, phPitch);
					Ndef(\PhisemBack).set(\density, density);
					Ndef(\PhisemBack).set(\phAmp, phAmp);
					Ndef(\PhisemBack).set(\phPan, phPan);
					Ndef(\PhisemBack).set(\gateEnv, (value-oldValue).abs);

//map to barkFeedback engine
					Ndef(\barkFeedback).set(\feedback, feedback);
					Ndef(\barkFeedback).set(\pan, pan);
					Ndef(\barkFeedback).set(\revTime, revTime);
					Ndef(\barkFeedback).set(\delTime, delTime);
					Ndef(\barkFeedback).set(\fedAmp, fedAmp);

						//map to rubber engine

					Ndef(\Rubber).set(\rubPitch, rubPitch);
					Ndef(\Rubber).set(\rubdensity, density);
					Ndef(\Rubber).set(\pitchRub, pitchRub);
					Ndef(\Rubber).set(\phAmp, phAmp);
					Ndef(\Rubber).set(\phPan, phPan);
					Ndef(\Rubber).set(\gateEnv, (value-oldValue).abs);


						//map to rubber back  engine

					Ndef(\RubberBack).set(\rubPitch, rubPitch);
					Ndef(\RubberBack).set(\rubdensity, density);
					Ndef(\RubberBack).set(\pitchRub, pitchRub);
					Ndef(\RubberBack).set(\phAmp, phAmp);
					Ndef(\RubberBack).set(\phPan, phPan);
					Ndef(\RubberBack).set(\gateEnv, (value-oldValue).abs);


						// (value-oldValue).abs.postln;
						oldValue = value;

					// reading speed
					0.01.wait;

			})
		});

	});
	s.sync;
		~playSequence.start;

	)
}
)

s.record("/Users/sabina/Music/SuperCollider Recordings/mutations.wav");

s.stopRecording;