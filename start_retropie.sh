#!/bin/bash
# Run retropie emulator over raspbian desktop
xdotool key "ctrl+alt+t"
xdotool sleep 1
xdotool type "ssh pi@localhost"
xdotool key KP_Enter
xdotool type emulationstation
xdotool key KP_Enter
