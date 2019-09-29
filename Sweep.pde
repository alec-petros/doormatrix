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
        speed = random(0.3, 1.5);
    }

    boolean active() {
        return active;
    }

    void iterateSweep() {
        sweepLoc += speed;

        if (active) {
            pushMatrix();
            translate(width / 2, height / 2);
            rotate(rotation);
            float sweepHue = map(noise(noiseX += 0.005), 0, 1, 55, 204);
            for (int i = 0; i < 20; i++) {
                stroke(sweepHue, 255, 255, alpha - 10 * i);
                line(-height, sweepCenter + sweepLoc - i, height, sweepCenter + sweepLoc - i);
            }
            popMatrix();
        }
    }
}