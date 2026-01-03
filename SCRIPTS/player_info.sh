#!/bin/bash

# Check if playerctl is running
if ! pgrep -x "playerctl" > /dev/null; then
    # Try to get status
    STATUS=$(playerctl status 2>/dev/null)
    
    if [ "$STATUS" = "Playing" ]; then
        # Get metadata
        ARTIST=$(playerctl metadata artist)
        TITLE=$(playerctl metadata title)
        
        # Limit length
        if [ ${#TITLE} -gt 30 ]; then
            TITLE=$(echo "$TITLE" | cut -c 1-27)...
        fi
        
        echo " $ARTIST - $TITLE"
        
        # Handle cover art notification (simple check to avoid spamming)
        # Store current song ID to check if it changed
        CURRENT_ID=$(playerctl metadata mpris:trackid)
        if [ -f /tmp/current_song_id ]; then
            LAST_ID=$(cat /tmp/current_song_id)
        else
            LAST_ID=""
        fi
        
        if [ "$CURRENT_ID" != "$LAST_ID" ]; then
            echo "$CURRENT_ID" > /tmp/current_song_id
            # Get cover art URL
            ART_URL=$(playerctl metadata mpris:artUrl)
            if [[ $ART_URL == file://* ]]; then
                ART_PATH=${ART_URL#file://}
                notify-send -i "$ART_PATH" "Now Playing" "$ARTIST - $TITLE"
            elif [[ $ART_URL == http* ]]; then
                # Download temp cover
                curl -s "$ART_URL" -o /tmp/cover_art.jpg
                notify-send -i /tmp/cover_art.jpg "Now Playing" "$ARTIST - $TITLE"
            fi
        fi
    elif [ "$STATUS" = "Paused" ]; then
        echo " Paused"
    else
        echo ""
    fi
else
    echo ""
fi
