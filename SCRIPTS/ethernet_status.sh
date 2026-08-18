#!/bin/sh
 
echo "%{F#2495e7}󰈀 %{F#ffffff}$(/usr/sbin/ip -4 addr show | awk '/inet / && !/127.0.0.1/ {print $2}' | cut -d/ -f1 | head -n 1)%{u-}"
