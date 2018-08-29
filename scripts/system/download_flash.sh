#!/bin/bash
/usr/bin/mkdir /tmp/flash
/usr/bin/wget 'https://fpdownload.adobe.com/get/flashplayer/pdc/11.2.202.559/install_flash_player_11_linux.x86_64.tar.gz' -O /tmp/flash.tar.gz
/usr/bin/tar -xvf /tmp/flash.tar.gz -C /tmp/flash
/usr/bin/cp /tmp/flash/libflashplayer.so ~/.mozilla/plugins/libflashplayer.so

/usr/bin/rm -Rf /tmp/flash.tar.gz
/usr/bin/rm -Rf /tmp/flash
