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
    printf '\033[0m\033(B\033[?25h'
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
# out, then the next prompt appears. The screen is a pretend tmux: the session
# on the left, a pretend htop on the right, and a green status bar. It is all
# drawn here; no real tmux runs.
#
# The session is made of chapters separated by "---". The first chapter always
# comes first and the last one last; the rest are shuffled on every loop.
#
#   $ cmd          typed by keypresses; the lines after it are its output
#   $! cmd         typed, then really run (harmless, read-only commands only)
#   @SELF n        output is the first n lines of this script
#   @ART name c    one of the ASCII art pictures below, in color c (31-37)
#   @KITTYSAY txt  a kitty with a speech bubble
#   @AQUARIUM n    n lines of fish swimming
#   @PROGRESS txt  a progress bar that fills up by itself
#   @DOWNLOAD a b  one progress bar per file, filling at different speeds
#   @HEXDUMP n     n lines of hex dump
#   @CRACK WORD    big letters spin through random ones and lock into WORD
#   @BANNER WORD   WORD in big green letters (one word per @BANNER)
#   @TRAIN         a choo-choo train drives across
#   @NYAN          a kitty flies across with a rainbow behind it
#   @ROCKET        a 3, 2, 1 countdown and a rocket that blasts off the top
#   @MATRIX s      green characters rain down for s seconds
#   @ZOOM/@UNZOOM  the left pane fills the screen, like tmux zoom, and back
#   {r} {y} {g} {c} {b} {m} {0}   colors in output: red ... magenta, reset
HACKER_CHARS_PER_KEY=3
IFS= read -r -d '' HACKER_SESSION <<'EOF'
$ cd ~/code/toddler
$ git status
On branch hearts
Your branch is up to date with 'origin/hearts'.

nothing to commit, working tree clean
---
$! uname -a
$! df -h
---
$ cat toddler.sh
@SELF 32
---
$ ping -c 4 mainframe.local
PING mainframe.local (10.0.0.42) 56(84) bytes of data.
64 bytes from 10.0.0.42: icmp_seq=1 ttl=64 time=0.412 ms
64 bytes from 10.0.0.42: icmp_seq=2 ttl=64 time=0.387 ms
64 bytes from 10.0.0.42: icmp_seq=3 ttl=64 time=0.401 ms
64 bytes from 10.0.0.42: icmp_seq=4 ttl=64 time=0.395 ms

--- mainframe.local ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
---
$ ping -c 3 kitty.local
PING kitty.local (10.0.0.9) 56(84) bytes of data.
64 bytes from kitty.local: {m}meow!{0} time=0.3 ms
64 bytes from kitty.local: {m}meow meow!{0} time=0.4 ms
64 bytes from kitty.local: {m}purrrrrrr{0} time=0.2 ms
---
$ make hearts
cc -O2 -Wall -c heart.c -o heart.o
cc -O2 -Wall -c rainbow.c -o rainbow.o
cc -O2 -Wall -c sparkle.c -o sparkle.o
cc -o hearts heart.o rainbow.o sparkle.o
$ ./hearts --rainbow
{r}♥ ♥ ♥ {y}♥ ♥ ♥ {g}♥ ♥ ♥ {c}♥ ♥ ♥ {b}♥ ♥ ♥ {m}♥ ♥ ♥{0}
---
$ curl -O mainframe.local/files/{hearts.db,rainbows.tar.gz,kittens.zip,stars.iso}
@DOWNLOAD hearts.db rainbows.tar.gz kittens.zip stars.iso
---
$ xxd secret.bin
@HEXDUMP 24
---
$! free -h
$! ps -e | head -20
---
$ cat kitty.txt
@ART KITTY 35
$ ./kittysay meow
@KITTYSAY meow! meow! I love you!
---
$ ls pets/
{c}duck.txt{0}  {c}fish.txt{0}  {c}kitty.txt{0}  {c}puppy.txt{0}
$ cat pets/puppy.txt
@ART PUPPY 33
$ cat pets/duck.txt
@ART DUCK 33
---
$ ./aquarium
@AQUARIUM 10
---
$ sl
@TRAIN
---
$ ./nyancat
@ZOOM
@NYAN
@UNZOOM
---
$ ./launch --rocket
@ROCKET
---
@ZOOM
$ ./crack --target mainframe.local
@CRACK HEARTS
{g}Password found!{0}
$ ssh mainframe.local
@PROGRESS Hacking the mainframe
@BANNER ACCESS
@BANNER GRANTED
$ clear
@UNZOOM
---
@ZOOM
$ matrix
@MATRIX 4
@UNZOOM
---
$ clear
EOF

