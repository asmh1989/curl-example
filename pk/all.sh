#!/bin/bash

if [ -z $1 ]; then
    echo "输入要检查的目录"
    exit 1
fi

rm -f all-absorption-$1
rm -f all-distribution-$1

i=1
while [ -f $1/result/output$i.txt-absorption.csv ]; do
    input=$1/result/output$i.txt-absorption.csv
    input2=$1/result2/output$i.txt-absorption.csv

    output=all-absorption-$1
    echo "start $input"
    if [ ! -f $output ]; then
        cat $input2 >$output
        awk 'NR>2' $input >>$output
    else
        awk 'NR>1' $input2 >>$output
        awk 'NR>2' $input >>$output
    fi

    input=$1/result/output$i.txt-distribution.csv
    input2=$1/result2/output$i.txt-distribution.csv
    output=all-distribution-$1

    echo "start $input"
    if [ ! -f $output ]; then
        cat $input2 >$output
        awk 'NR>2' $input >>$output
    else
        awk 'NR>1' $input2 >>$output
        awk 'NR>2' $input >>$output
    fi
    i=$((i + 1))
done

paste -d ',' ../biogen_data/$1 all-absorption-$1 | sed 's/\t/,/g' >pkcsm-absorption-$1
paste -d ',' ../biogen_data/$1 all-distribution-$1 | sed 's/\t/,/g' >pkcsm-distribution-$1
