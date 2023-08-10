#!/bin/bash
function urlencode() {
  echo -e "$1" | sed -e 's/=/%3D/g' -e 's/ /+/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/,/%2c/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g' -e 's/+/%2b/g' | sed ':label;N;s/\n/%0D%0A/;b label'
}

input='C1=CC=C(C=C1)C(=O)NC2=C(N=C(S2)N)C3=CC=CS3
CC(C)OC(=O)CC(=O)CSC1=C(C=C2CCCC2=N1)C#N
C1CCC2(CC1)NC3=CC(=C(C#N)C#N)C=CC3=N2
CCC1=NNC2=C1/C(=N\O)/CC(C2)C3=CC=CC=C3
CN1C2=CC=CC=C2N=C1SC3=CS(=O)(=O)C4=CC=CC=C43'

if [ ! -z $1 ]; then
  # echo "find input file $(cat $1 | wc -l)"
  input="$(cat $1 | sed -e 's/\\/%5C/g')"
fi

encoded_value=$(urlencode "$input")

# echo "$encoded_value"

csrfmiddlewaretoken='HQcypM498ZNjH4YNSnzq6tzhX5ziLJma4p5eI1415mBwSYG7OljP80e0zY9Z9ttd'

running=0
times=0
while [ $running == 0 ]; do
  output=$(curl -s 'https://admetmesh.scbdd.com/service/screening/cal' \
    -H 'Connection: keep-alive' \
    -H 'Cache-Control: max-age=0' \
    -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="99"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H 'Origin: https://admetmesh.scbdd.com' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.3.303' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
    -H 'Sec-Fetch-Site: same-origin' \
    -H 'Sec-Fetch-Mode: navigate' \
    -H 'Sec-Fetch-User: ?1' \
    -H 'Sec-Fetch-Dest: document' \
    -H 'Referer: https://admetmesh.scbdd.com/service/screening/index' \
    -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8' \
    -H 'Cookie: csrftoken=B6J4Usx60nmDmLJwrlMMkQ9OD4jQMDPGYFCKdHxYXKaQxFrQnjwbmnOxfXTxanWJ' \
    --data-raw "csrfmiddlewaretoken=$csrfmiddlewaretoken&smiles-list=${encoded_value}&method=2" \
    --compressed)

  echo $output >test1.html
  url=$(echo $output | grep -B4 'as CSV' | grep -o 'static/files/filter/result/tmp/[a-z0-9]*.csv' | head -n 1)
  if [ ! -z $url ]; then
    running=1
  else
    sleep 4
  fi
  times=$((times + 1))
  echo "开始第${times}次重试"
  if (($times > 6)); then
    echo "$1,$2" >>result/error.csv
    exit 1
  fi
done
echo "url=https://admetmesh.scbdd.com/$url"
sleep 1
if [ ! -z $2 ]; then
  curl -s https://admetmesh.scbdd.com/$url -o $2
else
  curl https://admetmesh.scbdd.com/$url
fi
