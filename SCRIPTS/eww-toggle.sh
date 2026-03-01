#!/bin/bash
# Toggle sidebar de eww
STATE=$(eww state | grep -c "sidebar")
if eww windows | grep -q "\*sidebar"; then
    eww close sidebar
else
    eww open sidebar
fi
