#!/bin/bash

function print_in_file () {
    if [ "$1" == "t" ]; then
        echo "${oldperiod}:${occurrence}" >>  /var/www/html/test/nonunique.txt
    else
        echo "${oldperiod}:${occurrence}" >>  /var/www/html/test/unique.txt
    fi
}

function count_in_string () {
    inc=0
    array=$(echo ${line} | awk '{print substr($0,16)}'| sed 's/\[//g'| sed 's/\]//g'| sed 's/ //g')
    if [[ $array != *"-"* ]] && [[ "$1" == "t" ]];then
        inc=$(echo $array | awk '{$0=$0","; print gsub(",",x)}')
        occurrence=$(( occurrence + $inc ))
    elif [[ $array != *"-"* ]] && [[ "$1" == "u" ]];then
        echo  $array | tr , '\n' >> templist.log
        occurrence=$(sort -u templist.log |wc -l)
    fi
}

function check_period () {
    period=$(echo $line | awk '{print substr($0,0,11)}')
    if [ "$oldperiod" == "0" ];then
        oldperiod=$period
        count_in_string $1
    elif [ "$oldperiod" != "$period" ];then
        #echo "${oldperiod}:${occurrence}"
        print_in_file $1
        oldperiod=$period
        occurrence=0
        true > templist.log
        count_in_string $1
    else
        count_in_string $1
    fi
}

function read_check_extract () {
    oldperiod=0
    occurrence=0
    while read line; do
        check_period $1
    done < interview.log
    print_in_file $1
    if [[ -f templist.log ]];then
        rm templist.log
    fi
}

if [[ -f interview.log ]];then
    if [[ "$1" == "" ]]; then
        echo "you should add the 'u' parameter if you want to extract unique values, \n  or the 't' parameter if you want to display all data."
    elif [ "$1" != "u" ] && [ "$1" != "t" ]; then
        echo "you have selected an invalid parameter: " $1 "\nPlease,  select 'u' or 't'."
    else
        if [ "$1" == "t" ]; then
            true >  /var/www/html/test/nonunique.txt
        else
            true >  /var/www/html/test/unique.txt
            true > templist.log
        fi
    read_check_extract "$1"
    fi
else
    echo "file source not found, please check the sources."
fi        
