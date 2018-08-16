#!/bin/sh

sudo kill -9 `pgrep -f app.js` >/dev/null 2>&1
sudo node /home/pi/Babypi/server/app.js
