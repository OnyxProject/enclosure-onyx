#!/bin/bash
CURRENT_VERSION=$(curl -s 'https://raw.githubusercontent.com/OnyxAI/onyx/master/version.json' | jq -r '.version')

ONYX_FOLDER="/home/pi/onyx"

ONYX_VERSION=$(cat $ONYX_FOLDER/version.json | jq -r '.version')


vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

testvercomp () {
    vercomp $1 $2
    case $? in
        0) op='=';;
        1) op='>';;
        2) op='<';;
    esac
    if [[ $op != $3 ]]
    then
        echo "NOT UPDATE REQUIRED"
    else
        echo "UPDATE REQUIRED"
        bash update-onyx.sh
    fi
}

echo "CURRENT_VERSION = " $CURRENT_VERSION
echo "ONYX_VERSION = " $ONYX_VERSION

testvercomp $CURRENT_VERSION $ONYX_VERSION ">"
