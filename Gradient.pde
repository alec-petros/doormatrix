// see @behrealjj's fantastic Medium article from which I ripped this
// https://medium.com/@behreajj/color-gradients-in-processing-v-2-0-e5c0b87cdfd2

class Gradient {
  static final int DEFAULT_COLOR_MODE = RGB;
  ArrayList<ColorStop> colorStops = new ArrayList<ColorStop>();

  Gradient() {
    this(0xff000000, 0xffffffff);
  }

  // Creates equidistant color stops.
  Gradient(int... colors) {
    int sz = colors.length;
    float szf = sz <= 1.0 ? 1.0 : sz - 1.0;
    for (int i = 0; i < sz; ++i) {
      colorStops.add(new ColorStop(i / szf, colors[i]));
    }
  }

  // Creates equidistant color stops.
  Gradient(int colorMode, float[]... colors) {
    int sz = colors.length;
    float szf = sz <= 1.0 ? 1.0 : sz - 1.0;
    for (int i = 0; i < sz; ++i) {
      colorStops.add(new ColorStop(colorMode, i / szf, colors[i]));
    }
  }

  Gradient(ColorStop... colorStops) {
    int sz = colorStops.length;
    for (int i = 0; i < sz; ++i) {
      this.colorStops.add(colorStops[i]);
    }
    java.util.Collections.sort(this.colorStops);
    remove();
  }

  Gradient(ArrayList<ColorStop> colorStops) {
    this.colorStops = colorStops;
    java.util.Collections.sort(this.colorStops);
    remove();
  }

  void add(int colorMode, float percent, float[] arr) {
    add(new ColorStop(colorMode, percent, arr));
  }

  void add(int colorMode, float percent,
    float x, float y, float z, float w) {
    add(new ColorStop(colorMode, percent, x, y, z, w));
  }

  void add(final float percent, final int clr) {
    add(new ColorStop(percent, clr));
  }

  void add(final ColorStop colorStop) {
    for (int sz = colorStops.size(), i = sz - 1; i > 0; --i) {
      ColorStop current = colorStops.get(i);
      if (current.approxPercent(colorStop, ColorStop.TOLERANCE)) {
        println(current, "will be replaced by", colorStop);
        colorStops.remove(current);
      }
    }
    colorStops.add(colorStop);
    java.util.Collections.sort(colorStops);
  }

  int eval(final float step) {
    return eval(step, DEFAULT_COLOR_MODE);
  }

  int eval(final float step, final int colorMode) {
    int sz = colorStops.size();

    // Exit from the function early whenever possible.
    if (sz == 0) {
      return 0x00000000;
    } else if (sz == 1 || step < 0.0) {
      return colorStops.get(0).clr;
    } else if (step >= 1.0) {
      return colorStops.get(sz - 1).clr;
    }

    ColorStop currStop;
    ColorStop prevStop;
    float currPercent, scaledst;
    for (int i = 0; i < sz; ++i) {
      currStop = colorStops.get(i);
      currPercent = currStop.percent;

      if (step < currPercent) {

        // These can be declared within the for-loop because
        // if step < currPercent, the function will return
        // and no more iterations will be executed.
        float[] originclr = new float[4];
        float[] destclr = new float[4];
        float[] rsltclr = new float[4];

        // If not at the first stop in the gradient (i == 0),
        // then get the previous.
        prevStop = colorStops.get(i - 1 < 0 ? 0 : i - 1);

        scaledst = step - currPercent;
        float denom = prevStop.percent - currPercent;
        if (denom != 0) {
          scaledst /= denom;
        }

        // Assumes that color stops' colors are ints. They could
        // also be float[] arrays, in which case they wouldn't
        // need to be decomposed.
        switch(colorMode) {
        case HSB:
          rgbToHsb(currStop.clr, originclr);
          rgbToHsb(prevStop.clr, destclr);
          smootherStepHsb(originclr, destclr, scaledst, rsltclr);
          return composeclr(hsbToRgb(rsltclr));
        case RGB:
          decomposeclr(currStop.clr, originclr);
          decomposeclr(prevStop.clr, destclr);
          smootherStepRgb(originclr, destclr, scaledst, rsltclr);
          return composeclr(rsltclr);
        }
      }
    }
    return colorStops.get(sz - 1).clr;
  }

  boolean remove(ColorStop colorStop) {
    return colorStops.remove(colorStop);
  }

  ColorStop remove(int i) {
    return colorStops.remove(i);
  }

  int remove() {
    int removed = 0;
    for (int sz = colorStops.size(), i = sz - 1; i > 0; --i) {
      ColorStop current = colorStops.get(i);
      ColorStop prev = colorStops.get(i - 1);
      if (current.approxPercent(prev, ColorStop.TOLERANCE)) {
        println(current, "removed, as it was too close to", prev);
        colorStops.remove(current);
        removed++;
      }
    }
    return removed;
  }
}