class Smoother {
    float smoothValue, smoothRate, maxVal;

    Smoother(float rate, float maxAmp) {
        smoothValue = 0.0;
        smoothRate = rate;
        maxVal = maxAmp;
    }

    void update(float newValue) {
        if (newValue > smoothValue) {
            smoothValue = newValue;
        } else {
            smoothValue = ((smoothValue * smoothRate) + newValue) / (smoothRate + 1);
        }
        // if (newValue > maxVal) {
        //     maxVal = newValue;
        // }
    }

    float value() {
        return smoothValue;
    }

    float normalValue() {
        return map(smoothValue, 0, maxVal, 0, 1);
    }

    float maxVal() {
        return maxVal;
    }
}