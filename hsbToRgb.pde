// see @behrealjj's fantastic Medium article from which I ripped this
// https://medium.com/@behreajj/color-gradients-in-processing-v-2-0-e5c0b87cdfd2

float[] hsbToRgb(float[] in) {
  float[] out = new float[] { 0.0, 0.0, 0.0, 1.0 };
  return hsbToRgb(in[0], in[1], in[2], in[3], out);
}

float[] hsbToRgb(float[] in, float[] out) {
  if (in.length == 3) {
    return hsbToRgb(in[0], in[1], in[2], 1.0, out);
  } else if (in.length == 4) {
    return hsbToRgb(in[0], in[1], in[2], in[3], out);
  }
  return out;
}

float[] hsbToRgb(float hue, float sat, float bri, float alpha) {
  float[] out = new float[] { 0.0, 0.0, 0.0, 1.0 };
  return hsbToRgb(hue, sat, bri, alpha, out);
}

float[] hsbToRgb(float hue, float sat, float bri, float alpha, float[] out) {
  if (sat == 0.0) {

    // 0.0 saturation is grayscale, so all values are equal.
    out[0] = out[1] = out[2] = bri;
  } else {

    // Divide color wheel into 6 sectors.
    // Scale up hue to 6, convert to sector index.
    float h = hue * 6.0;
    int sector = int(h);

    // Depending on the sector, three tints will
    // be distributed among R, G, B channels.
    float tint1 = bri * (1.0 - sat);
    float tint2 = bri * (1.0 - sat * (h - sector));
    float tint3 = bri * (1.0 - sat * (1.0 + sector - h));

    switch (sector) {
    case 1:
      out[0] = tint2; out[1] = bri; out[2] = tint1;
      break;
    case 2:
      out[0] = tint1; out[1] = bri; out[2] = tint3;
      break;
    case 3:
      out[0] = tint1; out[1] = tint2; out[2] = bri;
      break;
    case 4:
      out[0] = tint3; out[1] = tint1; out[2] = bri;
      break;
    case 5:
      out[0] = bri; out[1] = tint1; out[2] = tint2;
      break;
    default:
      out[0] = bri; out[1] = tint3; out[2] = tint1;
    }
  }

  out[3] = alpha;
  return out;
}