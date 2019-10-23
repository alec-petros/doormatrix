import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.analysis.*; 
import ddf.minim.*; 
import java.net.*; 
import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class doormatrix extends PApplet {

OPC opc;
Pulse[] pulses = new Pulse[160];
Cloud cloud;
Controller controller;
Smoother[] fftSmoothers = new Smoother[8];
RingWrapper ringwrapper;




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


public void setup()
{
  
  height3 = height/3;
  height23 = 2*height/3;

  maxValues = new float[9];

  // maxValues[0] = 53.05477;
  // maxValues[1] = 20.453335;
  // maxValues[2] = 15.642995;
  // maxValues[3] = 8.958029;
  // maxValues[4] = 7.492257;
  // maxValues[5] = 1.5066102;
  // maxValues[6] = 0.48962182;
  // maxValues[7] = 0.21129508;
  // maxValues[8] = 0.039143644;

  maxValues[0] = 121.5942f;
  maxValues[1] = 59.74217f;
  maxValues[2] = 30.849203f;
  maxValues[3] = 22.770254f;
  maxValues[4] = 11.008822f;
  maxValues[5] = 6.8135614f;
  maxValues[6] = 4.7134547f;
  maxValues[7] = 1.7664095f;
  maxValues[8] = 0.0000001f;

  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  opc = new OPC(this, "fade.local", 7890);
    // opc = new OPC(this, "127.0.0.1", 7890);
   //opc = new OPC(this, "192.168.1.7", 7890);
  
  // opc.setColorCorrection(2.5, 2, 2, 2);

  opc.ledStrip(320, 64, 3 * (width / 12), 8 * (height/10), width / 200.0f, 0, true);
  opc.ledStrip(256, 64, 4 * (width / 12), 5.4f * (height/10), width / 200.0f, radians(35),  true);
  opc.ledStrip(192, 64, 5 * (width / 12), 4 * (height/10), width / 200.0f, radians(60), true);
  opc.ledStrip(128, 64, 7 * (width / 12), 4 * (height/10), width / 200.0f, radians(120),  true);
  opc.ledStrip(64, 64, 8 * (width / 12), 5.4f * (height/10), width / 200.0f, radians(145),  true);
  opc.ledStrip(0, 64, 9 * (width / 12), 8 * (height/10), width / 200.0f, 0, false);
  
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
  
  cloud = new Cloud(0.0005f, fftLin);

  sparkler = new Sparkler();

  ringwrapper = new RingWrapper();

  for (int i = 0; i < fftLog.avgSize(); i++) {
    fftSmoothers[i] = new Smoother(15.0f, maxValues[i]);
  }
}

float noiseIterator = random(0, 1000);

public void draw() {
  background(0);

  noiseIterator += 0.5f;
  if (noise(noiseIterator) > 0.8f) {
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

    // fill(0, map(fftSmoothers[i].value(), 0, 10, 0, 255), 255);
    // rect(0, yTop, width, yDiff);
  }

  // draw bass
  fftSmoothers[0].update(fftLog.getAvg(0));
  float bassAmp = fftSmoothers[0].normalValue();
  // fill(map(bassAmp, 0, 1, 0, 255), map(bassAmp, 0, 1, 0, 255), 0);
  // rect(0, 0, width, height);

  cloud.draw(bassAmp);


  // draw mids
  fftSmoothers[3].update(fftLog.getAvg(3));
  float midAmp = fftSmoothers[3].normalValue();
  // fill(255, 0, 255);
  // rect(0, 0, width, map(midAmp, 0, 1, 0, height));
  sparkler.draw(midAmp);

  // println(fftSmoothers[0].maxVal(), fftSmoothers[1].maxVal(), fftSmoothers[2].maxVal(), fftSmoothers[3].maxVal(), fftSmoothers[4].maxVal(), fftSmoothers[5].maxVal(), fftSmoothers[6].maxVal(), fftSmoothers[7].maxVal());
  if (beat.isKick()) {
    // fill(255, 0, 255);
    ringwrapper.newRing(bassAmp);
    // rect(0, 0, width, height);
  }
  ringwrapper.draw();
}
// class DiscoNonsense {
//   float noiseTrigger

//   DiscoNonsense() {
//       noiseTrigger = random(0, 1000);
//   }

//   void draw() {

//   }
  
// }
class Box {
    boolean active, reverse;
    float location, noiseX, speed;

    Box(boolean isActive, boolean isReverse, float boxSpeed) {
        active = isActive;
        reverse = isReverse;
        location = -180;
        speed = boxSpeed;
        noiseX = random(0, 1000);
    }

    public boolean active() {
        return active;
    }

    public void draw() {
        location += speed;

        if (location >= 200 || location <= -200) {
            speed *= -1;
        }

        if (active) {
            pushMatrix();
            translate(width / 2, height / 2);
            rotate(radians(45 + 90));
            float sweepHue = map(noise(noiseX += 0.005f), 0, 1, 55, 204);
            fill(sweepHue, 255, 255, 255);
            rect(-20 + location, -20 + location, 40, 40);
            popMatrix();
        }
    }
}
class Cloud {
    float noiseTrigger;
    float noiseSpeed;

    Cloud(float speed, FFT fftLin) {
        noiseSpeed = speed;
        noiseTrigger = random(0, 1000);
    }

    public void draw(float normalAmp) {
        noiseTrigger += noiseSpeed + map(normalAmp, 0, 1, 0, 0.1f); 

        float z = noiseTrigger;

        loadPixels();
        float xoff = 0;
        for (int x = 0; x < width; x++) {
            float yoff = 0;
            for (int y = height - 1; y >= 0; y--) {

                float noiseOne = noise(xoff, yoff, z);
                float noiseTwo = noise(xoff, yoff, z + 10000);

                int c = color(
                    map(noiseOne, 0, 1, 80, 300),
                    map(noiseTwo, 0, 1, 0, 255),
                    map(normalAmp, 0, 1, 0, 360)
                );
            
                pixels[x + width*y] = c;
                yoff += 0.01f;
            }
            xoff += 0.01f;
        }
        updatePixels();
    }
}
class Controller {
    Pulse[] pulses;
    Sweep[] activeSweeps;
    Box box;
    int sweepLoc = 0;
    int sweepCenter = height / 2;
    int sweepIndex = 0;

    Controller(Pulse[] pulseArr) {
        pulses = pulseArr;
        activeSweeps = new Sweep[10];
        for (int i = 0; i < activeSweeps.length; i++) {
            activeSweeps[i] = new Sweep(pulses, false, 0);
        }
        println("initialized");
        box = new Box(true, false, 0.2f);
    }

    public void sweep(float rotation) {
        activeSweeps[sweepIndex] = new Sweep(pulses, true, rotation);
        sweepIndex += 1;
        if (sweepIndex == activeSweeps.length) {
            sweepIndex = 0;
        }
    }

    public void draw() {
        for (int i = 0; i < activeSweeps.length; i++) {
            activeSweeps[i].iterateSweep();
        }
        box.draw();
    }
}
/*
 * Simple Open Pixel Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013
 * This file is released into the public domain.
 */




public class OPC implements Runnable
{
  Thread thread;
  Socket socket;
  OutputStream output, pending;
  String host;
  int port;

  int[] pixelLocations;
  byte[] packetData;
  byte firmwareConfig;
  String colorCorrection;
  boolean enableShowLocations;

  OPC(PApplet parent, String host, int port)
  {
    this.host = host;
    this.port = port;
    thread = new Thread(this);
    thread.start();
    this.enableShowLocations = true;
    parent.registerMethod("draw", this);
  }

  // Set the location of a single LED
  public void led(int index, int x, int y)  
  {
    // For convenience, automatically grow the pixelLocations array. We do want this to be an array,
    // instead of a HashMap, to keep draw() as fast as it can be.
    if (pixelLocations == null) {
      pixelLocations = new int[index + 1];
    } else if (index >= pixelLocations.length) {
      pixelLocations = Arrays.copyOf(pixelLocations, index + 1);
    }

    pixelLocations[index] = x + width * y;
  }
  
  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  public void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i),
        (int)(x + (i - (count-1)/2.0f) * spacing * c + 0.5f),
        (int)(y + (i - (count-1)/2.0f) * spacing * s + 0.5f));
    }
  }

  // Set the locations of a ring of LEDs. The center of the ring is at (x, y),
  // with "radius" pixels between the center and each LED. The first LED is at
  // the indicated angle, in radians, measured clockwise from +X.
  public void ledRing(int index, int count, float x, float y, float radius, float angle)
  {
    for (int i = 0; i < count; i++) {
      float a = angle + i * 2 * PI / count;
      led(index + i, (int)(x - radius * cos(a) + 0.5f),
        (int)(y - radius * sin(a) + 0.5f));
    }
  }

  // Set the location of several LEDs arranged in a grid. The first strip is
  // at 'angle', measured in radians clockwise from +X.
  // (x,y) is the center of the grid.
  public void ledGrid(int index, int stripLength, int numStrips, float x, float y,
               float ledSpacing, float stripSpacing, float angle, boolean zigzag,
               boolean flip)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(index + stripLength * i, stripLength,
        x + (i - (numStrips-1)/2.0f) * stripSpacing * c,
        y + (i - (numStrips-1)/2.0f) * stripSpacing * s, ledSpacing,
        angle, zigzag && ((i % 2) == 1) != flip);
    }
  }

  // Set the location of 64 LEDs arranged in a uniform 8x8 grid.
  // (x,y) is the center of the grid.
  public void ledGrid8x8(int index, float x, float y, float spacing, float angle, boolean zigzag,
                  boolean flip)
  {
    ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag, flip);
  }

  // Should the pixel sampling locations be visible? This helps with debugging.
  // Showing locations is enabled by default. You might need to disable it if our drawing
  // is interfering with your processing sketch, or if you'd simply like the screen to be
  // less cluttered.
  public void showLocations(boolean enabled)
  {
    enableShowLocations = enabled;
  }
  
  // Enable or disable dithering. Dithering avoids the "stair-stepping" artifact and increases color
  // resolution by quickly jittering between adjacent 8-bit brightness levels about 400 times a second.
  // Dithering is on by default.
  public void setDithering(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x01;
    else
      firmwareConfig |= 0x01;
    sendFirmwareConfigPacket();
  }

  // Enable or disable frame interpolation. Interpolation automatically blends between consecutive frames
  // in hardware, and it does so with 16-bit per channel resolution. Combined with dithering, this helps make
  // fades very smooth. Interpolation is on by default.
  public void setInterpolation(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x02;
    else
      firmwareConfig |= 0x02;
    sendFirmwareConfigPacket();
  }

  // Put the Fadecandy onboard LED under automatic control. It blinks any time the firmware processes a packet.
  // This is the default configuration for the LED.
  public void statusLedAuto()
  {
    firmwareConfig &= 0x0C;
    sendFirmwareConfigPacket();
  }    

  // Manually turn the Fadecandy onboard LED on or off. This disables automatic LED control.
  public void setStatusLed(boolean on)
  {
    firmwareConfig |= 0x04;   // Manual LED control
    if (on)
      firmwareConfig |= 0x08;
    else
      firmwareConfig &= ~0x08;
    sendFirmwareConfigPacket();
  } 

  // Set the color correction parameters
  public void setColorCorrection(float gamma, float red, float green, float blue)
  {
    colorCorrection = "{ \"gamma\": " + gamma + ", \"whitepoint\": [" + red + "," + green + "," + blue + "]}";
    sendColorCorrectionPacket();
  }
  
  // Set custom color correction parameters from a string
  public void setColorCorrection(String s)
  {
    colorCorrection = s;
    sendColorCorrectionPacket();
  }

  // Send a packet with the current firmware configuration settings
  public void sendFirmwareConfigPacket()
  {
    if (pending == null) {
      // We'll do this when we reconnect
      return;
    }
 
    byte[] packet = new byte[9];
    packet[0] = (byte)0x00; // Channel (reserved)
    packet[1] = (byte)0xFF; // Command (System Exclusive)
    packet[2] = (byte)0x00; // Length high byte
    packet[3] = (byte)0x05; // Length low byte
    packet[4] = (byte)0x00; // System ID high byte
    packet[5] = (byte)0x01; // System ID low byte
    packet[6] = (byte)0x00; // Command ID high byte
    packet[7] = (byte)0x02; // Command ID low byte
    packet[8] = (byte)firmwareConfig;

    try {
      pending.write(packet);
    } catch (Exception e) {
      dispose();
    }
  }

  // Send a packet with the current color correction settings
  public void sendColorCorrectionPacket()
  {
    if (colorCorrection == null) {
      // No color correction defined
      return;
    }
    if (pending == null) {
      // We'll do this when we reconnect
      return;
    }

    byte[] content = colorCorrection.getBytes();
    int packetLen = content.length + 4;
    byte[] header = new byte[8];
    header[0] = (byte)0x00;               // Channel (reserved)
    header[1] = (byte)0xFF;               // Command (System Exclusive)
    header[2] = (byte)(packetLen >> 8);   // Length high byte
    header[3] = (byte)(packetLen & 0xFF); // Length low byte
    header[4] = (byte)0x00;               // System ID high byte
    header[5] = (byte)0x01;               // System ID low byte
    header[6] = (byte)0x00;               // Command ID high byte
    header[7] = (byte)0x01;               // Command ID low byte

    try {
      pending.write(header);
      pending.write(content);
    } catch (Exception e) {
      dispose();
    }
  }

  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  public void draw()
  {
    if (pixelLocations == null) {
      // No pixels defined yet
      return;
    }
    if (output == null) {
      return;
    }

    int numPixels = pixelLocations.length;
    int ledAddress = 4;

    setPixelCount(numPixels);
    loadPixels();

    for (int i = 0; i < numPixels; i++) {
      int pixelLocation = pixelLocations[i];
      int pixel = pixels[pixelLocation];

      packetData[ledAddress] = (byte)(pixel >> 16);
      packetData[ledAddress + 1] = (byte)(pixel >> 8);
      packetData[ledAddress + 2] = (byte)pixel;
      ledAddress += 3;

      if (enableShowLocations) {
        pixels[pixelLocation] = 0xFFFFFF ^ pixel;
      }
    }

    writePixels();

    if (enableShowLocations) {
      updatePixels();
    }
  }
  
  // Change the number of pixels in our output packet.
  // This is normally not needed; the output packet is automatically sized
  // by draw() and by setPixel().
  public void setPixelCount(int numPixels)
  {
    int numBytes = 3 * numPixels;
    int packetLen = 4 + numBytes;
    if (packetData == null || packetData.length != packetLen) {
      // Set up our packet buffer
      packetData = new byte[packetLen];
      packetData[0] = (byte)0x00;              // Channel
      packetData[1] = (byte)0x00;              // Command (Set pixel colors)
      packetData[2] = (byte)(numBytes >> 8);   // Length high byte
      packetData[3] = (byte)(numBytes & 0xFF); // Length low byte
    }
  }
  
  // Directly manipulate a pixel in the output buffer. This isn't needed
  // for pixels that are mapped to the screen.
  public void setPixel(int number, int c)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      setPixelCount(number + 1);
    }

    packetData[offset] = (byte) (c >> 16);
    packetData[offset + 1] = (byte) (c >> 8);
    packetData[offset + 2] = (byte) c;
  }
  
  // Read a pixel from the output buffer. If the pixel was mapped to the display,
  // this returns the value we captured on the previous frame.
  public int getPixel(int number)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      return 0;
    }
    return (packetData[offset] << 16) | (packetData[offset + 1] << 8) | packetData[offset + 2];
  }

  // Transmit our current buffer of pixel values to the OPC server. This is handled
  // automatically in draw() if any pixels are mapped to the screen, but if you haven't
  // mapped any pixels to the screen you'll want to call this directly.
  public void writePixels()
  {
    if (packetData == null || packetData.length == 0) {
      // No pixel buffer
      return;
    }
    if (output == null) {
      return;
    }

    try {
      output.write(packetData);
    } catch (Exception e) {
      dispose();
    }
  }

  public void dispose()
  {
    // Destroy the socket. Called internally when we've disconnected.
    // (Thread continues to run)
    if (output != null) {
      println("Disconnected from OPC server");
    }
    socket = null;
    output = pending = null;
  }

  public void run()
  {
    // Thread tests server connection periodically, attempts reconnection.
    // Important for OPC arrays; faster startup, client continues
    // to run smoothly when mobile servers go in and out of range.
    for(;;) {

      if(output == null) { // No OPC connection?
        try {              // Make one!
          socket = new Socket(host, port);
          socket.setTcpNoDelay(true);
          pending = socket.getOutputStream(); // Avoid race condition...
          println("Connected to OPC server");
          sendColorCorrectionPacket();        // These write to 'pending'
          sendFirmwareConfigPacket();         // rather than 'output' before
          output = pending;                   // rest of code given access.
          // pending not set null, more config packets are OK!
        } catch (ConnectException e) {
          dispose();
        } catch (IOException e) {
          dispose();
        }
      }

      // Pause thread to avoid massive CPU load
      try {
        Thread.sleep(500);
      }
      catch(InterruptedException e) {
      }
    }
  }
}
class Pulse {
    int yPosition, alpha;
    PVector noisePos;
    boolean flicker;
    float noiseScale;
    int pulseColor;

