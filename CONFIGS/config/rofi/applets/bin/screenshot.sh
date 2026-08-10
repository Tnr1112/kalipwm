/**
 * Rofi Screenshot Launcher Configuration (gh0stzk/dotfiles)
 * Repository: kalipwm (branch: design_changes)
 **/

@import "colors.rasi"

configuration {
    show-icons:                 false;
}

window {
    transparency:               "real";
    location:                   center;
    anchor:                     center;
    fullscreen:                 false;
    width:                      750px;
    padding:                    20px;
    border:                     1px solid;
    border-radius:              8px;
    border-color:               #ff2cf1;
    background-color:           @background;
}

mainbox {
    background-color:           transparent;
    spacing:                    15px;
    children:                   [ "inputbar", "message", "listview" ];
}

inputbar {
    spacing:                    10px;
    padding:                    0px;
    background-color:           transparent;
    text-color:                 @foreground;
    children:                   [ "textbox-prompt-colon", "prompt" ];
}

textbox-prompt-colon {
    expand:                     false;
    str:                        "🖼️";
    padding:                    8px 12px;
    border-radius:              4px;
    background-color:           #282a36;
    text-color:                 #ffffff;
}

prompt {
    padding:                    8px 16px;
    border-radius:              4px;
    background-color:           #ffffff;
    text-color:                 #000000;
    font:                       "JetBrainsMono Nerd Font 10 Bold 10";
}

message {
    padding:                    10px 0px;
    background-color:           transparent;
    text-color:                 #888888;
}

listview {
    columns:                    5;
    lines:                      1;
    spacing:                    12px;
    cycle:                      true;
    dynamic:                    true;
    scrollbar:                  false;
    layout:                     vertical;
    background-color:           transparent;
}

element {
    padding:                    20px 0px;
    border:                     1px solid;
    border-radius:              4px;
    border-color:               #333339;
    background-color:           #151518;
    text-color:                 @foreground;
    cursor:                     pointer;
}

element selected.normal {
    background-color:           #ffffff;
    text-color:                 #000000;
    border-color:               #ff2cf1;
}

element-text {
    font:                       "Feather 20";
    horizontal-align:           0.5;
    vertical-align:             0.5;
    background-color:           transparent;
    text-color:                 inherit;
}
