#!/usr/bin/python
import sys
import Adafruit_DHT
import time

pin = 24
humidity, temperature = Adafruit_DHT.read_retry(Adafruit_DHT.DHT22, pin)
date = time.time()
if humidity is not None and temperature is not None:
    print('{ "status" : "OK", "temperature": {0:0.1f}, "humidity": {1:0.1f}, "timestamp": {2:0.0f} }'.format(temperature, humidity, date))
else:
    sys.exit(1)
