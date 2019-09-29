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

    boolean active() {
        return active;
    }

    void draw() {
        location += speed;

        if (location >= 200 || location <= -200) {
            speed *= -1;
        }

        if (active) {
            pushMatrix();
            translate(width / 2, height / 2);
            rotate(radians(45 + 90));
            float sweepHue = map(noise(noiseX += 0.005), 0, 1, 55, 204);
            fill(sweepHue, 255, 255, 255);
            rect(-20 + location, -20 + location, 40, 40);
            popMatrix();
        }
    }
}