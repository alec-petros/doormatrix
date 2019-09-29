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
        box = new Box(true, false, 0.2);
    }

    void sweep(float rotation) {
        activeSweeps[sweepIndex] = new Sweep(pulses, true, rotation);
        sweepIndex += 1;
        if (sweepIndex == activeSweeps.length) {
            sweepIndex = 0;
        }
    }

    void draw() {
        for (int i = 0; i < activeSweeps.length; i++) {
            activeSweeps[i].iterateSweep();
        }
        box.draw();
    }
}