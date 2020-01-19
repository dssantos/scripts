#!/bin/bash
# Run retropie emulator over raspbian desktop
xdotool key "ctrl+alt+t"
xdotool sleep 1
xdotool type "ssh pi@localhost; exit"
xdotool key KP_Enter
xdotool type "emulationstation; exit"
xdotool key KP_Enter
