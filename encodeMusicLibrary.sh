#!/bin/bash
clear

# save separator to handle folders with whatever space encoding may happen.
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# kill script with single ctrl + C
trap "exit" INT

# Some option that might help for empty list & case insensitive
shopt -s nullglob nocaseglob
    

#musicRoot="/home/vincentvinciane/Musique/"
musicRoot="$1"
#musicTarget=/home/vincentvinciane/exportMusic/
musicTarget="$2"

function encodeFolders() {
    local source="$1"
    local dest="$2"
    
    for folder in $source*/ ; do
        if [ -d "$folder" ]; then
            folderName="${folder%/*}"
            folderName="${folderName##*/}"
            destFolder="$dest$folderName/"
            mkdir -p "$destFolder"
            
            printf "\nLooking into folder : $folderName\n"
    
            encodeFolders "$folder" "$destFolder"
        fi
    done
    
    encodeMusic "$1" "$2"
}

function encodeMusic() {
    local source="$1"
    local dest="$2"
    
    if test -f "$dest.folderComplete"; then
        printf "    Folder already encoded, skipped : $source \n\n"
        return
    fi
    
    printf "\n  Encoding folder :$source\n"
    removeBadChars "$source"
    
    for file in $source*.{ogg,wma,flac,mp3} ; do
        local filename=$(basename "$file")
        filename=${filename%.*}
        printf "    File to encode:$filename\n"
        
        local output="$dest$filename.mp3"
        
        # encode to output dest
        ffmpeg -y -i "$file" -vn -loglevel error -acodec libmp3lame -q:a 6 "$output"
        
    done
    
    touch "$dest.folderComplete"
}

function removeBadChars() {
    bad_chars="\?:\|\"*"
    for i in $1*["$bad_chars"]*; do 
        printf "    Renamed : $i\n"
        mv "$i" "${i//[$bad_chars]/}"
    done
}

encodeFolders $musicRoot $musicTarget

IFS=$SAVEIFS
