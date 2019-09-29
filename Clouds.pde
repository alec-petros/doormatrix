class Cloud {
    float noiseTrigger;
    float noiseSpeed;

    Cloud(float speed) {
        noiseSpeed = speed;
        noiseTrigger = random(0, 1000);
    }

    void draw() {
        noiseTrigger += noiseSpeed;

        long now = millis();
        float z = now * 0.00008;

        loadPixels();
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {

                float noisePoint = noise(x / 10 + noiseTrigger, y / 10 + noiseTrigger, z);

                color c = color(
                    map(noisePoint, 0, 1, 80, 300),
                    map(noisePoint, 0, 1, 200, 255),
                    map(noisePoint, 0, 1, -100, 180)
                );
            
                pixels[x + width*y] = c;
            }
        }
        updatePixels();
    }
}