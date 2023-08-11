#! /bin/bash

function urlencode() {
    echo -e "$1" | sed -e 's/ /+/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/,/%2c/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5B/g' -e 's/\]/%5D/g' -e 's/\^/%5e/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g' | sed ':label;N;s/\n/%0D%0A/;b label'
}

function urlencode2() {
    echo -e "$1" | sed -e 's/ /+/g' -e 's/>/%3E/g' -e 's/</%3C/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/,/%2c/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5B/g' -e 's/\]/%5D/g' -e 's/\^/%5e/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g' -e 's/=/%3D/g' | sed ':label;N;s/\n/%0D%0A/;b label'
}

input=job-all.csv

if [ -f "$1" ]; then
    input=$1
fi

data="{\"authenticity_token\":\"xAa59sbj+571sp0Q5VNJ9ilETMl0WWIDILOo04YC8bD4GP1g3f7hmLxFdMpO/AbeILRBW1H3cMU49pk5NBJsAA==\",\"data\":\"$(cat $input | sed 's/\\/\\\\/g' | sed 's/\t/\\t/g' | sed ':label;N;s/\n/\\n/;b label')\"}"

mkdir -p tmp
# echo -e "$data"
#输入文件路径
curl -s 'https://drumap.nibiohn.go.jp/prediction/smiles' \
    -H 'authority: drumap.nibiohn.go.jp' \
    -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="99"' \
    -H 'accept: */*' \
    -H 'content-type: application/json' \
    -H 'x-requested-with: XMLHttpRequest' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.3.303' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'origin: https://drumap.nibiohn.go.jp' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-dest: empty' \
    -H 'referer: https://drumap.nibiohn.go.jp/prediction' \
    -H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8' \
    -H 'cookie: _drumap_session=%2Bkak20d5X%2FLmC4JVLArpVX41BAl3sFSBirzfnijs%2FXM6NGTHS3rpOz2CkSSZ%2BC5j47YPw9mGRuDBo9NAjz6ITZ%2FKc5Xw58q72EJDkSNrqr4Hc1hrxfMpQnAEdvfzM4O0%2Fg6%2BEZmQftSxCnCGVNbgG9DxHkn1hRGs7NHIjwiQNnuNGDejZftuIjq5ions5uidfxcTAC%2FVwXdGKk2kM41u4HMdcgDARkI06%2BFtOZw5LwheIoJX9g2WHKANWZtCFiTQ6CAHJQ%3D%3D--0wW3UwMGKkpqpP8j--gEc3l5f1ZIjBKwSMEQTpLQ%3D%3D' \
    --data-raw "$data" \
    --compressed -o tmp/$1.smi

# echo "compound=${output}"
prediction=""

for item in $(awk -F"\t" '{print $2}' $input); do
    prediction="${prediction}prediction[options][${item}][apka]=&prediction[options][${item}][bpka]=&prediction[options][${item}][logp]=&"
done

# echo "prediction=${prediction}"

prediction_encode=$(urlencode "$prediction")
output_encode=$(urlencode2 "$(cat tmp/$1.smi | sed -e 's/\\/%5C/g')")

# echo "$output_encode"

data="utf8=%E2%9C%93&authenticity_token=iCMu1pFbTQPU9Cx1xtjxhoIfdn9F1nunORVh5fCqUPi0PWpAikZXBZ0Dxa9td76ui%2B977WB4aWEhUFAPQrrNSA%3D%3D&${prediction_encode}prediction%5Bmolecules%5D=${output_encode}%24%24%24%24&prediction%5Bparameters%5D%5B%5D=d_sol74&prediction%5Bparameters%5D%5B%5D=fu_p_human&prediction%5Bparameters%5D%5B%5D=fu_p_rat&prediction%5Bparameters%5D%5B%5D=fu_brain_mammal&prediction%5Bparameters%5D%5B%5D=clint_human&prediction%5Bparameters%5D%5B%5D=clint_value&prediction%5Bparameters%5D%5B%5D=papp_human_caco2&prediction%5Bparameters%5D%5B%5D=ner_human_llc_pk1&prediction%5Bparameters%5D%5B%5D=fa_human&prediction%5Bparameters%5D%5B%5D=clr_human&prediction%5Bparameters%5D%5B%5D=fe_human&prediction%5Bparameters%5D%5B%5D=cr_type_human&prediction%5Bparameters%5D%5B%5D=kp_brain_rat&commit=Calculate"

# echo "data=$data"
# echo "output == $output"
output=$(curl 'https://drumap.nibiohn.go.jp/prediction' \
    -H 'authority: drumap.nibiohn.go.jp' \
    -H 'cache-control: max-age=0' \
    -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="99"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'origin: https://drumap.nibiohn.go.jp' \
    -H 'content-type: application/x-www-form-urlencoded' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.3.303' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-mode: navigate' \
    -H 'sec-fetch-user: ?1' \
    -H 'sec-fetch-dest: document' \
    -H 'referer: https://drumap.nibiohn.go.jp/prediction' \
    -H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8' \
    -H 'cookie: _drumap_session=SicyeEeGJP9U36Q%2FKScKXA3ytOBvdgYTEPVg%2F1nUdHprLVzl4TKMABWZOT%2Fa8twkfI%2FV1bqyQLs1%2BBGXWYjhTpfqI3xn5IDDQa2%2BP41%2BdBvnRMN3LhxhJV02VorzbYrSEeJPZFMZ6fF72cIKrKEc3E9cqDpeRMzwBy6WY8UtpC7V9oZX1tyfEC42qWqyYhmxSwPoPvLtSRKhAterfeYw4K31slT3ZpXCxMmiBhVhwzKEAOPpS5IO7IsYnKXdhjRPkXIuLw%3D%3D--EPAx57SoIZjvO296--JCSXrE3MtH5Dat7L3l%2BM2Q%3D%3D' \
    --data-raw "$data" \
    --compressed)

url=$(echo $output | grep -o 'https://drumap.nibiohn.go.jp/prediction/[-a-z0-9]*' | head -n 1)

if [ -z $url ]; then
    echo "url 为空"
    exit 1
fi
# https://drumap.nibiohn.go.jp/prediction/799f5dec-7a2b-45d9-abe6-82be0b548180/result.tsv
echo "url=$url"

echo "curl --location $url  | grep -o \"prediction/[-a-z0-9]*/result.tsv\""

running=0
times=0
while [ $running == 0 ]; do
    csv=$(curl --location -s $url | grep -o "prediction/[-a-z0-9]*/result.tsv")
    if (($? == 0)); then
        running=1
    else
        sleep 10
    fi
    times=$((times + 1))
    if (($times > 32)); then
        echo "$1,$2,$3" >>result/error.csv
        exit 1
    fi
    echo "开始第${times}次重试"
done
echo "https://drumap.nibiohn.go.jp/$csv"
curl https://drumap.nibiohn.go.jp/$csv -o $2
