#!/bin/bash

if [ -z $1 ]; then
    echo "输入要检查的目录"
    exit 1
fi

output=all-$1
rm -f $output

i=1
while [ -f $1/result/output$i.txt.csv ]; do
    input=$1/result/output$i.txt.csv
    echo "start $input"
    if [ ! -f $output ]; then
        cat $input >$output
    else
        awk 'NR>1' $input >>$output
    fi
    i=$((i + 1))
done

paste -d ',' ../biogen_data/$1 all-$1 | sed 's/\t/,/g' >drumap-$1
