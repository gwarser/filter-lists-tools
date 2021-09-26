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
if ! curl --compressed --location --progress-bar --time-cond assets.json \
    --output assets.json https://raw.githubusercontent.com/gorhill/uBlock/master/assets/assets.json
then
    echo -e "$E# Failed to download assets.json$L"
    exit
fi


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

    if [ -f "$filepath" ]
    then
        filepathin="$filepath"
    else
        filepathin="$filepath".zst
    fi

    if curl --compressed --location --fail --progress-bar --create-dirs \
        --time-cond "$filepathin" --output "$filepath" "$url"
    then
        if [ -f "$filepath" ]
        then
            zstd -fq "$filepath" && rm "$filepath"
            echo -e "$name" > "assets.json_resources/${id}_name.txt"
        fi
    else
        ret=$?
        echo -e "$H# Download failed$L"
        echo -e "$(date +%F):\t($ret):\t$id\t$url\t$name" >> "failed-downloads-assets.json.txt"
    fi
done < assets.json-id-url-name.txt


echo -e "$H# Done$L"

