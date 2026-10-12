#!/bin/bash
#
# toddler.sh - Child-friendly interactive terminal application for learning letters and numbers
# Copyright (c) 2024 Nerd Tower LLC
# Licensed under the MIT License - see LICENSE file for details
#
# Needs bash 5 (associative arrays, fractional read timeouts, EPOCHREALTIME).

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

# Letters and numbers as solid half-block art, rendered from DejaVu Sans Bold.
# '#' is a full block, "'" the top half, ',' the bottom half.
declare -A GLYPHS
GLYPHS[A]="     ,#####,     
     #######     
    #### ####    
   ,###' '###,   
   ###'   '###,  
  #############  
 ####       #### 
,###'       '###,
                 "
GLYPHS[B]="##########,  
####    #### 
####    ####'
####,,,,###' 
####''''####,
####     ####
####    ,####
##########'' 
             "
GLYPHS[C]="   ,,########,
 ,####'    ''#
,####         
####          
####          
'####         
 '####,    ,,#
   ''########'
              "
GLYPHS[D]="##########,,   
####    '####, 
####      '###,
####       ####
####       ####
####      ,###'
####    ,####' 
##########''   
               "
GLYPHS[E]="###########
####       
####       
####,,,,,,,
####'''''''
####       
####       
###########
           "
GLYPHS[F]="###########
####       
####       
####,,,,,,,
####'''''''
####       
####       
####       
           "
GLYPHS[G]="   ,,,#######,,
 ,####'     ''#
,####          
####     ,,,,,,
####     '''###
'####       ###
 '####,    ,###
   ''########''
               "
GLYPHS[H]="####      ####
####      ####
####      ####
####,,,,,,####
####''''''####
####      ####
####      ####
####      ####
              "
GLYPHS[I]="##########
   ####   
   ####   
   ####   
   ####   
   ####   
   ####   
##########
          "
GLYPHS[J]=" ####
 ####
 ####
 ####
 ####
 ####
 ####
 ####
,####"
GLYPHS[K]="####     ,###' 
####   ,###'   
####,,###'     
#######'       
########,      
#### '####,    
####   '####,  
####     '####,
               "
GLYPHS[L]="####       
####       
####       
####       
####       
####       
####       
###########
           "
GLYPHS[M]="#####,      ######
######,    ,######
#######,  ,##'####
#### ### ,### ####
####  ######  ####
####   ####   ####
####   '''    ####
####          ####
                  "
GLYPHS[N]="#####     ####
######,   ####
#######,  ####
#### ###, ####
####  ###,####
####   #######
####    ######
####     '####
              "
GLYPHS[O]="   ,,#######,,   
 ,###''   '####  
,####       #### 
####        ####,
####        ####'
'####       #### 
 '###,,   ,####  
   ''#######''   
                 "
GLYPHS[P]="##########,, 
####    '####
####     ####
####    ,####
##########'' 
####         
####         
####         
             "
GLYPHS[Q]="   ,,#######,,   
 ,###''   '####  
,####       #### 
####        ####,
####        ####'
'####       #### 
 '###,,   ,####' 
   ''#######''   
         '###,   "
GLYPHS[R]="##########,   
####   '####  
####    ####  
####   ,####  
##########,   
####   '####  
####    '#### 
####     '####
              "
GLYPHS[S]=" ,,######## 
###'    ''# 
###,        
#######,,,  
 '''#######,
       '####
#,,    ,####
'########'' 
            "
GLYPHS[T]="###############
     #####     
     #####     
     #####     
     #####     
     #####     
     #####     
     #####     
               "
GLYPHS[U]="####      ####
####      ####
####      ####
####      ####
####      ####
####      ####
'####    #### 
  ''######''  
              "
GLYPHS[V]="'###,       ,###'
 ####,      #### 
  ####     ####  
   ####   ####'  
   '###, ,###'   
    ####,####    
     #######     
     '#####'     
                 "
GLYPHS[W]="####     ####     ,###
####    ,#####    ####
 ####   ###'##   ,###'
 ####  ,##  ###  #### 
  #### ###  ### ,###' 
  ####,##'   #######  
   ######    ######'  
   #####'     #####   
                      "
GLYPHS[X]="'###,     ,###'
 '####   ####' 
   ####,####   
    '#####'    
    ,#####,    
  ,####'####   
 ,###'   '###, 
####'     '###,
               "
GLYPHS[Y]="'####      ####'
 '####,  ,####  
   ####,,####   
    '######'    
     '####'     
      ####      
      ####      
      ####      
                "
GLYPHS[Z]="##############
       ,#####'
      ,#####  
    ,#####'   
   ,#####     
 ,#####'      
,####'        
##############
              "
GLYPHS[0]="  ,,#####,,  
 ####   '### 
,###     ####
####     ####
####     ####
'###     ####
 ####   ,### 
  ''#####''  
             "
GLYPHS[1]=",,######    
 '  ####    
    ####    
    ####    
    ####    
    ####    
    ####    
 ###########
            "
GLYPHS[2]=",,######,, 
#''   '####
       ####
      ,####
     ,###' 
   ,###'   
,####'     
###########
           "
GLYPHS[3]=" ,,######,,  
 ''    '#### 
        #### 
   ,,,,###'  
   ''''####, 
        ####,
 ,     ,#### 
