#! /bin/sh

light_pin=2
gpio -g mode $light_pin out

case "$1" in  
	on) 
		gpio -g write $light_pin 1
		return $? ;;
	off)
        	gpio -g write $light_pin 0
		return $? ;;
	status)
		gpio -g read $light_pin
		return $? ;;
	*)
		echo "usage light {on|off|status}"
		return 1 ;;
esac
