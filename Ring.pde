class Ring {
    int time;
    float amp;

    Ring(float bassAmp) {
        time = 0;
        amp = bassAmp;
    }

    void draw() {
        if (amp > 0.3) {
            noFill();
            stroke(color(255, 0, (time / 2) - 50));
            strokeWeight(70);
            circle(width / 2, 8 * (height/10), time += 10);
        }
    }
}