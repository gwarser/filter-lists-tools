#!/bin/bash


# Text formating
H="\033[1m"
L="\033[0m"


if ! curl --version &>/dev/null
then
    echo -e "$H# curl is required, exiting$L"
    exit
fi

if ! jq --version &>/dev/null
then
    echo -e "$H# jq is required, exiting$L"
    exit
fi


echo -e "$H# Downloading assets.json$L"
curl --compressed --location --progress-bar --output assets.json https://raw.githubusercontent.com/gorhill/uBlock/master/assets/assets.json


echo -e "$H# Extracting ID's and URL's$L"
jq --raw-output 'to_entries[] | select(.value.content == "filters") | "\(.key) \([.value.contentURL] | flatten[0]) \(.value.title)"' assets.json > assets.json-key-url.txt


echo -en "$H# Filter lists in total: $L"
grep -c '$' assets.json-key-url.txt


echo -e "$H# Donwloading lists$L"
while read -r key url title
do

    echo -e "$H# $key$L"
    curl --compressed --location --progress-bar --create-dirs --output "assets.json_resources/$key" "$url"
    echo -e "$title" > "assets.json_resources/${key}_title.txt"

done < assets.json-key-url.txt


echo -e "$H# Done$L"

