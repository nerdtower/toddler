#!/bin/bash
#
# toddler.sh - Child-friendly interactive terminal application for learning letters and numbers
# Copyright (c) 2024 Nerd Tower LLC
# Licensed under the MIT License - see LICENSE file for details
#
cleanup() {
    clear
    echo "Goodbye!"
    exit 0
}

restore_terminal() {
    stty "$saved_stty" 2>/dev/null
    # Reset colors and show the cursor again
    printf '\033[0m\033[?25h'
}

# Function to get letter ASCII art
get_letter_art() {
    local letter="$1"
    case "$letter" in
        A) echo "    A    
   A A   
  AAAAA  
 A     A 
A       A" ;;
        B) echo "BBBBB  
B     B
BBBBB  
B     B
BBBBB  " ;;
        C) echo " CCCCC 
C     C
C      
C      
C     C
 CCCCC " ;;
        D) echo "DDDDD  
D     D
D     D
D     D
DDDDD  " ;;
        E) echo "EEEEE
E    
EEEE 
E    
EEEEE" ;;
        F) echo "FFFFF
F    
FFFF 
F    
F    " ;;
        G) echo " GGGGG 
G     G
G      
G   GGG
G     G
 GGGGG " ;;
        H) echo "H     H
H     H
HHHHHHH
H     H
H     H" ;;
        I) echo "IIIII
  I  
  I  
  I  
IIIII" ;;
        J) echo "     J
     J
     J
J    J
 JJJJ " ;;
        K) echo "K   K
K  K 
KKK  
K  K 
K   K" ;;
        L) echo "L    
L    
L    
L    
LLLLL" ;;
        M) echo "M     M
MM   MM
M M M M
M  M  M
M     M" ;;
        N) echo "N     N
NN    N
N N   N
N  N  N
N     N" ;;
        O) echo " OOOOO 
O     O
O     O
O     O
 OOOOO " ;;
        P) echo "PPPPPP 
P     P
PPPPPP 
P      
P      " ;;
        Q) echo " QQQQQ 
Q     Q
Q     Q
Q   Q Q
 QQQQQ 
      Q" ;;
        R) echo "RRRRRR 
R     R
RRRRRR 
R   R  
R     R" ;;
        S) echo " SSSSS 
S     S
 SSSSS 
      S
S     S
 SSSSS " ;;
        T) echo "TTTTTTT
   T   
   T   
   T   
   T   " ;;
        U) echo "U     U
U     U
U     U
U     U
 UUUUU " ;;
        V) echo "V     V
V     V
V     V
 V   V 
  V V  
   V   " ;;
        W) echo "W     W
W     W
W  W  W
W W W W
WW   WW" ;;
        X) echo "X     X
 X   X 
  X X  
 X   X 
X     X" ;;
        Y) echo "Y     Y
 Y   Y 
  Y Y  
   Y   
   Y   " ;;
        Z) echo "ZZZZZZZ
     Z 
   Z   
 Z     
ZZZZZZZ " ;;
        *) echo "" ;;
    esac
}

# Function to get number ASCII art
get_number_art() {
    local number="$1"
    case "$number" in
        0) echo " 0000 
0    0
0    0
0    0
 0000 " ;;
        1) echo "  11  
 111  
  11  
  11  
 1111 " ;;
        2) echo " 2222 
2    2
    2 
   2  
  2   
222222" ;;
        3) echo " 3333 
3    3
    3 
 3333 
3    3
 3333 " ;;
        4) echo "4   4 
4   4 
4   4 
444444
    4 
    4 " ;;
        5) echo "555555
5     
55555 
     5
5    5
 5555 " ;;
        6) echo " 6666 
6     
6     
66666 
6    6
 6666 " ;;
        7) echo "777777
     7
    7 
   7  
  7   
 7    " ;;
        8) echo " 8888 
8    8
 8888 
8    8
 8888 " ;;
        9) echo " 9999 
9    9
 99999
     9
9    9
 9999 " ;;
        *) echo "" ;;
    esac
}

