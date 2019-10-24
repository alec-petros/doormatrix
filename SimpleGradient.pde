// Allows us to define a primary and secondary gradient, currently with only two color stops, and an accent
// TODO: Accept an array of colors for our gradients

class SimpleGradient {
    color x, y;
    
    ColorPalette(color initX, color initY) {
        x = initX;
        y = initY;
    }
    
    void setX(color newX) {
        x = newX;
    }

    void setY(color newY) {
        y = newY;
    }

    color get() {
        this(0.0);
    }
    
    color get(float amt) {
        return lerpColor(x, y, amt);
    }
}