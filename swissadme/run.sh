#!/bin/bash

pwd=$(pwd)
DATA=$(pwd)/../biogen_data
script=$(pwd)/../swissadme.sh
for item in $(ls $DATA); do
    echo "start ${item}"
    cd $pwd
    mkdir -p $item && cd $item
    awk -F"," 'NR>1{printf("%s %s\n", $2,$1)}' $DATA/$item | awk 'NR==1 || NR%10==1 { file = "output" (++count) ".txt" } { print > file }'
    mkdir -p result
    for input in $(ls *.txt); do
        if [ ! -f result/$input.csv ]; then
            echo "start $input to download swissadme.."
            time bash $script $input result/$input.csv
            sleep 1
        else
            echo "$input result already exist!"
        fi
    done
done
