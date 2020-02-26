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
curl --compressed --location --progress-bar --time-cond assets.json \
    --output assets.json https://raw.githubusercontent.com/gorhill/uBlock/master/assets/assets.json


echo -e "$H# Extracting ID's and URL's$L"
jq --raw-output 'to_entries[] | select(.value.content == "filters") | "\(.key) \([.value.contentURL] | flatten[0]) \(.value.title)"' \
    assets.json > assets.json-id-url-name.txt


echo -en "$H# Filter lists in total: $L"
grep -c '$' assets.json-id-url-name.txt


echo -e "$H# Downloading lists$L"
while read -r id url name
do

    echo -e "$H# $id$L"

#   Order in characters list is important.
    safename=$(echo -e "$name" | tr -cd -- "&'()+,. [:alnum:]_-")
    filepath="assets.json_resources/${id}_$safename.txt"

    if curl --compressed --location --fail --progress-bar --create-dirs --time-cond "$filepath" \
        --output "$filepath" "$url"

    then
        echo -e "$name" > "assets.json_resources/${id}_name.txt"
    else
        ret=$?
        echo -e "$H# Downloading failed$L"
        echo -e "$?:\t$id\t$url\t$name" >> "assets.json-failed-downloads.txt"
    fi

done < assets.json-id-url-name.txt


echo -e "$H# Done$L"