IFS= read -r -d '' ART_KITTY <<'EOF'
    /\_____/\
   /  o   o  \
  ( ==  ^  == )
   )         (
  (           )
 ( (  )   (  ) )
(__(__)___(__)__)
EOF

IFS= read -r -d '' ART_PUPPY <<'EOF'
    __
 o-''|\_____/)
  \_/|_)     )
     \  __  /
     (_/ (_/
EOF

IFS= read -r -d '' ART_DUCK <<'EOF'
    __
___( o)>
\ <_. )
 `---'
EOF

IFS= read -r -d '' ART_TRAIN <<'EOF'
         (@@) (  ) (@)  ( )
      (  )
    ___
 ___| |____________    ______________    ______________
|           |  _  |====|  []  []  [] |====|  []  []  [] |
| CHOO CHOO |_| |_|    |             |    |             |
|_________________|====|_____________|====|_____________|
  (O)  (O)   (O)        (O)       (O)      (O)       (O)
EOF

IFS= read -r -d '' ART_NYAN <<'EOF'
,------,
|   /\_/\
|__( ^ .^)
 ""  ""
EOF

IFS= read -r -d '' ART_ROCKET <<'EOF'
    /\
   /  \
  |    |
  | <3 |
  |    |
 /|    |\
/_|____|_\
   /__\
EOF

# ---- Panes: the left pane keeps its own lines and redraws itself when it
# scrolls. P_RAW holds each line as printed, P_FIT the same line cut to the
# pane width, and P_VIS how many columns P_FIT takes up.

LW=80        # left pane width
RW=0         # right pane width; 0 means no right pane
PANE_H=23    # pane height: screen rows minus the status bar
zoomed=0

layout_panes() {
    local size rows
    size=$(stty size 2>/dev/null)
    rows=${size% *}
    PANE_H=$(( ${rows:-24} - 1 ))
    if [ $zoomed -eq 0 ] && [ "$cols" -ge 100 ]; then
        LW=$((cols * 3 / 5))
        RW=$((cols - LW - 1))
    else
        LW=$cols
        RW=0
    fi
}

# Set FIT to text cut to max columns, skipping color codes, and FITV to its width
fit_text() {
    local text="$1" max="$2" out="" vis=0 i=0 ch esc
    if [[ $text != *$'\e'* ]]; then
        FIT=${text:0:max}
        FITV=${#FIT}
        return
    fi
    while [ $i -lt ${#text} ]; do
        ch=${text:i:1}
        if [ "$ch" = $'\e' ]; then
            esc=${text:i}
            esc=${esc%%m*}m
            out+=$esc
            i=$((i + ${#esc}))
        elif [ $vis -lt "$max" ]; then
            out+=$ch
            vis=$((vis + 1))
            i=$((i + 1))
        else
            break
        fi
    done
    FIT=$out$'\e[0m'
    FITV=$vis
}

pane_fit() {
    fit_text "${P_RAW[$1]}" "$LW"
    P_FIT[$1]=$FIT
    P_VIS[$1]=$FITV
}

pane_draw_line() {
    printf '\033[%d;1H%s\033[0m%*s' $(($1 + 1)) "${P_FIT[$1]}" $((LW - P_VIS[$1])) ''
}

# Redraw the whole left pane and the divider next to it
pane_draw_all() {
    local i out=""
    for ((i=0; i<PANE_H; i++)); do
        printf -v out '%s\033[%d;1H%s\033[0m%*s' "$out" $((i + 1)) "${P_FIT[i]}" $((LW - ${P_VIS[i]:-0})) ''
        if [ $RW -gt 0 ]; then
            out+=$'\e[32m\e(0x\e(B\e[0m'
        fi
    done
    printf '%s' "$out"
}

# Put the cursor at the end of the left pane's last line
pane_cursor() {
    local last=$(( ${#P_RAW[@]} - 1 )) col
    col=$((P_VIS[last] + 1))
    if [ $col -gt $LW ]; then
        col=$LW
    fi
    printf '\033[%d;%dH' $((last + 1)) "$col"
}

pane_newline() {
    P_RAW+=("")
    P_FIT+=("")
    P_VIS+=(0)
    if [ ${#P_RAW[@]} -gt $PANE_H ]; then
        P_RAW=("${P_RAW[@]:1}")
        P_FIT=("${P_FIT[@]:1}")
        P_VIS=("${P_VIS[@]:1}")
        pane_draw_all
    fi
}

# Add text to the end of the last line
pane_add() {
    local last=$(( ${#P_RAW[@]} - 1 ))
    P_RAW[last]+=$1
    pane_fit $last
    pane_draw_line $last
}

# Type plain text onto the last line, wrapping at the pane edge
pane_type() {
    local text="$1" last space
    while [ -n "$text" ]; do
        last=$(( ${#P_RAW[@]} - 1 ))
        space=$((LW - P_VIS[last]))
        if [ $space -le 0 ]; then
            pane_newline
            continue
        fi
        pane_add "${text:0:space}"
        text=${text:space}
    done
    pane_cursor
}

# Print a whole line, like echo
pane_print() {
    pane_add "$1"
    pane_newline
}

# Replace the line k lines above the cursor's line
pane_set() {
    local idx=$(( ${#P_RAW[@]} - 1 - $1 ))
    P_RAW[idx]=$2
    pane_fit $idx
    pane_draw_line $idx
}

pane_clear() {
    P_RAW=("")
    P_FIT=("")
    P_VIS=(0)
    pane_draw_all
    pane_cursor
}

# Lay the screen out again (after a zoom or on entering hacker mode)
pane_relayout() {
    local i
    layout_panes
    for ((i=0; i<${#P_RAW[@]}; i++)); do
        pane_fit $i
    done
    while [ ${#P_RAW[@]} -gt $PANE_H ]; do
        P_RAW=("${P_RAW[@]:1}")
        P_FIT=("${P_FIT[@]:1}")
        P_VIS=("${P_VIS[@]:1}")
    done
    printf '\033[2J'
    pane_draw_all
    last_tick=0
    htop_tick
}

# ---- The pretend htop in the right pane, and the status bar. Keypresses make
# the CPU bars jump.

cpu=(12 30 8 21)
proc_names=(hack-the-planet hearts rainbowd kittyd purr-server toddler.sh
    mainframe-link sparkle nyand sshd bash systemd)
proc_cpu=(870 412 233 190 120 88 61 40 22 9 4 1)
proc_pid=(4242 1337 2718 3141 1618 2024 8080 1234 4040 812 1001 1)
last_tick=0

htop_bump() {
    local i=$((RANDOM % 4))
    cpu[i]=$(( cpu[i] + 20 + RANDOM % 30 ))
    if [ "${cpu[i]}" -gt 100 ]; then
        cpu[i]=100
    fi
}

# Draw a meter line: label, a bar of '|' in two colors, and text at the right
htop_meter() {
    local label="$1" pct="$2" text="$3" inner bar fill green
    inner=$((RW - 7 - ${#text}))
    fill=$((inner * pct / 100))
    green=$((fill * 3 / 4))
    printf -v bar '%*s' "$fill" ''
    bar=${bar// /|}
    printf -v HTOP_LINE '\033[1;36m%4s\033[0m[\033[1;32m%s\033[1;31m%s\033[0m%*s%s]' \
        "$label" "${bar:0:green}" "${bar:green}" $((inner - fill + 1)) '' "$text"
}

htop_tick() {
    local now=${EPOCHREALTIME//[.,]/} i x out="" row clock left right mem up
    if [ $((now - last_tick)) -lt 200000 ]; then
        return
    fi
    last_tick=$now

    if [ $RW -gt 0 ]; then
        x=$((LW + 2))
        # CPU bars wander around 20% and settle back after keypresses
        for ((i=0; i<4; i++)); do
            cpu[i]=$(( cpu[i] + RANDOM % 15 - 7 - (cpu[i] - 20) / 6 ))
            if [ "${cpu[i]}" -lt 2 ]; then
                cpu[i]=2
            fi
        done
        for ((i=0; i<${#proc_cpu[@]}; i++)); do
            proc_cpu[i]=$(( proc_cpu[i] + RANDOM % 41 - 20 ))
            if [ "${proc_cpu[i]}" -lt 0 ]; then
                proc_cpu[i]=0
            fi
        done
        row=1
        for ((i=0; i<4; i++)); do
            htop_meter "$((i + 1))" "${cpu[i]}" "$(printf '%5.1f%%' "${cpu[i]}")"
            out+=$'\e['"$row;${x}H$HTOP_LINE"
            row=$((row + 1))
        done
        mem=$((30 + (cpu[0] + cpu[1]) / 8))
        htop_meter Mem "$mem" "$((mem * 77 / 100 / 10)).$((mem * 77 / 100 % 10))G/7.7G"
        out+=$'\e['"$row;${x}H$HTOP_LINE"
        row=$((row + 1))
        htop_meter Swp 0 "0K/2.0G"
        out+=$'\e['"$row;${x}H$HTOP_LINE"
        row=$((row + 2))
        printf -v left '  Tasks: \033[1;36m%d\033[0m, 97 thr; \033[1;32m%d\033[0m running' \
            $((40 + RANDOM % 5)) $((1 + RANDOM % 4))
        out+=$'\e['"$row;${x}H$left"
        row=$((row + 1))
        printf -v left '  Load average: \033[1;36m%d.%02d %d.%02d %d.%02d\033[0m' \
            $((cpu[0] / 50)) $((RANDOM % 100)) 0 $((RANDOM % 100)) 0 $((RANDOM % 100))
        out+=$'\e['"$row;${x}H$left"
        row=$((row + 1))
        up=$SECONDS
        if read -r up _ < /proc/uptime 2>/dev/null; then
            up=${up%.*}
        fi
        left="  Uptime: "$'\e[1;36m'
        if [ "$up" -ge 86400 ]; then
            left+="$((up / 86400)) days, "
        fi
        printf -v left '%s%02d:%02d:%02d\033[0m' "$left" \
            $((up / 3600 % 24)) $((up / 60 % 60)) $((up % 60))
        out+=$'\e['"$row;${x}H$left"
        row=$((row + 2))
        printf -v left '%-*s' "$RW" '    PID USER      CPU%  Command'
        out+=$'\e['"$row;${x}H"$'\e[30;42m'"$left"$'\e[0m'
        row=$((row + 1))
        for ((i=0; i<${#proc_names[@]} && row<=PANE_H; i++)); do
            printf -v left '%7d %-8s %3d.%d  %s' "${proc_pid[i]}" toddler \
                $((proc_cpu[i] / 10)) $((proc_cpu[i] % 10)) "${proc_names[i]}"
            left=${left:0:RW}
            printf -v left '%-*s' "$RW" "$left"
            if [ $i -eq 0 ]; then
                left=$'\e[30;46m'"$left"$'\e[0m'
            fi
            out+=$'\e['"$row;${x}H$left"
            row=$((row + 1))
        done
        # Clear the meter and text rows' leftovers by padding each to the pane edge
        out+=$'\e[0m'
    fi

    # Status bar
    printf -v clock '%(%H:%M %d-%b-%y)T' -1
    left=" [hack] 0:bash*"
    if [ $zoomed -eq 1 ]; then
        left+="Z"
    fi
    right="\"$host\" $clock "
    printf -v out '%s\033[%d;1H\033[30;42m%s%*s%s\033[0m' "$out" $((PANE_H + 1)) \
        "$left" $((cols - ${#left} - ${#right})) '' "$right"
    printf '\033[?25l%s' "$out"
    pane_cursor
    printf '\033[?25h'
}

# ---- Session

# Turn HACKER_SESSION into steps, with the middle chapters shuffled. TYPE steps
# wait for keypresses; every other step runs on its own.
parse_hacker_session() {
    local dir="~" line cmd last chapter i j tmp session=""
    local -a chapters=()
    user=$(id -un)
    host=$(hostname 2>/dev/null || uname -n)

    chapter=""
    while IFS= read -r line; do
        if [ "$line" = "---" ]; then
            chapters+=("$chapter")
            chapter=""
        else
            chapter+="$line"$'\n'
        fi
    done <<< "$HACKER_SESSION"
    chapters+=("$chapter")
    for ((i=${#chapters[@]} - 2; i>1; i--)); do
        j=$((1 + RANDOM % i))
        tmp=${chapters[i]}
        chapters[i]=${chapters[j]}
        chapters[j]=$tmp
    done
    for chapter in "${chapters[@]}"; do
        session+=$chapter
    done

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
            '@'*)
                step_kind+=("${line%% *}")
                step_text+=("${line#* }")
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
    done <<< "${session%$'\n'}"
    step=0
    typed=0
}

# Wait between animation frames. A keypress ends the wait early, is kept in
# pending, and makes the CPU bars jump. Returns 1 if the adult switched modes.
hacker_pause() {
    if take_key -t "$1"; then
        pending=$KEY
        htop_bump
    fi
    [ "$mode" = hacker ] || return 1
    htop_tick
}

# Print output a line at a time, quickly, so it scrolls like a real one
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
        pane_print "$line"
        hacker_pause 0.012 || return
    done 3<<< "$1"
    pane_cursor
}

# Print art centered in the left pane, in one color
show_art() {
    local art="$1" color="$2" line width=0 pad out=""
    while IFS= read -r line; do
        if [ ${#line} -gt $width ]; then
            width=${#line}
        fi
    done <<< "$art"
    printf -v pad '%*s' $(( LW > width ? (LW - width) / 2 : 0 )) ''
    while IFS= read -r line; do
        out+="$pad"$'\e[1;'"${color}m$line"$'\e[0m\n'
    done <<< "${art%$'\n'}"
    show_output "${out%$'\n'}"
}

# Set BIG_LINES to WORD drawn with the solid glyphs, one cell per letter of
# width cell (0 means each letter's own width), centered in the left pane.
# Letter colors come from the array named by the second argument, cycling if
# short. Returns 1 if the word doesn't fit.
big_word() {
    local word="$1" cell="$3"
    local -n big_colors="$2"
    local i r ch glyph line width total=0 pad lines=()
    local -a rows
    for ((i=0; i<${#word}; i++)); do
        ch=${word:i:1}
        glyph=${GLYPHS[$ch]}
        line=${glyph%%$'\n'*}
        width=${#line}
        if [ "$cell" -gt 0 ]; then
            width=$cell
        fi
        total=$((total + width + (i > 0 ? 2 : 0)))
    done
    if [ $total -gt "$LW" ]; then
        return 1
    fi
    printf -v pad '%*s' $(( (LW - total) / 2 )) ''
    for ((r=0; r<9; r++)); do
        rows[r]="$pad"
    done
    for ((i=0; i<${#word}; i++)); do
        ch=${word:i:1}
        glyph=${GLYPHS[$ch]}
        mapfile -t lines <<< "$glyph"
        line=${lines[0]}
        width=${#line}
        for ((r=0; r<9; r++)); do
            line=${lines[r]}
            if [ "$cell" -gt 0 ]; then
                printf -v line '%*s%s%*s' $(( (cell - width) / 2 )) '' "$line" \
                    $(( cell - width - (cell - width) / 2 )) ''
            fi
            line=${line//\#/█}
            line=${line//\'/▀}
            line=${line//,/▄}
            if [ $i -gt 0 ]; then
                rows[r]+="  "
            fi
            rows[r]+=$'\e[1;'"${big_colors[i % ${#big_colors[@]}]}m${line}"$'\e[0m'
        done
    done
    BIG_LINES=("${rows[@]}")
}

# Make room for an animation n lines tall at the bottom of the left pane
pane_reserve() {
    local i
    for ((i=0; i<$1; i++)); do
        pane_newline
    done
}

# A progress bar that fills up by itself
effect_progress() {
    local text="$1" width i done_chars bar
    width=$((LW - ${#text} - 10))
    if [ $width -lt 10 ]; then
        width=10
    fi
    for ((i=0; i<=100; i+=2)); do
        done_chars=$((width * i / 100))
        printf -v bar '%*s' "$done_chars" ''
        bar=${bar// /#}
        printf -v bar '%s [\033[1;32m%s\033[0m%*s] %3d%%' "$text" "$bar" $((width - done_chars)) '' "$i"
        pane_set 0 "$bar"
        hacker_pause 0.03 || return
    done
    pane_newline
}

# One progress bar per file, each filling at its own speed
effect_download() {
    local -a names pct=()
    local i n width done_chars all_done bar speed line
    read -ra names <<< "$1"
    n=${#names[@]}
    width=$((LW - 44))
    if [ $width -lt 10 ]; then
        width=10
    fi
    for ((i=0; i<n; i++)); do
        pct[i]=0
    done
    pane_reserve "$n"
    while true; do
        all_done=1
        for ((i=0; i<n; i++)); do
            if [ "${pct[i]}" -lt 100 ]; then
                pct[i]=$(( pct[i] + 1 + RANDOM % 6 ))
                if [ "${pct[i]}" -gt 100 ]; then
                    pct[i]=100
                fi
                all_done=0
            fi
            done_chars=$((width * pct[i] / 100))
            printf -v bar '%*s' "$done_chars" ''
            bar=${bar// /=}
            if [ "${pct[i]}" -lt 100 ]; then
                bar+=">"
                speed="$((1 + RANDOM % 9)).$((RANDOM % 10)) MB/s"
            else
                bar+="="
                speed="done"
            fi
            printf -v line '%-18s [\033[1;36m%-*s\033[0m] %3d%%  %s' \
                "${names[i]}" $((width + 1)) "$bar" "${pct[i]}" "$speed"
            pane_set $((n - i)) "$line"
        done
        if [ $all_done -eq 1 ]; then
            break
        fi
        hacker_pause 0.05 || return
    done
    pane_cursor
}

# Hex dump of random bytes, as wide as the pane allows
effect_hexdump() {
    local count="$1" per_line i j byte hex ascii out=""
    per_line=$(( (LW - 12) / 4 / 4 * 4 ))
    if [ $per_line -lt 4 ]; then
        per_line=4
    fi
    for ((i=0; i<count; i++)); do
        hex=""
        ascii=""
        for ((j=0; j<per_line; j++)); do
            byte=$((RANDOM % 256))
            printf -v hex '%s%02x ' "$hex" "$byte"
            if [ $byte -ge 33 ] && [ $byte -le 126 ]; then
                printf -v ascii "%s\\x$(printf '%x' "$byte")" "$ascii"
            else
                ascii+="."
            fi
        done
        printf -v out '%s{c}%08x{0}: %s {y}%s{0}\n' "$out" $((i * per_line)) "$hex" "$ascii"
    done
    show_output "${out%$'\n'}"
}

# Big letters spin through random ones and lock into the word one at a time
effect_crack() {
    local word="$1" letters="ABCDEFGHIJKLMNOPQRSTUVXYZ0123456789"
    local locked=0 frame=0 i shown r
    local -a colors_now
    pane_reserve 9
    while [ $locked -le ${#word} ]; do
        shown=""
        colors_now=()
        for ((i=0; i<${#word}; i++)); do
            if [ $i -lt $locked ]; then
                shown+=${word:i:1}
                colors_now[i]=32
            else
                shown+=${letters:RANDOM % ${#letters}:1}
                colors_now[i]=37
            fi
        done
        if ! big_word "$shown" colors_now 18; then
            break
        fi
        for ((r=0; r<9; r++)); do
            pane_set $((9 - r)) "${BIG_LINES[r]}"
        done
        frame=$((frame + 1))
        if [ $((frame % 6)) -eq 0 ]; then
            locked=$((locked + 1))
        fi
        hacker_pause 0.05 || return
    done
    pane_cursor
}

# A word in big green letters, scrolled in like output
effect_banner() {
    local -a green=(32)
    if big_word "$1" green 0; then
        show_output "$(printf '%s\n' "${BIG_LINES[@]}")"
    else
        show_output "{g}$1{0}"
    fi
}

# A kitty saying something, in a speech bubble
effect_kittysay() {
    local text="$1" top under
    printf -v top '%*s' $((${#text} + 2)) ''
    under=${top// /-}
    top=${top// /_}
    show_output " $top
< {y}$text{0} >
 $under"'
    \
     \  {m}/\_/\{0}
        {m}( o.o ){0}
         {m}> ^ <{0}'
}

# Fish swimming around, facing both ways, with bubbles
effect_aquarium() {
    local count="$1" i out="" fish pad
    local -a kinds=("><((('>" "<')))><" "><>" "<><" "><(('>" "<'))><")
    local -a fish_colors=(31 33 32 36 34 35)
    for ((i=0; i<count; i++)); do
        fish=${kinds[RANDOM % ${#kinds[@]}]}
        printf -v pad '%*s' $((RANDOM % (LW > 12 ? LW - 10 : 2))) ''
        if [ $((RANDOM % 3)) -eq 0 ]; then
            out+="$pad{c}o{0}"$'\n'
        else
            out+="$pad"$'\e[1;'"${fish_colors[RANDOM % 6]}m$fish{0}"$'\n'
        fi
    done
    out+="{b}"
    printf -v pad '%*s' $((LW < 60 ? LW : 60)) ''
    out+="${pad// /\~}{0}"
    show_output "$out"
}

# Slide art across the left pane: dir 1 moves right, -1 moves left. With a
# trail, colored stripes stretch behind it (the flying kitty's rainbow).
slide_art() {
    local art="$1" dir="$2" trail="$3" color="$4"
    local -a lines stripes=(31 33 32 34)
    local n width=0 x end r line shown stripe
    mapfile -t lines <<< "${art%$'\n'}"
    n=${#lines[@]}
    for line in "${lines[@]}"; do
        if [ ${#line} -gt $width ]; then
            width=${#line}
        fi
    done
    pane_reserve "$n"
    if [ "$dir" -gt 0 ]; then
        x=$((-width))
        end=$LW
    else
        x=$LW
        end=$((-width))
    fi
    while [ $(( (end - x) * dir )) -gt 0 ]; do
        for ((r=0; r<n; r++)); do
            printf -v line '%-*s' "$width" "${lines[r]}"
            if [ $x -ge 0 ]; then
                printf -v shown '%*s%s' "$x" '' "$line"
            else
                shown=${line:$((-x))}
            fi
            shown=${shown:0:LW}
            if [ -n "$trail" ] && [ $x -gt 0 ]; then
                printf -v stripe '%*s' "$x" ''
                stripe=${stripe// /=}
                stripe=${stripe:0:LW}
                shown=$'\e[1;'"${stripes[r % ${#stripes[@]}]}m$stripe"$'\e[1;37m'"${shown:x}"
            else
                shown=$'\e[1;'"${color}m$shown"
            fi
            pane_set $((n - r)) "$shown"
        done
        x=$((x + 2 * dir))
        hacker_pause 0.03 || return
    done
    pane_cursor
}

effect_train() {
    slide_art "$ART_TRAIN" -1 "" 33
}

effect_nyan() {
    slide_art "$ART_NYAN" 1 trail 37
}

# Countdown in big numbers, then a rocket that blasts off the top of the pane
effect_rocket() {
    local -a white=(37) flames=("  (  )  " " ( )( ) " "  )  (  " " (  )(  " "   ()   " "    .   ")
    local i r pad flame color
    pane_reserve 9
    for i in 3 2 1; do
        big_word "$i" white 0 || break
        for ((r=0; r<9; r++)); do
            pane_set $((9 - r)) "${BIG_LINES[r]}"
        done
        hacker_pause 0.5 || return
        hacker_pause 0.3 || return
    done
    show_output "{y}LIFTOFF!{0}"
    show_art "$ART_ROCKET" 37
    printf -v pad '%*s' $(( LW > 9 ? (LW - 9) / 2 : 0 )) ''
    for ((i=0; i<PANE_H; i++)); do
        if [ $i -lt 10 ]; then
            flame=${flames[RANDOM % 4]}
            color=$((RANDOM % 2 ? 31 : 33))
            pane_print "$pad"$'\e[1;'"${color}m$flame"
        elif [ $((RANDOM % 4)) -eq 0 ]; then
            printf -v flame '%*s' $((RANDOM % LW)) ''
            pane_print "$flame"$'\e[1;37m*'
        else
            pane_print ""
        fi
        hacker_pause 0.05 || return
    done
    pane_cursor
}

# Green characters rain down the left pane
effect_matrix() {
    local seconds="$1" chars="0123456789ABCDEFabcdef#$%&*+=<>"
    local frames f c out
    local -a drop tail
    for ((c=1; c<=LW; c++)); do
        drop[c]=$(( -(RANDOM % PANE_H) ))
        tail[c]=$((6 + RANDOM % 14))
    done
    frames=$(( seconds * 25 ))
    pane_clear
    printf '\033[?25l'
    for ((f=0; f<frames; f++)); do
        out=""
        for ((c=1; c<=LW; c+=2)); do
            drop[c]=$((drop[c] + 1))
            if [ "${drop[c]}" -ge 1 ] && [ "${drop[c]}" -le "$PANE_H" ]; then
                out+=$'\e['"${drop[c]};${c}H"$'\e[1;37m'"${chars:RANDOM % ${#chars}:1}"
            fi
            if [ $((drop[c] - 1)) -ge 1 ] && [ $((drop[c] - 1)) -le "$PANE_H" ]; then
                out+=$'\e['"$((drop[c] - 1));${c}H"$'\e[1;32m'"${chars:RANDOM % ${#chars}:1}"
            fi
            if [ $((drop[c] - tail[c])) -ge 1 ] && [ $((drop[c] - tail[c])) -le "$PANE_H" ]; then
                out+=$'\e['"$((drop[c] - tail[c]));${c}H "
            fi
            if [ $((drop[c] - tail[c])) -gt "$PANE_H" ]; then
                drop[c]=$(( -(RANDOM % 10) ))
                tail[c]=$((6 + RANDOM % 14))
            fi
        done
        printf '%s\033[0m' "$out"
        hacker_pause 0.04 || break
    done
    printf '\033[?25h'
    pane_clear
}

# Run steps until the next one that needs typing. At the end of the session,
# shuffle a new one and keep going.
run_hacker_steps() {
    local art_name
    while [ "$mode" = hacker ]; do
        case "${step_kind[step]}" in
            TYPE) return ;;
            PROMPT) pane_add "${step_text[step]}" ;;
            SHOW) show_output "${step_text[step]}" ;;
            RUN) show_output "$(bash -c "${step_text[step]}" 2>&1 | head -n 30)" ;;
            CLEAR) pane_clear ;;
            @ART)
                art_name="ART_${step_text[step]%% *}"
                show_art "${!art_name}" "${step_text[step]#* }"
                ;;
            @KITTYSAY) effect_kittysay "${step_text[step]}" ;;
            @AQUARIUM) effect_aquarium "${step_text[step]}" ;;
            @PROGRESS) effect_progress "${step_text[step]}" ;;
            @DOWNLOAD) effect_download "${step_text[step]}" ;;
            @HEXDUMP) effect_hexdump "${step_text[step]}" ;;
            @CRACK) effect_crack "${step_text[step]}" ;;
            @BANNER) effect_banner "${step_text[step]}" ;;
            @TRAIN) effect_train ;;
            @NYAN) effect_nyan ;;
            @ROCKET) effect_rocket ;;
            @MATRIX) effect_matrix "${step_text[step]}" ;;
            @ZOOM) zoomed=1; pane_relayout ;;
            @UNZOOM) zoomed=0; pane_relayout ;;
        esac
        step=$((step + 1))
        if [ $step -ge ${#step_kind[@]} ]; then
            parse_hacker_session
        fi
    done
}

# One keypress in hacker mode: type a few more characters, or with Enter
# finish the command. A finished command runs its output and the next prompt.
hacker_key() {
    local key="$1" count=$HACKER_CHARS_PER_KEY text
    if [ "$key" = $'\n' ] || [ "$key" = $'\r' ]; then
        count=1000
    fi
    htop_bump
    text=${step_text[step]}
    pane_type "${text:typed:count}"
    typed=$((typed + count))
    if [ $typed -ge ${#text} ]; then
        pane_newline
        typed=0
        step=$((step + 1))
        run_hacker_steps
    fi
    htop_tick
}

# Switch modes: hearts hides the cursor, hacker shows it like a real terminal
start_mode() {
    mode=$1
    pending=""
    printf '\033[2J\033[H'
    if [ "$mode" = hacker ]; then
        zoomed=0
        P_RAW=("")
        P_FIT=("")
        P_VIS=(0)
        parse_hacker_session
        pane_relayout
        printf '\033[?25h'
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
    elif [ "$mode" = hacker ]; then
        # Keep the pretend htop moving while nobody types
        if ! take_key -t 0.25; then
            if [ "$mode" = hacker ]; then
                htop_tick
            fi
            continue
        fi
        key=$KEY
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
