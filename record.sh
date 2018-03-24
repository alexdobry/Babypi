#!/bin/sh

if [ $# -eq 2 ]
then
	auth=$1
	webdav=$2
	hooks=/hooks
	rec=/rec
	archive=$rec/archive

	echo recording ...
	touch $hooks/mute
	sleep 2
	touch $hooks/start_record
	sleep 8
	touch $hooks/stop_record
	sleep 2
	touch $hooks/unmute
	echo finished recording 

	cd $archive
	record=`ls $archive | sort -r | head -1 | grep .ts`
	timestamp=`date +%s`
	filename=$timestamp.mp4
	ffmpeg -i $record -c:v copy -c:a copy -bsf:a aac_adtstoasc $filename
	if [ $? -eq 0 ]
	then
		echo converted $record to $filename
	else
		echo failed conversion
		return 1
	fi

	echo uploading ...
	curl -T $filename -u $auth $webdav/video.mp4 --verbose
	echo finished uploading
	
	rm $rec/*.ts
	rm $archive/*
	echo everything is cleaned up

	return 0
else
	echo provide authentication as arg 1 and webdav url as arg 2
	return 1 
fi
