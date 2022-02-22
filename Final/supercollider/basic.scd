
ServerOptions.devices; // all devices
ServerOptions.inDevices; // input devices
ServerOptions.outDevices; // output devices
Server.default.options.inDevice_("UMC404HD 192k");
Server.default.options.outDevice_("UMC404HD 192kt");
"open -a 'Audio MIDI Setup'".unixCmd;

(
s.boot;
Server.default.options.device_("UMC404HD 192k");
s.options.sampleRate = 44100;
s.recChannels=4;
s.options.numOutputBusChannels=4;
s.options.numInputBusChannels=0;

)

b = NetAddr.new("192.168.1.115", 9010);    // create the NetAddr
b.sendMsg("/hello", "there");




s.meter;
s.scope;
s.plotTree;
s.makeWindow;
s.freqscope;

s.quit;

(
{
	var sig;
	sig = PinkNoise.ar(1);
	Out.ar(3, sig);
}.play;
)




~marble = Buffer.read(s, "/Users/sabina/Desktop/Parasitic Signals/Documentation/Parasitic_Signals_SC_testing/1.SR_Small_Landslide-cut.wav")

(
{
	var sig;
	sig = PlayBuf.ar(1, ~marble, loop:1); //stero file ->2
	Out.ar(2, sig);//speaker ch 0~3
}.play;
)

(
{
	var sig, env, panSpeed;
	env = EnvGen.kr(Env.new([0,1,0],[10,10],[1,-1]),doneAction:2);
	panSpeed = EnvGen.kr(Env.new([0,001, 1.25, 0.001], [10,10],[1,1]));
	sig = PlayBuf.ar(1, ~marble, loop:1); //mono file->1
	sig = PanAz.ar(4,sig, LFSaw.kr(panSpeed), 1,2,0.5); //4 speakers, last 1(oct) -> 0.5(quad)
	sig = sig *env;
	Out.ar(0,sig);//from ch 0
}.play
)


s.makeGui;










).play;