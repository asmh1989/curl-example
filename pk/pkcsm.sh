#! /bin/bash

#输入文件路径
input=$1
type=$2
output=$(curl -s 'https://biosig.lab.uq.edu.au/pkcsm/admet_prediction' \
    --form "pred_type=$type" \
    --form "smiles_file=@${input}")

url=$(echo $output | grep -o 'pkcsm/prediction/[a-z_0-9.]*' | head -n 1)

if [ -z $url ]; then
    echo "url 为空"
    exit 1
fi

echo "https://biosig.lab.uq.edu.au/$url"

echo "curl --location https://biosig.lab.uq.edu.au/$url  | grep -o \"pkcsm/get_results/[0-9_a-z./]*.csv\""

running=0
times=0
while [ $running == 0 ]; do
    csv=$(curl --location -s https://biosig.lab.uq.edu.au/$url | grep -o "pkcsm/get_results/[0-9_a-z./]*.csv")
    if (($? == 0)); then
        running=1
    else
        sleep 10
    fi
    times=$((times + 1))
    echo "开始第${times}次重试"
    if (($times > 32)); then
        echo "$1,$2,$3" >>result/error.csv
        exit 1
    fi
done
curl -s https://biosig.lab.uq.edu.au/$csv -o $3