''#######''  
             "
GLYPHS[4]="     ,#####  
    ,######  
  ,### ####  
 ,##'  ####  
###'   ####  
#############
       ####  
       ####  
             "
GLYPHS[5]="########### 
####        
####        
#########,  
''    '####,
        ####
,     ,####'
'#######''  
            "
GLYPHS[6]="   ,,######, 
 ,###'     ' 
 ####,,,,,   
######''#### 
#####    ####
 ####    ####
 '###,  ,###'
   '######'  
             "
GLYPHS[7]="#############
        #### 
       ####' 
      ####'  
     ####'   
    ,###'    
   ,###'     
  ,####      
             "
GLYPHS[8]="  ,#######,, 
 ####   '###,
 ####    ###'
 ''##,,,###' 
 ,###'''###, 
,###     ####
'###,   ,####
  '#######'' 
             "
GLYPHS[9]="  ,,#####,,  
 ###'   ###, 
####    ####,
####    #####
 '###,,,#####
   ''''' ###'
 ,     ,###' 
 ''#####''   
             "

# A big heart; '#' becomes a heart when printed
HEART_ART=" ###   ### 
##### #####
###########
 ######### 
  #######  
   #####   
    ###    
     #     "

# Rainbow order: red, yellow, green, cyan, blue, magenta (bold makes them bright)
rainbow=(31 33 32 36 34 35)
row_number=0

# Seconds between the lines of a row as it glides in: on its own, and while
# keys are held or mashed
GLIDE_DELAY=0.035
GLIDE_DELAY_HELD=0.006

cols=80
update_size() {
    local size
    size=$(stty size 2>/dev/null) && cols=${size#* }
}

# Read one key into KEY, including Enter, space, and backslash. Swallows the
# rest of arrow/function key escape sequences, and watches for the adult
# sequences typed within 2 seconds: z, 9, ! (shift+1) exits, and z, 9, @
# (shift+2) switches between hearts and hacker mode. Never blocks waiting for
# the next key, so z draws like any other letter.
take_key() {
    local now
    IFS= read -rsn1 -d '' "$@" KEY || return 1
    if [ "$KEY" = $'\e' ]; then
        while IFS= read -rsn1 -d '' -t 0.02 _; do :; done
    fi

    now=${EPOCHREALTIME//[.,]/}
    if [ "$last_key" = "9" ] &&
        { [ "$key_before_last" = "z" ] || [ "$key_before_last" = "Z" ]; } &&
        [ $((now - key_before_last_time)) -lt 2000000 ]; then
        if [ "$KEY" = "!" ]; then
            cleanup
        elif [ "$KEY" = "@" ]; then
            last_key=""
            if [ "$mode" = hacker ]; then
                start_mode hearts
            else
                start_mode hacker
            fi
            return 1
        fi
    fi
    key_before_last=$last_key
    key_before_last_time=$last_key_time
    last_key=$KEY
    last_key_time=$now
}

# Scroll in one row of art repeated across the screen, centered, in rainbow
# order. Letters and numbers get a strip of little hearts underneath. With a
# delay, the row glides in a line at a time; a key pressed meanwhile is saved
# in pending and speeds up the rest of the row.
scroll_row() {
    local key="$1" delay="$2"
    local art width cell gap count total pad left right line out i start
    case "$key" in
        [A-Za-z0-9]) art=${GLYPHS[${key^^}]} ;;
        *) art=$HEART_ART ;;
    esac

    # Art is ASCII until it's printed, so lengths and padding are byte-safe
    line=${art%%$'\n'*}
    width=${#line}
    if [ "$art" = "$HEART_ART" ]; then
        cell=$width
        gap=2
    else
        cell=$((width > 16 ? width : 16))
        gap=3
    fi
    count=$(( (cols + gap) / (cell + gap) ))
    if [ $count -lt 1 ]; then
        count=1
    fi
    total=$((count * (cell + gap) - gap))
    printf -v pad '%*s' $(( cols > total ? (cols - total) / 2 : 0 )) ''
    printf -v left '%*s' $(( (cell - width) / 2 )) ''
    printf -v right '%*s' $(( cell - width - (cell - width) / 2 )) ''

    start=$((row_number % ${#rainbow[@]}))
    row_number=$((row_number + 1))

    # Art comes in on fd 3 so take_key below still reads the keyboard
    printf '\n'
    while IFS= read -r -u 3 line; do
        if [ "$art" = "$HEART_ART" ]; then
            line=${line//\#/♥}
        else
            line=${line//\#/█}
            line=${line//\'/▀}
            line=${line//,/▄}
        fi
        out="$pad"
        for ((i=0; i<count; i++)); do
            if [ $i -gt 0 ]; then
                printf -v out '%s%*s' "$out" "$gap" ''
            fi
            out+=$'\e[1;'"${rainbow[(start + i) % ${#rainbow[@]}]}m${left}${line}${right}"
        done
        printf '\n%s\033[0m' "$out"

        if [ -n "$delay" ] && take_key -t "$delay"; then
            pending=$KEY
            delay=$GLIDE_DELAY_HELD
        fi
        if [ "$mode" != hearts ]; then
            return
        fi
    done 3<<< "$art"

    if [ "$art" != "$HEART_ART" ]; then
        out="$pad"
        for ((i=0; i<(total + 1) / 2; i++)); do
            out+=$'\e[1;'"${rainbow[(start + i) % ${#rainbow[@]}]}m♥ "
        done
        printf '\n%s\033[0m\n' "$out"
    else
        printf '\n'
    fi
}

# Hacker mode: every key types the next few characters of a terminal session,
# like the grown-up's screen. When a command is finished its output scrolls
# out, then the next prompt appears. The session loops forever.
#
#   $ cmd          typed by keypresses; the lines after it are its output
#   $! cmd         typed, then really run (harmless, read-only commands only)
#   @SELF n        output is the first n lines of this script
#   @PROGRESS txt  output is a progress bar that fills up by itself
#   {r} {y} {g} {c} {b} {m} {0}   colors in output: red ... magenta, reset
HACKER_CHARS_PER_KEY=3
read -r -d '' HACKER_SESSION <<'EOF'
$ cd ~/code/toddler
$ git status
On branch hearts
Your branch is up to date with 'origin/hearts'.

nothing to commit, working tree clean
$! uname -a
$ cat toddler.sh
@SELF 32
$! df -h
$ ping -c 4 mainframe.local
PING mainframe.local (10.0.0.42) 56(84) bytes of data.
64 bytes from 10.0.0.42: icmp_seq=1 ttl=64 time=0.412 ms
64 bytes from 10.0.0.42: icmp_seq=2 ttl=64 time=0.387 ms
64 bytes from 10.0.0.42: icmp_seq=3 ttl=64 time=0.401 ms
64 bytes from 10.0.0.42: icmp_seq=4 ttl=64 time=0.395 ms

--- mainframe.local ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
$ make hearts
cc -O2 -Wall -c heart.c -o heart.o
cc -O2 -Wall -c rainbow.c -o rainbow.o
cc -O2 -Wall -c sparkle.c -o sparkle.o
cc -o hearts heart.o rainbow.o sparkle.o
$ ./hearts --rainbow
{r}♥ ♥ ♥ {y}♥ ♥ ♥ {g}♥ ♥ ♥ {c}♥ ♥ ♥ {b}♥ ♥ ♥ {m}♥ ♥ ♥{0}
$! free -h
$ ssh mainframe.local
@PROGRESS Hacking the mainframe
{g}ACCESS GRANTED{0}
$! ps -e | head -20
$ clear
EOF

# Turn HACKER_SESSION into steps. PROMPT, SHOW, RUN, PROGRESS and CLEAR run on
# their own; TYPE steps wait for keypresses.
parse_hacker_session() {
    local user host dir="~" line cmd last
    user=$(id -un)
    host=$(hostname 2>/dev/null || uname -n)
    step_kind=()
    step_text=()
    while IFS= read -r line; do
        last=$((${#step_kind[@]} - 1))
        case "$line" in
            '$ '*|'$! '*)
                cmd=${line#\$ }
                cmd=${cmd#\$! }
                step_kind+=(PROMPT TYPE)
                step_text+=($'\e[1;32m'"$user@$host"$'\e[0m:\e[1;34m'"$dir"$'\e[0m$ ' "$cmd")
                if [ "${line:0:2}" = '$!' ]; then
                    step_kind+=(RUN)
                    step_text+=("$cmd")
                elif [ "$cmd" = clear ]; then
                    step_kind+=(CLEAR)
                    step_text+=("")
                fi
                if [ "${cmd:0:3}" = "cd " ]; then
                    dir=${cmd#cd }
                fi
                ;;
            '@SELF '*)
                step_kind+=(SHOW)
                step_text+=("$(head -n "${line#@SELF }" "$0")")
                ;;
            '@PROGRESS '*)
                step_kind+=(PROGRESS)
                step_text+=("${line#@PROGRESS }")
                ;;
            *)
                if [ "${step_kind[last]}" = SHOW ]; then
                    step_text[last]+=$'\n'"$line"
                else
                    step_kind+=(SHOW)
                    step_text+=("$line")
                fi
                ;;
        esac
    done <<< "$HACKER_SESSION"
    step=0
    typed=0
}

# Print command output a line at a time, quickly, so it scrolls like a real one
show_output() {
    local line
    while IFS= read -r -u 3 line; do
        line=${line//\{r\}/$'\e[1;31m'}
        line=${line//\{y\}/$'\e[1;33m'}
        line=${line//\{g\}/$'\e[1;32m'}
        line=${line//\{c\}/$'\e[1;36m'}
        line=${line//\{b\}/$'\e[1;34m'}
        line=${line//\{m\}/$'\e[1;35m'}
        line=${line//\{0\}/$'\e[0m'}
        printf '%s\033[0m\n' "$line"
        if take_key -t 0.012; then
            pending=$KEY
        fi
        if [ "$mode" != hacker ]; then
            return
        fi
    done 3<<< "$1"
}

# Run steps until the next one that needs typing
run_hacker_steps() {
    local i
    while [ "$mode" = hacker ]; do
        case "${step_kind[step]}" in
            TYPE) return ;;
            PROMPT) printf '%s' "${step_text[step]}" ;;
            SHOW) show_output "${step_text[step]}" ;;
            RUN) show_output "$(bash -c "${step_text[step]}" 2>&1 | head -n 30)" ;;
            CLEAR) printf '\033[2J\033[H' ;;
            PROGRESS)
                printf '%s [' "${step_text[step]}"
                for ((i=0; i<30; i++)); do
                    printf '\033[1;32m#\033[0m'
                    if take_key -t 0.04; then
                        pending=$KEY
                    fi
                done
                printf '] 100%%\n'
                ;;
        esac
        step=$(( (step + 1) % ${#step_kind[@]} ))
    done
}

# One keypress in hacker mode: type a few more characters, or with Enter
# finish the command. A finished command runs its output and the next prompt.
hacker_key() {
    local key="$1" count=$HACKER_CHARS_PER_KEY text
    if [ "$key" = $'\n' ] || [ "$key" = $'\r' ]; then
        count=1000
    fi
    text=${step_text[step]}
    printf '%s' "${text:typed:count}"
    typed=$((typed + count))
    if [ $typed -ge ${#text} ]; then
        printf '\n'
        typed=0
        step=$(( (step + 1) % ${#step_kind[@]} ))
        run_hacker_steps
    fi
}

# Switch modes: hearts hides the cursor, hacker shows it like a real terminal
start_mode() {
    mode=$1
    pending=""
    printf '\033[2J\033[H'
    if [ "$mode" = hacker ]; then
        printf '\033[?25h'
        parse_hacker_session
        run_hacker_steps
    else
        printf '\033[?25l'
    fi
}

# Parse command line arguments
mode=hearts
case "${1:-}" in
    "") ;;
    --hacker) mode=hacker ;;
    test)
        # Test mode: print one row and quit
        update_size
        scroll_row "${2:-A}" ""
        exit 0
        ;;
    *)
        echo "Usage: $0 [--hacker | test [CHARACTER]]"
        echo "  --hacker: Start in hacker mode (every key types a pretend terminal session)"
        echo "  test [CHARACTER]: Test mode - print one row of a character and exit"
        exit 1
        ;;
esac

# Child-proof the terminal: no echo, no line buffering, and no special keys.
# -isig makes Ctrl+C/Ctrl+Z/Ctrl+\ plain keypresses, -ixon stops Ctrl+S from
# freezing the screen, -iexten disables Ctrl+V and Ctrl+O.
saved_stty=$(stty -g)
trap restore_terminal EXIT
trap '' INT TERM TSTP TTIN TTOU QUIT
trap update_size WINCH
stty -echo -icanon -isig -ixon -iexten min 1 time 0
update_size
start_mode "$mode"

while true; do
    if [ -n "$pending" ]; then
        key=$pending
        pending=""
        delay=$GLIDE_DELAY_HELD
    else
        take_key || continue
        key=$KEY
        delay=$GLIDE_DELAY
    fi

    if [ "$mode" = hacker ]; then
        hacker_key "$key"
    else
        scroll_row "$key" "$delay"
    fi

    # Keep only the newest key mashed while drawing so the screen never lags
    while read -t 0; do
        if take_key; then
            pending=$KEY
        fi
    done
done
