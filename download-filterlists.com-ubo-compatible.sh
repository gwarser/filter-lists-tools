#!/bin/bash

# Text formating
H="\033[1m"
L="\033[0m"
W="\033[1;93m"
E="\033[1;91m"
R="\033[0m"

if ! curl --version &>/dev/null
then
    echo -e "$E# curl is required, aborting$R"
    exit
fi

if ! jq --version &>/dev/null
then
    echo -e "$E# jq is required, aborting$R"
    exit
fi

echo -e "$H# Downloading filterlists.com software table$R"
if ! curl --compressed --location --progress-bar --time-cond \
    filterlists.com-Software.json --output filterlists.com-Software.json \
    https://raw.githubusercontent.com/collinbarrett/FilterLists/master/services/Directory/data/Software.json
then
    echo -e "$E# Failed to download filterlists.com software table$R"
    exit
fi

echo -e "$H# Downloading filterlists.com software syntax table$R"
if ! curl --compressed --location --progress-bar --time-cond \
    filterlists.com-SoftwareSyntax.json --output \
    filterlists.com-SoftwareSyntax.json \
    https://raw.githubusercontent.com/collinbarrett/FilterLists/master/services/Directory/data/SoftwareSyntax.json
then
    echo -e "$E# Failed to download filterlists.com software syntax table$R"
    exit
fi

echo -e "$H# Downloading filterlists.com lists syntax table$R"
if ! curl --compressed --location --progress-bar --time-cond \
    filterlists.com-FilterListSyntax.json --output \
    filterlists.com-FilterListSyntax.json \
    https://raw.githubusercontent.com/collinbarrett/FilterLists/master/services/Directory/data/FilterListSyntax.json
then
    echo -e "$E# Failed to download filterlists.com lists syntax table$R"
fi

echo -e "$H# Downloading filterlists.com lists table$R"
if ! curl --compressed --location --progress-bar --time-cond \
    filterlists.com-FilterList.json --output filterlists.com-FilterList.json \
    https://raw.githubusercontent.com/collinbarrett/FilterLists/master/services/Directory/data/FilterList.json
then
    echo -e "$E# Failed to download filterlists.com lists table$R"
fi

echo -e "$H# Downloading filterlists.com viewURL table$R"
if ! curl --compressed --location --progress-bar --time-cond \
    filterlists.com-FilterListViewUrl.json --output filterlists.com-FilterListViewUrl.json \
    https://raw.githubusercontent.com/collinbarrett/FilterLists/master/services/Directory/data/FilterListViewUrl.json
then
    echo -e "$E# Failed to download filterlists.com viewURL table$R"
fi

echo -e "$H# Extracting id and name$R"

jq --raw-output --null-input \
    --slurpfile SOFTWARE filterlists.com-Software.json \
    --slurpfile SOFTWARESYNTAX filterlists.com-SoftwareSyntax.json \
    --slurpfile FILTERLISTSYNTAX filterlists.com-FilterListSyntax.json \
    --slurpfile FILTERLISTS filterlists.com-FilterList.json \
    --slurpfile VIEWURL filterlists.com-FilterListViewUrl.json \
    '$SOFTWARE[0][]|select(.name=="uBlock Origin").id as $vSoftId | $SOFTWARESYNTAX[0][]|select(.softwareId==$vSoftId).syntaxId as $vSoftSyntax | $FILTERLISTSYNTAX[0][]|select(.syntaxId|inside($vSoftSyntax)).filterListId as $vFilterListId | $FILTERLISTS[0][]|select(.id==$vFilterListId and (.isDeleted==true|not)) as $vFilterList | {name:$vFilterList.name, data:[$VIEWURL[0][]|select(.filterListId==$vFilterList.id)]} | "\(.data[0].filterListId) \(.data[0].url) \(.name)"' \
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



    if [[ "$url" == *.zip || "$url" == *.7z || "$url" == *.tar.gz ]]
    then
        echo -e "$W# Compressed, skipping$R"
        echo -e "$(date +%F):\tzip:\t$id\t$url\t$name" >> "failed-downloads-filterlists.com.txt"
        continue
    fi

#   Order in characters list is important.
    safename=$(echo -e "$name" | tr -cd -- "&'()+,. [:alnum:]_-")
    filepath="filterlists.com_resources/${id}_$safename.txt"

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
            echo -e "$name" > "filterlists.com_resources/${id}_name.txt"
        fi
    else
        ret=$?
        echo -e "$E# Download failed$R"
        echo -e "$(date +%F):\t404($ret):\t$id\t$url\t$name" >> "failed-downloads-filterlists.com.txt"
    fi
done < filterlists.com-id-url-name.txt


echo -e "$H# Done$R"

