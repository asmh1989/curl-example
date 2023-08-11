#!/bin/bash

pwd=$(pwd)
DATA=/mnt/share/sun/curl/biogen_data
script=$(pwd)/drumap.sh
for item in $(ls $DATA); do
    echo "start ${item}"
    cd $pwd
    mkdir -p $item && cd $item
    awk -F"," 'NR>1{printf("%s\t%s\n", $2,$1)}' $DATA/$item | awk 'NR==1 || NR%10==1 { file = "output" (++count) ".txt" } { print > file }'
    mkdir -p result
    for input in $(ls *.txt); do
        if [ ! -f result/$input.csv ]; then
            echo "start $(item) $input to download drumap .."
            bash $script $input result/$input.csv
        else
            echo "$input result already exist!"
        fi

    done
done
