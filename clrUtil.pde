// see @behrealjj's fantastic Medium article from which I ripped this
// https://medium.com/@behreajj/color-gradients-in-processing-v-2-0-e5c0b87cdfd2

int composeclr(float[] in) {
  return composeclr(in[0], in[1], in[2], in[3]);
}

// Assumes that RGBA are in range 0 .. 1.
int composeclr(float red, float green, float blue, float alpha) {
  return round(alpha * 255.0) << 24
    | round(red * 255.0) << 16
    | round(green * 255.0) << 8
    | round(blue * 255.0);
}

float[] decomposeclr(int clr) {
  return decomposeclr(clr, new float[] { 0.0, 0.0, 0.0, 1.0 });
}

// Assumes that out has 4 elements.
// 1.0 / 255.0 = 0.003921569
float[] decomposeclr(int clr, float[] out) {
  out[3] = (clr >> 24 & 0xff) * 0.003921569;
  out[0] = (clr >> 16 & 0xff) * 0.003921569;
  out[1] = (clr >> 8 & 0xff) * 0.003921569;
  out[2] = (clr & 0xff) * 0.003921569;
  return out;
}

float smootherStep(float st) {
  return st * st * st * (st * (st * 6.0 - 15.0) + 10.0);
}

float[] smootherStepRgb(float[] a, float[] b, float st, float[] out) {
  float eval = smootherStep(st);
  out[0] = a[0] + eval * (b[0] - a[0]);
  out[1] = a[1] + eval * (b[1] - a[1]);
  out[2] = a[2] + eval * (b[2] - a[2]);
  out[3] = a[3] + eval * (b[3] - a[3]);
  return out;
}

float[] smootherStepHsb(float[] a, float[] b, float st, float[] out) {

  // Find difference in hues.
  float huea = a[0];
  float hueb = b[0];
  float delta = hueb - huea;

  // Prefer shortest distance.
  if (delta < -0.5) {
    hueb += 1.0;
  } else if (delta > 0.5) {
    huea += 1.0;
  }

  float eval = smootherStep(st);

  // The two hues may be outside of 0 .. 1 range,
  // so modulate by 1.
  out[0] = (huea + eval * (hueb - huea)) % 1;
  out[1] = a[1] + eval * (b[1] - a[1]);
  out[2] = a[2] + eval * (b[2] - a[2]);
  out[3] = a[3] + eval * (b[3] - a[3]);
  return out;
}