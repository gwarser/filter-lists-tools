#!/bin/bash


# Text formating
H="\033[1m"
L="\033[0m"
W="\033[1;93m"
E="\033[1;91m"
R="\033[0m"


if ! curl --version &>/dev/null
then
    echo -e "$E# curl is required, exiting$R"
    exit
fi

if ! jq --version &>/dev/null
then
    echo -e "$E# jq is required, exiting$R"
    exit
fi


echo -e "$H# Downloading filterlists.com software table$R"
curl --compressed --location --progress-bar --time-cond filterlists.com-software.min.json \
    --output filterlists.com-software.min.json https://filterlists.com/api/v1/software

# echo -e "$H# Pretty print filterlists.com software table$R"
# jq '.' < filterlists.com-software.min.json > filterlists.com-software.json


echo -e "$H# Downloading filterlists.com lists table$R"
curl --compressed --location --progress-bar --time-cond filterlists.com-lists.min.json \
    --output filterlists.com-lists.min.json https://filterlists.com/api/v1/lists

# echo -e "$H# Pretty print filterlists.com lists table$R"
# jq '.' < filterlists.com-lists.min.json > filterlists.com-lists.json


echo -e "$H# Extracting id, viewUrl and name$R"
# 20% faster?
# jq --null-input --raw-output --slurpfile SOFT filterlists.com-software.min.json --slurpfile LISTS filterlists.com-lists.min.json \
#  '$SOFT[0][]|select(.name == "uBlock Origin").syntaxIds as $IDS | $LISTS[0][]|select(.syntaxId|inside($IDS[])) | "\(.id) \(.viewUrl) \(.name)"' \
#  > filterlists.com-id-url-name.txt

jq --raw-output --slurpfile SOFT filterlists.com-software.min.json \
 '.[] | select(.syntaxId|inside($SOFT[0][]|select(.name == "uBlock Origin").syntaxIds[])?) | "\(.id) \(.viewUrl) \(.name)"' \
 < filterlists.com-lists.min.json \
 > filterlists.com-id-url-name.txt
 
 
echo -en "$H# Filter lists in total: $R"
ALL=$(grep -c '$' filterlists.com-id-url-name.txt)
echo "$ALL"

CUR=0
echo -e "$H# Downloading lists$R"
while read -r id url name
do

    ((CUR++))
    echo -e "$L$CUR/$ALL: $name ($id)$R"

    if [[ "$url" == *.zip || "$url" == *.7z ]]
    then
        echo -e "$W# Compressed, skipping$R"
        echo -e "$(date +%F): zip: $id $url $name" >> "filterlists.com-failed-downloads.txt"
        continue
    fi

#   Order in characters list is important.
    safename=$(echo -e "$name" | tr -cd -- "&'()+,. [:alnum:]_-")
    filepath="filterlists.com_resources/${id}_$safename.txt"

    if curl --compressed --location --fail --progress-bar --create-dirs --time-cond "$filepath" \
        --output "$filepath" "$url"

    then
        echo -e "$name" > "filterlists.com_resources/${id}_name.txt"
    else
        echo -e "$E# Downloading failed$R"
        echo -e "$(date +%F): 404: $id $url $name" >> "filterlists.com-failed-downloads.txt"
    fi

done < filterlists.com-id-url-name.txt


echo -e "$H# Done$R"

