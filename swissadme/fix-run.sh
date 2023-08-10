#!/bin/bash

pwd=$(pwd)
DATA=/HOME/scz1961/run/demo/curl/biogen_data
script=/HOME/scz1961/run/demo/curl/swissadme.sh

if [ -z $1 ]; then
    echo "输入要检查的目录"
    exit 1
fi

cd $1
for input in $(ls *.txt); do
    # echo "start ${input}"
    reslut_file=result/$input.csv
    lines=$(cat $reslut_file | grep -v '^$' | wc -l)
    ori_lines=$(cat $input | grep -v '^$' | wc -l)
    if [ ! -f $reslut_file ]; then
        echo "start $input to download ametmesh.."
        bash $script $input result/$input.csv
    else
        while [ $lines != $((ori_lines + 1)) ]; do
            echo "$reslut_file 行数不对, $lines ！= $((ori_lines + 1)) ， 需要重新下载"
            bash $script $input result/$input.csv
            lines=$(cat $reslut_file | grep -v '^$' | wc -l)
            sleep 1
        done
    fi
done
