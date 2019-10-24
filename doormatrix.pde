OPC opc;
Pulse[] pulses = new Pulse[160];
Cloud cloud;
Controller controller;
Smoother[] fftSmoothers = new Smoother[8];
RingWrapper ringwrapper;

import ddf.minim.analysis.*;
import ddf.minim.*;


int clrCount = 5;
ColorStop[] temp = new ColorStop[clrCount];
float prc;
Gradient grd;
ColorPalette cPalette;

Minim minim;  
AudioInput audioInput;
BeatDetect beat;
FFT fftLin;
FFT fftLog;

float height3;
float height23;
float spectrumScale = 4;
int spectrumDivisor = 5;

PFont font;
float maxValues[];

Sparkler sparkler;


void setup()
{
  size(480, 256);
  height3 = height/3;
  height23 = 2*height/3;

  maxValues = new float[9];

  for (int i = 0; i < clrCount; ++i) {
    prc = i == 0 ? 0 : i == clrCount - 1 ? 1 : random(1);
    temp[i] = new ColorStop(prc,
      composeclr(random(0, 1), random(0, 1), random(0, 1), 1));
    }
  grd = new Gradient(temp);

  cPalette = new ColorPalette(color(#00FCFA), color(#FC00F9), color(#E8FFEA));

  maxValues[0] = 121.5942;
  maxValues[1] = 59.74217;
  maxValues[2] = 30.849203;
  maxValues[3] = 22.770254;
  maxValues[4] = 11.008822;
  maxValues[5] = 6.8135614;
  maxValues[6] = 4.7134547;
  maxValues[7] = 1.7664095;
  maxValues[8] = 0.0000001;

  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  opc = new OPC(this, "fade.local", 7890);
  // opc = new OPC(this, "127.0.0.1", 7890);
  
  // opc.setColorCorrection(2.5, 2, 2, 2);

  opc.ledStrip(320, 64, 3 * (width / 12), 8 * (height/10), width / 200.0, 0, true);
  opc.ledStrip(256, 64, 4 * (width / 12), 5.4 * (height/10), width / 200.0, radians(35),  true);
  opc.ledStrip(192, 64, 5 * (width / 12), 4 * (height/10), width / 200.0, radians(60), true);
  opc.ledStrip(128, 64, 7 * (width / 12), 4 * (height/10), width / 200.0, radians(120),  true);
  opc.ledStrip(64, 64, 8 * (width / 12), 5.4 * (height/10), width / 200.0, radians(145),  true);
  opc.ledStrip(0, 64, 9 * (width / 12), 8 * (height/10), width / 200.0, 0, false);
  
  // opc.ledStrip(384, 64, 3 * (width / 12), 8 * (height/10), width / 200.0, 0, true);
  // opc.ledStrip(320, 64, 4 * (width / 12), 5.4 * (height/10), width / 200.0, radians(35),  true);
  // opc.ledStrip(256, 64, 5 * (width / 12), 4 * (height/10), width / 200.0, radians(60), true);
  // opc.ledStrip(192, 64, 7 * (width / 12), 4 * (height/10), width / 200.0, radians(120),  true);
  // opc.ledStrip(128, 64, 8 * (width / 12), 5.4 * (height/10), width / 200.0, radians(145),  true);
  // opc.ledStrip(64, 64, 9 * (width / 12), 8 * (height/10), width / 200.0, 0, true);
  
  // Make the status LED quiet
  opc.setStatusLed(false);

  for (int i = 0; i < pulses.length; i++) {
      pulses[i] = new Pulse(i, false);
  }

  controller = new Controller(pulses);
  
  colorMode(HSB, 255);
  
  minim = new Minim(this);
  audioInput = minim.getLineIn();
  
  // create an FFT object that has a time-domain buffer the same size as audioInput's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be 1024. 
  // see the online tutorial for more info.
  // fftLin = new FFT( audioInput.bufferSize(), audioInput.sampleRate() );
  
  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  // fftLin.linAverages( 256 );
  
  // create an FFT object for calculating logarithmically spaced averages
  fftLog = new FFT( audioInput.bufferSize(), audioInput.sampleRate() );

  beat = new BeatDetect(audioInput.bufferSize(), audioInput.sampleRate());
  beat.setSensitivity(450);
  
  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages
  fftLog.logAverages( 100, 1 );
  
  cloud = new Cloud(0.0005, fftLin, cPalette);

  sparkler = new Sparkler(cPalette);

  ringwrapper = new RingWrapper();

  for (int i = 0; i < fftLog.avgSize(); i++) {
    fftSmoothers[i] = new Smoother(15.0, maxValues[i]);
  }
}

float noiseIterator = random(0, 1000);

void draw() {
  background(0);

  noiseIterator += 0.5;
  if (noise(noiseIterator) > 0.8) {
    controller.sweep(random(360));
  }

  // controller.draw();

  float centerFrequency = 0;
  
  // perform a forward FFT on the samples in audioInput's mix buffer
  // note that if audioInput were a MONO file, this would be the same as using audioInput.left or audioInput.right
  // fftLin.forward( audioInput.mix );
  fftLog.forward( audioInput.mix );
  beat.detect( audioInput.mix );

  // println(fftLog.getAvg(0));
  for (int i = 0; i < fftLog.avgSize(); i++) {
    fftSmoothers[i].update(fftLog.getAvg(i));
    int yDiff = height / fftLog.avgSize();
    int yTop = yDiff * i;
    int yBot = yDiff * (i + 1);
  }

  // draw bass
  fftSmoothers[0].update(fftLog.getAvg(0));
  float bassAmp = fftSmoothers[0].normalValue();
  cloud.draw(bassAmp);


  // draw mids
  fftSmoothers[3].update(fftLog.getAvg(3));
  float midAmp = fftSmoothers[3].normalValue();
  sparkler.draw(midAmp);

  // don't delete this, it's useful until i write a better solution
  // println(fftSmoothers[0].maxVal(), fftSmoothers[1].maxVal(), fftSmoothers[2].maxVal(), fftSmoothers[3].maxVal(), fftSmoothers[4].maxVal(), fftSmoothers[5].maxVal(), fftSmoothers[6].maxVal(), fftSmoothers[7].maxVal());

  if (beat.isKick()) {
    ringwrapper.newRing(bassAmp);
  }
  ringwrapper.draw();
}
