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

# Art for a key: letters and numbers get their own, everything else is a heart
art_for_key() {
    case "$1" in
        [A-Za-z]) get_letter_art "${1^^}" ;;
        [0-9]) get_number_art "$1" ;;
        *) echo "$HEART_ART" ;;
    esac
}

# Scroll in one row of art repeated across the whole screen, centered, each copy
# its own color. Letters and numbers get a row of little hearts underneath.
scroll_row() {
    local key="$1"
    local art size cols width count pad padding line padded i out
    local -a copy_colors
    art=$(art_for_key "$key")
    size=$(stty size)
    cols=${size#* }
    width=$(get_max_length "$art")

    # Copies are separated by a gap of 2
    count=$(( (cols + 2) / (width + 2) ))
    if [ $count -lt 1 ]; then
        count=1
    fi
    pad=$(( (cols - count * (width + 2) + 2) / 2 ))
    if [ $pad -lt 0 ]; then
        pad=0
    fi
    printf -v padding '%*s' "$pad" ''
    for ((i=0; i<count; i++)); do
        copy_colors[i]=${colors[RANDOM % ${#colors[@]}]}
    done

    out=$'\n'
    while IFS= read -r line; do
        printf -v padded '%-*s' "$width" "$line"
        out+=$'\n'"$padding"
        for ((i=0; i<count; i++)); do
            if [ $i -gt 0 ]; then
                out+="  "
            fi
            out+=$'\e[1;'"${copy_colors[i]}m${padded//\#/♥}"
        done
    done <<< "$art"

    if [ "$art" != "$HEART_ART" ]; then
        out+=$'\n\n'"$padding"
        for ((i=0; i<(count * (width + 2) - 2) / 2; i++)); do
            out+=$'\e[1;'"${colors[RANDOM % ${#colors[@]}]}m♥ "
        done
    fi
    printf '%s\033[0m\n' "$out"
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

    scroll_row "$key"

    # Drop keys mashed while drawing so the screen doesn't lag behind
    while read -t 0; do read_key _; done
done
