class RingWrapper {
    Ring[] rings = new Ring[10];
    int ringIndex;

    RingWrapper() {
        for (int i = 0; i < rings.length; i++) {
            rings[i] = new Ring(0.0);
        }
        ringIndex = 0;
    }

    void draw() {
        for (int i = 0; i < rings.length; i++) {
            rings[i].draw();
        }
    }

    void newRing(float bassAmp) {
        rings[ringIndex] = new Ring(bassAmp);
        ringIndex++;
        if (ringIndex >= rings.length) {
            ringIndex = 0;
        }
    }
}