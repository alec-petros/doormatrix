// Allows us to define a primary and secondary gradient, currently with only two color stops, and an accent
// TODO: Accept an array of colors for our gradients

class ColorPalette {
    SimpleGradient primary, secondary, accent;
    color accent;
    
    ColorPalette(color initPrimaryX, color initPrimaryY, color initSecX, color initSecY, color initAccent) {
        primary = new SimpleGradient(initPrimaryX, initPrimaryY);
        secondary = new SimpleGradient(initSecondaryX, initSecondaryY);
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