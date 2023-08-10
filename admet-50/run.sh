#!/bin/bash

pwd=$(pwd)
DATA=$pwd/../biogen_data
script=$pwd/admetmesh.sh
for item in $(ls $DATA); do
    echo "start ${item}"
    cd $pwd
    mkdir -p $item && cd $item
    awk -F"," 'NR>1{print $2}' $DATA/$item | awk 'NR==1 || NR%30==1 { file = "output" (++count) ".txt" } { print > file }'
    mkdir -p result
    for input in $(ls *.txt); do
        if [ ! -f result/$input.csv ]; then
            echo "start $input to download ametmesh.."
            bash $script $input result/$input.csv
        else
            echo "$input result already exist!"
        fi
    done
done