    Pulse(int pos, boolean flick) {
        yPosition = pos;
        alpha = 0;
        noisePos = new PVector(random(0, 1000), random(0, 1000));
        flicker = flick;
        noiseScale = 0.005f;
        pulseColor = color(255, 0, 255);
    }

    public void draw() {
        stroke(150, alpha -= 5);
        line(0, yPosition, width, yPosition);
        noisePos.add(new PVector(noiseScale, noiseScale));
        float noiseX = noise(noisePos.x);
        if (flicker && noise(noisePos.x) > 0.83f) {
            this.ping();
        }
        for (int i = 0; i < height / 10; i++) {
            // stroke(map(noise(noisePos.x), 0, 1, 100, 200), map(noise(noisePos.y), 0, 1, 0, 200), map(noise(noisePos.x), 0, 1, 255, 100), alpha - 30 * i);
            stroke(pulseColor, alpha - i * 100000);
            line(0, yPosition + i, width, yPosition + i);
            line(0, yPosition - i, width, yPosition - i);
        }
    }

    public void sweepDraw(float sweepHue) {
        stroke(sweepHue, 255, 255, alpha -= 3);
        line(0, yPosition, width, yPosition);
    }

    public void ping() {
        alpha = 255;
    }
}
class Ring {
    int time;
    float amp;

