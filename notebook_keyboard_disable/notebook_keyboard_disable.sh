#!/bin/bash

# https://askubuntu.com/questions/160945/is-there-a-way-to-disable-a-laptops-internal-keyboard

Icon=icon.png
Icoff=icoff.png
fconfig=".keyboard" 
scriptPath=$HOME/scripts/notebook_keyboard_disable
id=14


if [ ! -f $scriptPath/$fconfig ];
    then
        echo "Creating config file"
        echo "enabled" > $scriptPath/$fconfig
        var="enabled"
    else
        read -r var< $scriptPath/$fconfig
        echo "keyboard is : $var"
fi

if [ $var = "disabled" ];
    then
        notify-send -i $scriptPath/$Icon "Enabling keyboard..." \ "ON - Keyboard connected !";
        echo "enable keyboard..."
        xinput enable $id
        echo "enabled" > $scriptPath/$fconfig
    elif [ $var = "enabled" ]; then
        notify-send -i $scriptPath/$Icoff "Disabling Keyboard" \ "OFF - Keyboard disconnected";
        echo "disable keyboard"
        xinput disable $id
        echo 'disabled' > $scriptPath/$fconfig
fi
