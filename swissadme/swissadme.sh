#!/bin/bash
function urlencode() {
  echo -e "$1" | sed -e 's/+/%2b/g' -e 's/=/%3D/g' -e 's/ /+/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/,/%2c/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g' | sed ':label;N;s/\n/%0D%0A/;b label'
}

input='COCCN(C)c1ccc(CN2CCc3nn(C)c(=O)cc3C2)cn1 c0
CCN(CC(N)=O)CC(=O)N1c2ccccc2CCc2ccccc21 c1'

if [ ! -z $1 ]; then
  input="$(cat $1 | sed -e 's/\\/%5C/g')"
fi

encoded_value=$(urlencode "$input")

# echo "$encoded_value"

running=0
times=0
while [ $running == 0 ]; do
  output=$(
    curl -s 'http://www.swissadme.ch/index.php' \
      -H 'Proxy-Connection: keep-alive' \
      -H 'Cache-Control: max-age=0' \
      -H 'Upgrade-Insecure-Requests: 1' \
      -H 'Origin: http://www.swissadme.ch' \
      -H 'Content-Type: application/x-www-form-urlencoded' \
      -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 HBPC/12.1.3.303' \
      -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
      -H 'Referer: http://www.swissadme.ch/index.php' \
      -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8' \
      -H 'Cookie: _ga=GA1.2.365750215.1690870136; _gid=GA1.2.1044360362.1690870136; _pk_id.45.66d4=88b28eb4537417eb.1690870136.; _pk_ses.45.66d4=1; _ga_FTPHNJJ3FJ=GS1.2.1690870136.1.1.1690870630.0.0.0' \
      --data "smiles=$encoded_value" \
      --compressed \
      --insecure
  )
  echo "$output" >1.html
  times=$((times + 1))
  url=$(echo $output | grep -o 'results/[0-9]*/swissadme.csv')
  if [ ! -z $url ]; then
    running=1
  else
    sleep 4
    echo "开始第${times}次重试"
  fi

  if (($times > 4)); then
    echo "$1,$2" >>result/error.csv
    exit 1
  fi

done
# if [ ! -f "/path/to/file" ]; then
#     touch download.csv
# fi

echo "http://www.swissadme.ch/$url" >>result/download.csv
if [ ! -z $2 ]; then
  curl -s http://www.swissadme.ch/$url -o $2
  # echo "http://www.swissadme.ch/$url" >>$2
else
  curl http://www.swissadme.ch/$url
fi
