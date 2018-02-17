sudo bash /home/pi/make_dirs.sh
sudo /home/pi/picam/picam -o /run/shm/hls --volume 5.0 --channels 2 --audiobitrate 96000 --vfr --avclevel 3.1 --autoex --time --alsadev hw:1,0 >/var/log/picam.log 2>&1 &
