// see @behrealjj's fantastic Medium article from which I ripped this
// https://medium.com/@behreajj/color-gradients-in-processing-v-2-0-e5c0b87cdfd2

float[] rgbToHsb(int clr) {
  return rgbToHsb(clr, new float[] { 0.0, 0.0, 0.0, 1.0 });
}

float[] rgbToHsb(int clr, float[] out) {
  return rgbToHsb((clr >> 16 & 0xff) * 0.003921569,
    (clr >> 8 & 0xff) * 0.003921569,
    (clr & 0xff) * 0.003921569,
    (clr >> 24 & 0xff) * 0.003921569, out);
}

float[] rgbToHsb(float[] in) {
  return rgbToHsb(in, new float[] { 0.0, 0.0, 0.0, 1.0 });
}

float[] rgbToHsb(float[] in, float[] out) {
  if (in.length == 3) {
    return rgbToHsb(in[0], in[1], in[2], 1.0, out);
  } else if (in.length == 4) {
    return rgbToHsb(in[0], in[1], in[2], in[3], out);
  }
  return out;
}

float[] rgbToHsb(float red, float green, float blue, float alpha, float[] out) {

  // Find highest and lowest values.
  float max = max(red, green, blue);
  float min = min(red, green, blue);

  // Find the difference between max and min.
  float delta = max - min;

  // Calculate hue.
  float hue = 0.0;
  if (delta != 0.0) {
    if (red == max) {
      hue = (green - blue) / delta;
    } else if (green == max) {
      hue = 2.0 + (blue - red) / delta;
    } else {
      hue = 4.0 + (red - green) / delta;
    }

    hue /= 6.0;
    if (hue < 0.0) {
      hue += 1.0;
    }
  }

  out[0] = hue;
  out[1] = max == 0.0 ? 0.0 : (max - min) / max;
  out[2] = max;
  out[3] = alpha;
  return out;
}