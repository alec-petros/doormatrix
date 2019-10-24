class Sparkler {
    Sparkle[] sparkles = new Sparkle[30];
    int index;
    ColorPalette cPalette;

    Sparkler(ColorPalette palette) {
        index = 0;
        cPalette = palette;
        for (int i = 0; i < sparkles.length; i++) {
            sparkles[i] = new Sparkle(new PVector(width / 2, height / 2), new PVector(3, 3), cPalette.accent());
        }
    }

    void draw(float midAmp) {
        if (midAmp > 0.5) {
            float sparkleX = random(width / 4, (width / 4) * 3);
            float sparkleY = random(height / 4, (height / 4) * 3);
            sparkles[index] = new Sparkle(new PVector(sparkleX, sparkleY), new PVector(random(-1, 1), random(-1, 1)), cPalette.accent());
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