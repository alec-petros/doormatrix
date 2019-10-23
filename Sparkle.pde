class Sparkle {
    PVector velocity, loc;
    Smoother size;

    Sparkle(PVector location, PVector speed) {
        loc = location;
        velocity = speed;
        size = new Smoother(15.0, 1);
    }

    void draw(float midAmp) {
        size.update(midAmp);
        loc = PVector.add(loc, velocity);
        noStroke();
        fill(200, 0, 255);
        circle(loc.x, loc.y, map(size.value(), 0, 1, 0, 50));
    }
}