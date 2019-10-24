// Allows us to define a primary and secondary gradient, currently with only two color stops, and an accent
// TODO: Accept an array of colors for our gradients

class ColorPalette {
    SimpleGradient primary, secondary;
    color accent;
    
    ColorPalette(color initPrimaryX, color initPrimaryY, color initSecX, color initSecY, color initAccent) {
        primary = new SimpleGradient(color(initPrimaryX), color(initPrimaryY));
        secondary = new SimpleGradient(initSecX, initSecY);
        accent = initAccent;
    }

    ColorPalette(color initPrimaryX, color initPrimaryY, color initAccent) {
        primary = new SimpleGradient(color(initPrimaryX), color(initPrimaryY));
        secondary = new SimpleGradient(color(0, 0, 0), color(255, 255, 255));
        accent = initAccent;
    }

    ColorPalette(SimpleGradient initPrimary, SimpleGradient initSecondary, color initAccent) {
        primary = initPrimary;
        secondary = initSecondary;
        accent = initAccent;
    }
    
    color getPrimary(float amt) {
        return primary.get(amt);
    }

    color getSecondary(float amt) {
        return secondary.get(amt);
    }
    
    color accent() {
        return accent;
    }
}