    Ring(float bassAmp) {
        time = 0;
        amp = bassAmp;
    }

    public void draw() {
        if (amp > 0.3f) {
            noFill();
            stroke(color(255, 0, (time / 2) - 50));
            strokeWeight(70);
            circle(width / 2, 8 * (height/10), time += 10);
        }
    }
}
class RingWrapper {
    Ring[] rings = new Ring[10];
    int ringIndex;

    RingWrapper() {
        for (int i = 0; i < rings.length; i++) {
            rings[i] = new Ring(0.0f);
        }
        ringIndex = 0;
    }

    public void draw() {
        for (int i = 0; i < rings.length; i++) {
            rings[i].draw();
        }
    }

    public void newRing(float bassAmp) {
        rings[ringIndex] = new Ring(bassAmp);
        ringIndex++;
        if (ringIndex >= rings.length) {
            ringIndex = 0;
        }
    }
}
class Smoother {
    float smoothValue, smoothRate, maxVal;

    Smoother(float rate, float maxAmp) {
        smoothValue = 0.0f;
        smoothRate = rate;
        maxVal = maxAmp;
    }

    public void update(float newValue) {
        if (newValue > smoothValue) {
            smoothValue = newValue;
        } else {
            smoothValue = ((smoothValue * smoothRate) + newValue) / (smoothRate + 1);
        }
        // if (newValue > maxVal) {
        //     maxVal = newValue;
        // }
    }

