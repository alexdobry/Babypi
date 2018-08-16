# !/bin/sh

nginx_path=/home/pi/Babypi/nginx.sh

case "$1" in
    start)
        echo "Starting Picam"
	    sudo $nginx_path start
        #sudo /home/pi/make_dirs.sh
        sudo /home/pi/picam/picam -o /run/shm/hls --volume 5.0 --channels 2 --audiobitrate 96000 --fps 15.0 --vfr --avclevel 3.1 --autoex --time --alsadev hw:1,0 >/var/log/picam.log 2>&1 &
	return $? ;;
    stop)
        echo "Stopping Picam"
	    sudo $nginx_path stop
        killall picam
	return $? ;;
    *)
        echo "Usage: picam {start|stop}"
        return 1 ;;
esac
