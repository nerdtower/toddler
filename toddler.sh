#!/bin/bash

# Setup
stty -echo -icanon time 1 min 0

# Disable most interrupt signals - make it child-proof!
# But allow Ctrl-\ (SIGQUIT) for adult exit
trap '' INT TERM SIGTSTP SIGTTIN SIGTTOU
trap cleanup SIGQUIT

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

# ASCII art function for letters
print_big_letter() {
    local letter="$1"
    local color="$2"
    
    case "$letter" in
        [A-Za-z])
            # Simple ASCII art for letters
            case "$letter" in
                [Aa])
                    echo -e "\033[${color}m"
                    echo "    A    "
                    echo "   A A   "
                    echo "  AAAAA  "
                    echo " A     A "
                    echo "A       A"
                    echo -e "\033[0m"
                    ;;
                [Bb])
                    echo -e "\033[${color}m"
                    echo "BBBBB  "
                    echo "B     B"
                    echo "BBBBB  "
                    echo "B     B"
                    echo "BBBBB  "
                    echo -e "\033[0m"
                    ;;
                [Cc])
                    echo -e "\033[${color}m"
                    echo " CCCCC "
                    echo "C     C"
                    echo "C      "
                    echo "C      "
                    echo "C     C"
                    echo " CCCCC "
                    echo -e "\033[0m"
                    ;;
                [Dd])
                    echo -e "\033[${color}m"
                    echo "DDDDD  "
                    echo "D     D"
                    echo "D     D"
                    echo "D     D"
                    echo "DDDDD  "
                    echo -e "\033[0m"
                    ;;
                [Ee])
                    echo -e "\033[${color}m"
                    echo "EEEEE"
                    echo "E    "
                    echo "EEEE "
                    echo "E    "
                    echo "EEEEE"
                    echo -e "\033[0m"
                    ;;
                [Ff])
                    echo -e "\033[${color}m"
                    echo "FFFFF"
                    echo "F    "
                    echo "FFFF "
                    echo "F    "
                    echo "F    "
                    echo -e "\033[0m"
                    ;;
                [Gg])
                    echo -e "\033[${color}m"
                    echo " GGGGG "
                    echo "G     G"
                    echo "G      "
                    echo "G   GGG"
                    echo "G     G"
                    echo " GGGGG "
                    echo -e "\033[0m"
                    ;;
                [Hh])
                    echo -e "\033[${color}m"
                    echo "H     H"
                    echo "H     H"
                    echo "HHHHHHH"
                    echo "H     H"
                    echo "H     H"
                    echo -e "\033[0m"
                    ;;
                [Ii])
                    echo -e "\033[${color}m"
                    echo "IIIII"
                    echo "  I  "
                    echo "  I  "
                    echo "  I  "
                    echo "IIIII"
                    echo -e "\033[0m"
                    ;;
                [Jj])
                    echo -e "\033[${color}m"
                    echo "     J"
                    echo "     J"
                    echo "     J"
                    echo "J    J"
                    echo " JJJJ "
                    echo -e "\033[0m"
                    ;;
                [Kk])
                    echo -e "\033[${color}m"
                    echo "K   K"
                    echo "K  K "
                    echo "KKK  "
                    echo "K  K "
                    echo "K   K"
                    echo -e "\033[0m"
                    ;;
                [Ll])
                    echo -e "\033[${color}m"
                    echo "L    "
                    echo "L    "
                    echo "L    "
                    echo "L    "
                    echo "LLLLL"
                    echo -e "\033[0m"
                    ;;
                [Mm])
                    echo -e "\033[${color}m"
                    echo "M     M"
                    echo "MM   MM"
                    echo "M M M M"
                    echo "M  M  M"
                    echo "M     M"
                    echo -e "\033[0m"
                    ;;
                [Nn])
                    echo -e "\033[${color}m"
                    echo "N     N"
                    echo "NN    N"
                    echo "N N   N"
                    echo "N  N  N"
                    echo "N     N"
                    echo -e "\033[0m"
                    ;;
                [Oo])
                    echo -e "\033[${color}m"
                    echo " OOOOO "
                    echo "O     O"
                    echo "O     O"
                    echo "O     O"
                    echo " OOOOO "
                    echo -e "\033[0m"
                    ;;
                [Pp])
                    echo -e "\033[${color}m"
                    echo "PPPPPP "
                    echo "P     P"
                    echo "PPPPPP "
                    echo "P      "
                    echo "P      "
                    echo -e "\033[0m"
                    ;;
                [Qq])
                    echo -e "\033[${color}m"
                    echo " QQQQQ "
                    echo "Q     Q"
                    echo "Q     Q"
                    echo "Q   Q Q"
                    echo " QQQQQ "
                    echo "      Q"
                    echo -e "\033[0m"
                    ;;
                [Rr])
                    echo -e "\033[${color}m"
                    echo "RRRRRR "
                    echo "R     R"
                    echo "RRRRRR "
                    echo "R   R  "
                    echo "R     R"
                    echo -e "\033[0m"
                    ;;
                [Ss])
                    echo -e "\033[${color}m"
                    echo " SSSSS "
                    echo "S     S"
                    echo " SSSSS "
                    echo "      S"
                    echo "S     S"
                    echo " SSSSS "
                    echo -e "\033[0m"
                    ;;
                [Tt])
                    echo -e "\033[${color}m"
                    echo "TTTTTTT"
                    echo "   T   "
                    echo "   T   "
                    echo "   T   "
                    echo "   T   "
                    echo -e "\033[0m"
                    ;;
                [Uu])
                    echo -e "\033[${color}m"
                    echo "U     U"
                    echo "U     U"
                    echo "U     U"
                    echo "U     U"
                    echo " UUUUU "
                    echo -e "\033[0m"
                    ;;
                [Vv])
                    echo -e "\033[${color}m"
                    echo "V     V"
                    echo "V     V"
                    echo "V     V"
                    echo " V   V "
                    echo "  V V  "
                    echo "   V   "
                    echo -e "\033[0m"
                    ;;
                [Ww])
                    echo -e "\033[${color}m"
                    echo "W     W"
                    echo "W     W"
                    echo "W  W  W"
                    echo "W W W W"
                    echo "WW   WW"
                    echo -e "\033[0m"
                    ;;
                [Xx])
                    echo -e "\033[${color}m"
                    echo "X     X"
                    echo " X   X "
                    echo "  X X  "
                    echo " X   X "
                    echo "X     X"
                    echo -e "\033[0m"
                    ;;
                [Yy])
                    echo -e "\033[${color}m"
                    echo "Y     Y"
                    echo " Y   Y "
                    echo "  Y Y  "
                    echo "   Y   "
                    echo "   Y   "
                    echo -e "\033[0m"
                    ;;
                [Zz])
                    echo -e "\033[${color}m"
                    echo "ZZZZZZZ"
                    echo "     Z "
                    echo "   Z   "
                    echo " Z     "
                    echo "ZZZZZZZ"
                    echo -e "\033[0m"
                    ;;
            esac
            ;;
        *)
            # For non-letters, just show the character
            echo -e "\033[${color}m"
            echo "  $letter  "
            echo " $letter$letter$letter "
            echo "$letter$letter$letter$letter$letter"
            echo " $letter$letter$letter "
            echo "  $letter  "
            echo -e "\033[0m"
            ;;
    esac
}

# Color list
colors=(31 32 33 34 35 36 37)

while true; do
    read -n1 key

    if [ "$key" != "" ]; then
        # Random color
        color=${colors[$RANDOM % ${#colors[@]}]}

        # Print big colored letter (no clear screen)
        print_big_letter "$key" "$color"
    fi
done