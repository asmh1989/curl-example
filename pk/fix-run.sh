#!/bin/bash

pwd=$(pwd)
DATA=/mnt/share/sun/curl/biogen_data
script=$(pwd)/pkcsm.sh
result_dir=result2
for item in $(ls $DATA); do
    echo "start ${item}"
    cd $pwd
    mkdir -p $item && cd $item
    awk -F"," 'NR>1{print $2}' $DATA/$item | awk 'NR==1 || NR%100==1 { file = "output" (++count) ".txt" } { print > file }'
    mkdir -p $result_dir
    for input2 in $(ls *.txt); do
        input=$input2.csv
        echo "CC" >$input
        cat $input2 | head -n 2 >>$input
        if [ ! -f $result_dir/$input-absorption.csv ]; then
            echo "start $input to download pkcsm absorption .."
            bash $script $input absorption $result_dir/$input2-absorption.csv
        else
            echo "$input result already exist!"
        fi
        if [ ! -f $result_dir/$input-distribution.csv ]; then
            echo "start $input to download pkcsm distribution .."
            bash $script $input distribution $result_dir/$input2-distribution.csv
        else
            echo "$input result already exist!"
        fi

    done
done
