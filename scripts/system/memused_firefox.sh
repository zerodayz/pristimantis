#!/bin/bash

while true; do
  sleep 60
  echo "$(date) - $(ps -eo comm,rss| grep firefox)" >> /tmp/firefox.log
done