# Function to get maximum line length from an array of lines
get_max_length() {
    local max_len=0
    while IFS= read -r line; do
        local len=${#line}
        if [ $len -gt $max_len ]; then
            max_len=$len
        fi
    done <<< "$1"
    echo $max_len
}

# A big heart, drawn with '#' so padding stays byte-safe; '#' becomes a heart when printed
HEART_ART=" ###   ### 
##### #####
###########
 ######### 
  #######  
   #####   
    ###    
     #     "

# Print ASCII art side by side repeat_count times in one color
print_art() {
    local art="$1"
    local color="$2"
    local repeat_count="$3"
    local max_length=$(get_max_length "$art")
    local line row padded j

    printf '\033[1;%sm' "$color"
    while IFS= read -r line; do
        row=""
        for ((j=1; j<=repeat_count; j++)); do
            printf -v padded "%-*s" "$max_length" "$line"
            row+="$padded"
            if [ $j -lt $repeat_count ]; then
                row+="  "
            fi
        done
        echo "${row//\#/♥}"
    done <<< "$art"
    printf '\033[0m'
}

# Print a row of little hearts, each a different color
print_heart_row() {
    local count="$1"
    local i
    for ((i=1; i<=count; i++)); do
        printf '\033[1;%sm♥ ' "${colors[$RANDOM % ${#colors[@]}]}"
    done
    printf '\033[0m\n\n'
}

# Letters and numbers get big art with hearts underneath; every other key is a big heart
print_big_letter() {
    local letter="$1"
    local color="$2"
    local repeat_count="${3:-1}"
    local art=""

    case "$letter" in
        [A-Za-z]) art=$(get_letter_art "$(echo "$letter" | tr '[:lower:]' '[:upper:]')") ;;
        [0-9]) art=$(get_number_art "$letter") ;;
    esac

    echo
    if [ -n "$art" ]; then
        print_art "$art" "$color" "$repeat_count"
        echo
        print_heart_row $((repeat_count * 4))
    else
        print_art "$HEART_ART" "$color" "$repeat_count"
        echo
    fi
}

# A small heart for stickers
STICKER_HEART_ART=" ## ## 
#######
 ##### 
  ###  
   #   "

# Art for a key: letters and numbers get their own, everything else is a heart
art_for_key() {
    case "$1" in
        [A-Za-z]) get_letter_art "${1^^}" ;;
        [0-9]) get_number_art "$1" ;;
        *) echo "$2" ;;
    esac
}

