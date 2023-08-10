#!/bin/bash

pwd=$(pwd)
DATA=/mnt/share/sun/curl/biogen_data
script=$(pwd)/pkcsm.sh
for item in $(ls $DATA); do
    echo "start ${item}"
    cd $pwd
    mkdir -p $item && cd $item
    awk -F"," 'NR>1{print $2}' $DATA/$item | awk 'NR==1 || NR%100==1 { file = "output" (++count) ".txt" } { print > file }'
    mkdir -p result
    for input in $(ls *.txt); do
        if [ ! -f result/$input-absorption.csv ]; then
            echo "start $input to download pkcsm absorption .."
            bash $script $input absorption result/$input-absorption.csv
        else
            echo "$input result already exist!"
        fi
        if [ ! -f result/$input-distribution.csv ]; then
            echo "start $input to download pkcsm distribution .."
            bash $script $input distribution result/$input-distribution.csv
        else
            echo "$input result already exist!"
        fi

    done
done
