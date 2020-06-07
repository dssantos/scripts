#!/bin/bash

# This script can be set on OS crontab ou startup applications
xmodmap -e 'keycode 44 = '
xmodmap -e 'keycode 135 = j'
echo 'J Key switched to Menu Key'
