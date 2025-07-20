#!/bin/bash
#
# toddler.sh - Child-friendly interactive terminal application for learning letters and numbers
# Copyright (c) 2024 Nerd Tower LLC
# Licensed under the MIT License - see LICENSE file for details
#
# Setup
stty -echo -icanon time 1 min 0

# Clear screen on startup
clear

# Disable most interrupt signals - make it child-proof!
# We'll handle exit via custom key sequence in the main loop
trap '' INT TERM SIGTSTP SIGTTIN SIGTTOU SIGQUIT

cleanup() {
    # Restore terminal settings
    stty sane
    stty echo icanon
    # Clear any pending input
    while read -t0; do :; done 2>/dev/null || true
    # Reset terminal colors
    echo -e "\033[0m"
    # Clear screen
    clear
    echo -e "\nGoodbye!"
    exit 0
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

# Function to pad a line to a specific width
pad_line() {
    local line="$1"
    local width="$2"
    printf "%-*s" "$width" "$line"
}

# ASCII art function for letters and numbers
print_big_letter() {
    local letter="$1"
    local color="$2"
    local repeat_count="${3:-1}"
    
    case "$letter" in
        [A-Za-z])
            # Convert to uppercase
            local upper_letter=$(echo "$letter" | tr '[:lower:]' '[:upper:]')
            
            # Get the art for this letter
            local art=$(get_letter_art "$upper_letter")
            
            if [ -n "$art" ]; then
                echo -e "\033[${color}m"
                
                # Get the maximum line length for padding
                local max_length=$(get_max_length "$art")
                
                # Print each line repeated
                while IFS= read -r line; do
                    for ((j=1; j<=repeat_count; j++)); do
                        pad_line "$line" "$max_length"
                        if [ $j -lt $repeat_count ]; then
                            echo -n "  "
                        fi
                    done
                    echo
                done <<< "$art"
                
                echo -e "\033[0m"
            else
                # Fallback for unknown letters
                echo -e "\033[${color}m"
                for ((i=1; i<=repeat_count; i++)); do
                    echo -n "  $letter$letter$letter$letter$letter  "
                    if [ $i -lt $repeat_count ]; then echo -n "  "; fi
                done
                echo
                for ((i=1; i<=repeat_count; i++)); do
                    echo -n " $letter$letter$letter$letter$letter$letter$letter "
                    if [ $i -lt $repeat_count ]; then echo -n "  "; fi
                done
                echo
                for ((i=1; i<=repeat_count; i++)); do
                    echo -n "$letter$letter$letter$letter$letter$letter$letter$letter$letter"
                    if [ $i -lt $repeat_count ]; then echo -n "  "; fi
                done
                echo
                for ((i=1; i<=repeat_count; i++)); do
                    echo -n " $letter$letter$letter$letter$letter$letter$letter "
                    if [ $i -lt $repeat_count ]; then echo -n "  "; fi
                done
                echo
                for ((i=1; i<=repeat_count; i++)); do
                    echo -n "  $letter$letter$letter$letter$letter  "
                    if [ $i -lt $repeat_count ]; then echo -n "  "; fi
                done
                echo
                echo -e "\033[0m"
            fi
            ;;
        [0-9])
            # Get the art for this number
            local art=$(get_number_art "$letter")
            
            if [ -n "$art" ]; then
                echo -e "\033[${color}m"
                
                # Get the maximum line length for padding
                local max_length=$(get_max_length "$art")
                
                # Print each line repeated
                while IFS= read -r line; do
                    for ((j=1; j<=repeat_count; j++)); do
                        pad_line "$line" "$max_length"
                        if [ $j -lt $repeat_count ]; then
                            echo -n "  "
                        fi
                    done
                    echo
                done <<< "$art"
                
                echo -e "\033[0m"
            else
                # Fallback for unknown numbers
                echo -e "\033[${color}m"
                for ((i=1; i<=repeat_count; i++)); do
                    echo -n "  $letter$letter$letter$letter$letter  "
                    if [ $i -lt $repeat_count ]; then echo -n "  "; fi
                done
                echo
                for ((i=1; i<=repeat_count; i++)); do
                    echo -n " $letter$letter$letter$letter$letter$letter$letter "
                    if [ $i -lt $repeat_count ]; then echo -n "  "; fi
                done
                echo
                for ((i=1; i<=repeat_count; i++)); do
                    echo -n "$letter$letter$letter$letter$letter$letter$letter$letter$letter"
                    if [ $i -lt $repeat_count ]; then echo -n "  "; fi
                done
                echo
                for ((i=1; i<=repeat_count; i++)); do
                    echo -n " $letter$letter$letter$letter$letter$letter$letter "
                    if [ $i -lt $repeat_count ]; then echo -n "  "; fi
                done
                echo
                for ((i=1; i<=repeat_count; i++)); do
                    echo -n "  $letter$letter$letter$letter$letter  "
                    if [ $i -lt $repeat_count ]; then echo -n "  "; fi
                done
                echo
                echo -e "\033[0m"
            fi
            ;;
        *)
            # For non-letters, create a simple block pattern
            echo -e "\033[${color}m"
            for ((i=1; i<=repeat_count; i++)); do
                echo -n "  $letter$letter$letter$letter$letter  "
                if [ $i -lt $repeat_count ]; then echo -n "  "; fi
            done
            echo
            for ((i=1; i<=repeat_count; i++)); do
                echo -n " $letter$letter$letter$letter$letter$letter$letter "
                if [ $i -lt $repeat_count ]; then echo -n "  "; fi
            done
            echo
            for ((i=1; i<=repeat_count; i++)); do
                echo -n "$letter$letter$letter$letter$letter$letter$letter$letter$letter"
                if [ $i -lt $repeat_count ]; then echo -n "  "; fi
            done
            echo
            for ((i=1; i<=repeat_count; i++)); do
                echo -n " $letter$letter$letter$letter$letter$letter$letter "
                if [ $i -lt $repeat_count ]; then echo -n "  "; fi
            done
            echo
            for ((i=1; i<=repeat_count; i++)); do
                echo -n "  $letter$letter$letter$letter$letter  "
                if [ $i -lt $repeat_count ]; then echo -n "  "; fi
            done
            echo
            echo -e "\033[0m"
            ;;
    esac
}

# Color list
colors=(31 32 33 34 35 36 37)

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
            echo "  -n, --number COUNT: Number of characters to display on each line (default: 5)"
            echo "  test [CHARACTER]: Test mode - display one character and exit"
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

while true; do
    read -n1 key

    if [ "$key" != "" ]; then
        # Check for exit sequence: requires a very specific, non-sequential combination
        # This is virtually impossible for a toddler to trigger accidentally
        if [ "$key" = "z" ] || [ "$key" = "Z" ]; then
            # First step: check for '9' within 1 second (number, not letter)
            echo -n "Press '9' within 1 second to continue exit sequence: "
            read -t 1 -n1 step1
            if [ "$step1" = "9" ]; then
                # Second step: check for '!' within 1 second (symbol, requires shift)
                echo -n "Press '!' (shift+1) within 1 second to exit: "
                read -t 1 -n1 step2
                if [ "$step2" = "!" ]; then
                    cleanup
                    exit 0
                fi
            fi
            echo  # New line after the prompt
        fi
        
        # Random color
        color=${colors[$RANDOM % ${#colors[@]}]}

        # Print big colored letter with specified repeat count
        print_big_letter "$key" "$color" "$repeat_count"
    fi
done