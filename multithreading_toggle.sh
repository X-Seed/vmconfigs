#!/bin/bash

function enabled() {
    echo -en "Enabling HyperThreading\n"
    echo on > /sys/devices/system/cpu/smt/control
}

function disabled() {
    echo -en "Disabling HyperThreading\n"
    echo off > /sys/devices/system/cpu/smt/control
}

ONLINE=$(cat /sys/devices/system/cpu/online)
OFFLINE=$(cat /sys/devices/system/cpu/offline)
echo "---------------------------------------------------"
echo -en "CPU's online: $ONLINE\t CPU's offline: $OFFLINE\n"
echo "---------------------------------------------------"
while true; do
    read -p "Type in e to enable or d disable hyperThreading or q to quit [e/d/q] ?" ed
    case $ed in
        [Ee]* ) enabled; break;;
        [Dd]* ) disabled;exit;;
        [Qq]* ) exit;;
        * ) echo "Please answer e for enable or d for disable hyperThreading.";;
    esac
done