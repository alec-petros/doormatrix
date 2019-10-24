class Sparkle {
    PVector velocity, loc;
    Smoother size;
    color c;

    Sparkle(PVector location, PVector speed, color fillColor) {
        loc = location;
        velocity = speed;
        size = new Smoother(15.0, 1);
        c = fillColor;
    }

    void draw(float midAmp) {
        size.update(midAmp);
        loc = PVector.add(loc, velocity);
        noStroke();
        fill(c);
        circle(loc.x, loc.y, map(size.value(), 0, 1, 0, 50));
    }
}