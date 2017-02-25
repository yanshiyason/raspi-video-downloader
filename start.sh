#!/bin/bash
export PATH=/home/pi/.pyenv/shims:/home/pi/.pyenv/bin:/home/pi/.rbenv/shims:/home/pi/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
export HOME=/home/pi
export RASPI_VIDEO_DOWNLOADER_HOME=/home/pi/workspace/raspi-video-downloader

/home/pi/.rbenv/shims/ruby $RASPI_VIDEO_DOWNLOADER_HOME/app.rb >> $RASPI_VIDEO_DOWNLOADER_HOME/logs/raspi-video.log 2>&1 &
/home/pi/ngrok http --hostname $NGROK_HOSTNAME -region ap -config=/home/pi/.ngrok2/ngrok.yml 3000 >> $RASPI_VIDEO_DOWNLOADER_HOME/logs/raspi-ngrok.log 2>&1
