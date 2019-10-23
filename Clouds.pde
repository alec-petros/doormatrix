class Cloud {
    float noiseTrigger;
    float noiseSpeed;

    Cloud(float speed, FFT fftLin) {
        noiseSpeed = speed;
        noiseTrigger = random(0, 1000);
    }

    void draw(float normalAmp) {
        noiseTrigger += noiseSpeed + map(normalAmp, 0, 1, 0, 0.1); 

        float z = noiseTrigger;

        loadPixels();
        float xoff = 0;
        for (int x = 0; x < width; x++) {
            float yoff = 0;
            for (int y = height - 1; y >= 0; y--) {

                float noiseOne = noise(xoff, yoff, z);
                float noiseTwo = noise(xoff, yoff, z + 10000);

                color c = color(
                    map(noiseOne, 0, 1, 80, 300),
                    map(noiseTwo, 0, 1, 0, 255),
                    map(normalAmp, 0, 1, 0, 360)
                );
            
                pixels[x + width*y] = c;
                yoff += 0.01;
            }
            xoff += 0.01;
        }
        updatePixels();
    }
}