#!/bin/bash
clear

# save separator to handle folders with whatever space encoding may happen.
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")


musicRoot="/home/vincentvinciane/Documents/testmusicencode/"
musicTarget=/home/vincentvinciane/exportMusic/


function encodeFolders() {
    local source="$1"
    local dest="$2"
    local folder
    local foldername
    local destFolder
    
    echo Looking into folder : $source
    #echo With target being : $dest
    
    for folder in $source*/ ; do
        if [ -d "$folder" ]; then
            folderName="${folder%/*}"
            folderName="${folderName##*/}"
            destFolder="$dest$folderName/"
            mkdir -p "$destFolder"
            
            #echo ---folder:$folder
            #echo ---dest:$destFolder            
            encodeFolders "$folder" "$destFolder"
        fi
    done
    
    encodeMusic "$1" "$2"
}

function encodeMusic() {
    local source="$1"
    local dest="$2"
    
    echo Encoding folder :$source
    if test -f "$dest.folderComplete"; then
        echo "    folder already encoded, skipped"
        return
    fi
    
    shopt -s nullglob nocaseglob
    
    # remove bad characters from filenames
    bad_chars="\?:\|\"*"
    for i in $source*["$bad_chars"]*; do 
        echo $i
        mv "$i" "${i//[$bad_chars]/}"
    done
    
    for file in $source*.{ogg,wma,flac,mp3} ; do
        echo "    File to encode:"$file
        local filename=$(basename "$file")
        filename=${filename%.*}
        
        local output="$dest$filename.mp3"
        
        # encode to output dest
        ffmpeg -i "$file" -vn -loglevel error -acodec libmp3lame -q:a 6 "$output"
        
    done
    
    touch ".folderComplete"
}

encodeFolders $musicRoot $musicTarget

IFS=$SAVEIFS