    public float value() {
        return smoothValue;
    }

    public float normalValue() {
        return map(smoothValue, 0, maxVal, 0, 1);
    }

    public float maxVal() {
        return maxVal;
    }
}
class Sparkle {
    PVector velocity, loc;
    Smoother size;

    Sparkle(PVector location, PVector speed) {
        loc = location;
        velocity = speed;
        size = new Smoother(15.0f, 1);
    }

    public void draw(float midAmp) {
        size.update(midAmp);
        loc = PVector.add(loc, velocity);
        noStroke();
        fill(200, 0, 255);
        circle(loc.x, loc.y, map(size.value(), 0, 1, 0, 50));
    }
}
class Sparkler {
    Sparkle[] sparkles = new Sparkle[30];
    int index;

    Sparkler() {
        index = 0;
        for (int i = 0; i < sparkles.length; i++) {
            sparkles[i] = new Sparkle(new PVector(width / 2, height / 2), new PVector(3, 3));
        }
    }

    public void draw(float midAmp) {
        if (midAmp > 0.5f) {
            float sparkleX = random(width / 4, (width / 4) * 3);
            float sparkleY = random(height / 4, (height / 4) * 3);
            sparkles[index] = new Sparkle(new PVector(sparkleX, sparkleY), new PVector(random(-1, 1), random(-1, 1)));
            index++;
        }
        for (int i = 0; i < sparkles.length; i++) {
            sparkles[i].draw(midAmp);
        }

        if (index >= sparkles.length) {
            index = 0;
        }
    }
}
class Sweep {
    Pulse[] pulses;
    boolean active;
    float sweepCenter, sweepLoc, noiseX, alpha, rotation, speed;

    Sweep(Pulse[] pulseArr, boolean isActive, float degrees) {
        pulses = pulseArr;
        active = isActive;
        sweepCenter = -100;
        sweepLoc = 0;
        noiseX = random(0, 100);
        alpha = 255;
        rotation = radians(degrees);
        speed = random(0.3f, 1.5f);
    }

    public boolean active() {
        return active;
    }

    public void iterateSweep() {
        sweepLoc += speed;

        if (active) {
            pushMatrix();
            translate(width / 2, height / 2);
            rotate(rotation);
            float sweepHue = map(noise(noiseX += 0.005f), 0, 1, 55, 204);
            for (int i = 0; i < 20; i++) {
                stroke(sweepHue, 255, 255, alpha - 10 * i);
                line(-height, sweepCenter + sweepLoc - i, height, sweepCenter + sweepLoc - i);
            }
            popMatrix();
        }
    }
}
  public void settings() {  size(480, 256); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "doormatrix" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
