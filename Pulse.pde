class Pulse {
    int yPosition, alpha;
    PVector noisePos;
    boolean flicker;
    float noiseScale;
    color pulseColor;

    Pulse(int pos, boolean flick) {
        yPosition = pos;
        alpha = 0;
        noisePos = new PVector(random(0, 1000), random(0, 1000));
        flicker = flick;
        noiseScale = 0.005;
        pulseColor = color(255, 0, 255);
    }

    void draw() {
        stroke(150, alpha -= 5);
        line(0, yPosition, width, yPosition);
        noisePos.add(new PVector(noiseScale, noiseScale));
        float noiseX = noise(noisePos.x);
        if (flicker && noise(noisePos.x) > 0.83) {
            this.ping();
        }
        for (int i = 0; i < height / 10; i++) {
            // stroke(map(noise(noisePos.x), 0, 1, 100, 200), map(noise(noisePos.y), 0, 1, 0, 200), map(noise(noisePos.x), 0, 1, 255, 100), alpha - 30 * i);
            stroke(pulseColor, alpha - i * 100000);
            line(0, yPosition + i, width, yPosition + i);
            line(0, yPosition - i, width, yPosition - i);
        }
    }

    void sweepDraw(float sweepHue) {
        stroke(sweepHue, 255, 255, alpha -= 3);
        line(0, yPosition, width, yPosition);
    }

    void ping() {
        alpha = 255;
    }
}