# Set ART_W and ART_H to the size of a piece of art, without a subshell
measure_art() {
    local line
    ART_W=0
    ART_H=0
    while IFS= read -r line; do
        if [ ${#line} -gt $ART_W ]; then
            ART_W=${#line}
        fi
        ART_H=$((ART_H + 1))
    done <<< "$1"
}

# Stickers stay on screen until the next heart burst. Each one is stored
# pre-rendered, with spaces turned into cursor moves so the stickers
# underneath show through.
stickers=()

add_sticker() {
    local art="$1" color="$2" rows="$3" cols="$4"
    local line top left r=0 sticker
    measure_art "$art"
    if [ $ART_H -gt $rows ] || [ $ART_W -gt $cols ]; then
        return
    fi
    top=$((1 + RANDOM % (rows - ART_H + 1)))
    left=$((1 + RANDOM % (cols - ART_W + 1)))
    sticker=$'\e[1;'"${color}m"
    while IFS= read -r line; do
        line=${line//\#/♥}
        sticker+=$'\e['"$((top + r));${left}H${line// /$'\e[C'}"
        r=$((r + 1))
    done <<< "$art"
    stickers+=("$sticker")
}

# Add a handful of hearts at random spots to FRAME
sprinkle_hearts() {
    local count="$1" rows="$2" cols="$3" i
    for ((i=0; i<count; i++)); do
        FRAME+=$'\e['"$((1 + RANDOM % rows));$((1 + RANDOM % cols))H"
        FRAME+=$'\e[1;'"${colors[RANDOM % ${#colors[@]}]}m♥"
    done
    FRAME+=$'\e[0m'
}

# Add art to FRAME scaled up to fill the screen, centered, in solid color blocks.
# Background colors draw solid blocks with any console font.
draw_giant() {
    local art="$1" color="$2" rows="$3" cols="$4"
    local scale scale_x cell_w top left block gap line row i k r=0
    measure_art "$art"

    # Console cells are about twice as tall as they are wide, so each art cell is 2 wide
    scale=$(( (rows - 2) / ART_H ))
    scale_x=$(( (cols - 4) / (ART_W * 2) ))
    if [ $scale_x -lt $scale ]; then
        scale=$scale_x
    fi
    if [ $scale -lt 1 ]; then
        scale=1
    fi
    cell_w=$((scale * 2))
    top=$(( (rows - ART_H * scale) / 2 + 1 ))
    left=$(( (cols - ART_W * cell_w) / 2 + 1 ))
    printf -v block '%*s' "$cell_w" ''
    gap=$'\e['"${cell_w}C"

    FRAME+=$'\e['"$((color % 10 + 40))m"
    while IFS= read -r line; do
        row=""
        for ((i=0; i<${#line}; i++)); do
            if [ "${line:i:1}" = " " ]; then
                row+=$gap
            else
                row+=$block
            fi
        done
        for ((k=0; k<scale; k++)); do
            FRAME+=$'\e['"$((top + r * scale + k));${left}H${row}"
        done
        r=$((r + 1))
    done <<< "$art"
    FRAME+=$'\e[0m'
}

# Fill the screen with hearts, then start a fresh sticker book
heart_burst() {
    local rows="$1" cols="$2" i
    for ((i=0; i<20; i++)); do
        FRAME=""
        sprinkle_hearts $((rows * cols / 40)) "$rows" "$cols"
        printf '%s' "$FRAME"
        sleep 0.05
    done
    stickers=()
}

# Holding space scrolls rows of big hearts across the whole screen, each heart its own color
scroll_hearts() {
    local size rows cols count pad padding line i out
    local -a heart_colors
    size=$(stty size)
    rows=${size% *}
    cols=${size#* }

    # Hearts are 11 wide with a gap of 2
    count=$(( (cols + 2) / 13 ))
    if [ $count -lt 1 ]; then
        count=1
    fi
    pad=$(( (cols - count * 13 + 2) / 2 ))
    if [ $pad -lt 0 ]; then
        pad=0
    fi
    printf -v padding '%*s' "$pad" ''
    for ((i=0; i<count; i++)); do
        heart_colors[i]=${colors[RANDOM % ${#colors[@]}]}
    done

    out=$'\e['"${rows};1H"
    while IFS= read -r line; do
        out+=$'\n'"$padding"
        for ((i=0; i<count; i++)); do
            if [ $i -gt 0 ]; then
                out+="  "
            fi
            out+=$'\e[1;'"${heart_colors[i]}m${line//\#/♥}"
        done
    done <<< "$HEART_ART"
    printf '%s\033[0m\n' "$out"
}

# One keypress: the sticker book, a few loose hearts, and the new key as a giant
# in the middle. The giant becomes a sticker on the next keypress.
draw_screen() {
    local key="$1" color="$2"
    local size rows cols sticker
    size=$(stty size)
    rows=${size% *}
    cols=${size#* }

    if [ ${#stickers[@]} -ge $((rows * cols / 60)) ]; then
        heart_burst "$rows" "$cols"
    fi

    FRAME=$'\e[2J'
    for sticker in "${stickers[@]}"; do
        FRAME+=$sticker
    done
    FRAME+=$'\e[0m'
    sprinkle_hearts 12 "$rows" "$cols"
    draw_giant "$(art_for_key "$key" "$HEART_ART")" "$color" "$rows" "$cols"
    FRAME+=$'\e['"${rows};1H"
    printf '%s' "$FRAME"

    add_sticker "$(art_for_key "$key" "$STICKER_HEART_ART")" "$color" "$rows" "$cols"
}

# Color list
colors=(31 32 33 34 35 36 91 92 93 94 95 96)

# Parse command line arguments
repeat_count=5
test_mode=false
test_letter=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--number)
            repeat_count="$2"
            shift 2
            ;;
        test)
            test_mode=true
            test_letter="${2:-A}"
            shift 2
            ;;
        *)
            echo "Usage: $0 [-n|--number COUNT] [test [CHARACTER]]"
            echo "  -n, --number COUNT: Test mode only - copies of the character per line (default: 5)"
            echo "  test [CHARACTER]: Test mode - print one character and exit"
            exit 1
            ;;
    esac
done

# Check if test mode is requested
if [ "$test_mode" = true ]; then
    # Test mode: output one letter and quit
    color=${colors[$RANDOM % ${#colors[@]}]}
    print_big_letter "$test_letter" "$color" "$repeat_count"
    exit 0
fi

# Child-proof the terminal: no echo, no line buffering, and no special keys.
# -isig makes Ctrl+C/Ctrl+Z/Ctrl+\ plain keypresses, -ixon stops Ctrl+S from
# freezing the screen, -iexten disables Ctrl+V and Ctrl+O.
saved_stty=$(stty -g)
trap restore_terminal EXIT
trap '' INT TERM TSTP TTIN TTOU QUIT
stty -echo -icanon -isig -ixon -iexten min 1 time 0
printf '\033[?25l'
clear

# Read one keypress, including Enter, space, and backslash
read_key() {
    IFS= read -rsn1 -d '' "$@"
}

while true; do
    read_key key || continue

    # Arrow and function keys send an escape sequence; swallow the rest of it
    if [ "$key" = $'\e' ]; then
        while read_key -t 0.02 _; do :; done
    fi

    # Silent adult exit: z, then 9, then ! (shift+1), each within 1 second
    if [ "$key" = "z" ] || [ "$key" = "Z" ]; then
        if read_key -t 1 step1 && [ "$step1" = "9" ]; then
            if read_key -t 1 step2 && [ "$step2" = "!" ]; then
                cleanup
            fi
        fi
    fi

    # Random color
    color=${colors[$RANDOM % ${#colors[@]}]}

    if [ "$key" = " " ]; then
        scroll_hearts
    else
        draw_screen "$key" "$color"
    fi

    # Drop keys mashed while drawing so the screen doesn't lag behind
    while read -t 0; do read_key _; done
done
