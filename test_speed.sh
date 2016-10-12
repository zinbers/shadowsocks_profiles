#!/bin/bash
server_file="ss_cfg.json"
if [ $1 ]; then
    server_file=$1
fi
server_list=(`cat $server_file| grep \"server\" | cut -d ":" -f 2`)
min_time=5000
min_server=""
total_server=${#server_list[@]}
for((i=1;i<=$total_server;i++))
do
    echo "--process $i/$total_server"
    serv=`echo ${server_list[i-1]} | tr -d '"'`
    ret=`ping -t 5 $serv`
    time=(`echo $ret | tr ' ' '\n' | grep "time"`)
    #echo "server:$serv"
    sum_time=0
    tmp_time=0
    counter=0
    for t in ${time[@]}
    do
        tmp_time=`echo $t | cut -d "=" -f2`
        if [ $tmp_time != $t ]; then
            sum_time=`echo "$sum_time+$tmp_time" | bc`
            let counter=counter+1
        fi
    done
    flag=`echo "$sum_time > 0" | bc`
    if [ $flag -gt 0 ]; then
        sum_time=`echo "$sum_time/$counter"|bc`
        echo "server:$serv avg_time:$sum_time"
        flag=`echo "$min_time > $sum_time" |bc`
        if [ $flag -gt 0 ]; then
            min_time=$sum_time
            min_server=$serv
        fi
    else
        echo "server:$serv avg_time:timeout"
    fi
done
echo "fin min_server:$min_server min_time:$min_time"
