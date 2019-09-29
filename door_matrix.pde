OPC opc;
Pulse[] pulses = new Pulse[160];
Cloud cloud;
Controller controller;

void setup()
{
  size(80, 140);

  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  opc = new OPC(this, "fade.local", 7890);
  
  opc.setColorCorrection(2.5, 2, 2, 2);

  boolean rev = false;
  //for(int i=0; i<8; i++) {
  //  opc.ledStrip(i * 32, 32, i * width / 8.0 + width / 16.0,
  //  height * 0.5, height / 32.0, PI * 1.5, rev);
  //  rev = !rev;
  //}
  
  for (int i = 1; i < 8; i++) {
    opc.ledStrip(((i - 1) * 64), 64, width/2, i * (height/8), width / 70.0, 0, false);
  }
  
  // Make the status LED quiet
  opc.setStatusLed(false);

  for (int i = 0; i < pulses.length; i++) {
      pulses[i] = new Pulse(i, false);
  }

  controller = new Controller(pulses);
  cloud = new Cloud(0.005);
  
  colorMode(HSB, 255);
}

float noiseIterator = random(0, 1000);

void draw() {
  background(0);

  noiseIterator += 0.5;
  if (noise(noiseIterator) > 0.8) {
    controller.sweep(random(360));
  }

  cloud.draw();

  controller.draw();

}
