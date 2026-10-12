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
#   @PROGRESS txt  a full-width progress bar that fills up by itself
#   @DOWNLOAD a b  one progress bar per file, filling at different speeds
#   @HEXDUMP n     n full-width lines of hex dump
#   @CRACK WORD    big letters spin through random ones and lock into WORD
#   @BANNER WORD   WORD in big green letters (one word per @BANNER)
#   @MATRIX s      green characters rain down the whole screen for s seconds
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
$ curl -O mainframe.local/files/{hearts.db,rainbows.tar.gz,kittens.zip,stars.iso}
@DOWNLOAD hearts.db rainbows.tar.gz kittens.zip stars.iso
$ xxd secret.bin
@HEXDUMP 28
$! free -h
$ ./crack --target mainframe.local
@CRACK HEARTS
{g}Password found!{0}
$ ssh mainframe.local
@PROGRESS Hacking the mainframe
@BANNER ACCESS
@BANNER GRANTED
$! ps -e | head -20
$ matrix
@MATRIX 4
$ clear
EOF

# Turn HACKER_SESSION into steps. TYPE steps wait for keypresses; every other
# step (PROMPT, SHOW, RUN, CLEAR and the @ effects) runs on its own.
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

# Wait between animation frames. A keypress ends the wait early and is kept
# in pending; returns 1 if the adult switched modes.
hacker_pause() {
    if take_key -t "$1"; then
        pending=$KEY
    fi
    [ "$mode" = hacker ]
}

# Set BIG_LINES to WORD drawn with the solid glyphs, one cell per letter of
# width cell (0 means each letter's own width), centered on the screen. Letter
# colors come from the array named by the second argument, cycling if short.
# Returns 1 if the word doesn't fit.
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
    if [ $total -gt "$cols" ]; then
        return 1
    fi
    printf -v pad '%*s' $(( (cols - total) / 2 )) ''
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

# A full-width progress bar that fills up by itself
effect_progress() {
    local text="$1" width i done_chars
    width=$((cols - ${#text} - 10))
    if [ $width -lt 10 ]; then
        width=10
    fi
    for ((i=0; i<=100; i+=2)); do
        done_chars=$((width * i / 100))
        printf '\r%s [\033[1;32m%s\033[0m%*s] %3d%%' "$text" \
            "$(printf '%*s' "$done_chars" '' | tr ' ' '#')" $((width - done_chars)) '' "$i"
        hacker_pause 0.03 || return
    done
    printf '\n'
}

# One progress bar per file, each filling at its own speed
effect_download() {
    local -a names pct=()
    local i n width done_chars all_done bar speed
    read -ra names <<< "$1"
    n=${#names[@]}
    width=$((cols - 44))
    if [ $width -lt 10 ]; then
        width=10
    fi
    for ((i=0; i<n; i++)); do
        pct[i]=0
        printf '\n'
    done
    while true; do
        printf '\033[%dA' "$n"
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
            printf '\r%-18s [\033[1;36m%-*s\033[0m] %3d%%  %-9s\033[K\n' \
                "${names[i]}" $((width + 1)) "$bar" "${pct[i]}" "$speed"
        done
        if [ $all_done -eq 1 ]; then
            return
        fi
        hacker_pause 0.05 || return
    done
}

# Full-width hex dump of random bytes
effect_hexdump() {
    local count="$1" per_line i j byte hex ascii out=""
    per_line=$(( (cols - 12) / 4 / 8 * 8 ))
    if [ $per_line -lt 8 ]; then
        per_line=8
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
    printf '\033[?25l'
    for ((r=0; r<9; r++)); do
        printf '\n'
    done
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
        printf '\033[9A'
        for ((r=0; r<9; r++)); do
            printf '\r%s\033[K\n' "${BIG_LINES[r]}"
        done
        frame=$((frame + 1))
        if [ $((frame % 6)) -eq 0 ]; then
            locked=$((locked + 1))
        fi
        hacker_pause 0.05 || break
    done
    printf '\033[?25h'
}

# A word in big green letters, scrolled in like output
effect_banner() {
    local -a green=(32)
    if big_word "$1" green 0; then
        printf '\n'
        show_output "$(printf '%s\n' "${BIG_LINES[@]}")"
    else
        show_output "{g}$1{0}"
    fi
}

# Green characters rain down the whole screen
effect_matrix() {
    local seconds="$1" chars="0123456789ABCDEFabcdef#$%&*+=<>"
    local rows frames f c out size
    local -a drop tail
    size=$(stty size 2>/dev/null)
    rows=${size% *}
    rows=${rows:-24}
    for ((c=1; c<=cols; c++)); do
        drop[c]=$(( -(RANDOM % rows) ))
        tail[c]=$((6 + RANDOM % 14))
    done
    frames=$(( seconds * 25 ))
    printf '\033[?25l\033[2J'
    for ((f=0; f<frames; f++)); do
        out=""
        for ((c=1; c<=cols; c+=2)); do
            drop[c]=$((drop[c] + 1))
            if [ "${drop[c]}" -ge 1 ] && [ "${drop[c]}" -le "$rows" ]; then
                out+=$'\e['"${drop[c]};${c}H"$'\e[1;37m'"${chars:RANDOM % ${#chars}:1}"
            fi
            if [ $((drop[c] - 1)) -ge 1 ] && [ $((drop[c] - 1)) -le "$rows" ]; then
                out+=$'\e['"$((drop[c] - 1));${c}H"$'\e[1;32m'"${chars:RANDOM % ${#chars}:1}"
            fi
            if [ $((drop[c] - tail[c])) -ge 1 ] && [ $((drop[c] - tail[c])) -le "$rows" ]; then
                out+=$'\e['"$((drop[c] - tail[c]));${c}H "
            fi
            if [ $((drop[c] - tail[c])) -gt "$rows" ]; then
                drop[c]=$(( -(RANDOM % 10) ))
                tail[c]=$((6 + RANDOM % 14))
            fi
        done
        printf '%s\033[0m' "$out"
        hacker_pause 0.04 || break
    done
    printf '\033[0m\033[2J\033[H\033[?25h'
}

# Run steps until the next one that needs typing
run_hacker_steps() {
    while [ "$mode" = hacker ]; do
        case "${step_kind[step]}" in
            TYPE) return ;;
            PROMPT) printf '%s' "${step_text[step]}" ;;
            SHOW) show_output "${step_text[step]}" ;;
            RUN) show_output "$(bash -c "${step_text[step]}" 2>&1 | head -n 30)" ;;
            CLEAR) printf '\033[2J\033[H' ;;
            @PROGRESS) effect_progress "${step_text[step]}" ;;
            @DOWNLOAD) effect_download "${step_text[step]}" ;;
            @HEXDUMP) effect_hexdump "${step_text[step]}" ;;
            @CRACK) effect_crack "${step_text[step]}" ;;
            @BANNER) effect_banner "${step_text[step]}" ;;
            @MATRIX) effect_matrix "${step_text[step]}" ;;
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
