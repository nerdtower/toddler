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
# rest of arrow/function key escape sequences, and watches for the adult exit:
# z, 9, ! (shift+1) typed within 2 seconds. Never blocks waiting for the next
# key, so z draws like any other letter.
take_key() {
    local now
    IFS= read -rsn1 -d '' "$@" KEY || return 1
    if [ "$KEY" = $'\e' ]; then
        while IFS= read -rsn1 -d '' -t 0.02 _; do :; done
    fi

    now=${EPOCHREALTIME//[.,]/}
    if [ "$KEY" = "!" ] && [ "$last_key" = "9" ] &&
        { [ "$key_before_last" = "z" ] || [ "$key_before_last" = "Z" ]; } &&
        [ $((now - key_before_last_time)) -lt 2000000 ]; then
        cleanup
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

# Parse command line arguments
if [ $# -gt 0 ]; then
    if [ "$1" = "test" ]; then
        # Test mode: print one row and quit
        update_size
        scroll_row "${2:-A}" ""
        exit 0
    fi
    echo "Usage: $0 [test [CHARACTER]]"
    echo "  test [CHARACTER]: Test mode - print one row of a character and exit"
    exit 1
fi

# Child-proof the terminal: no echo, no line buffering, and no special keys.
# -isig makes Ctrl+C/Ctrl+Z/Ctrl+\ plain keypresses, -ixon stops Ctrl+S from
# freezing the screen, -iexten disables Ctrl+V and Ctrl+O.
saved_stty=$(stty -g)
trap restore_terminal EXIT
trap '' INT TERM TSTP TTIN TTOU QUIT
trap update_size WINCH
stty -echo -icanon -isig -ixon -iexten min 1 time 0
printf '\033[?25l'
clear
update_size

pending=""
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

    scroll_row "$key" "$delay"

    # Keep only the newest key mashed while drawing so the screen never lags
    while read -t 0; do
        if take_key; then
            pending=$KEY
        fi
    done
done
