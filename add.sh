#!/bin/bash

version=1.0.1
function killShadowsocksX(){
    ss_process=`ps aux | grep "ShadowsocksX$" | grep -v "grep"`
    if [ "$ss_process" ]; then
        pid=`echo "$ss_process" | awk '{print $2}'`
        if [ -z "$pid" ]; then
            echo "kill shadowsocks process failed, please restart ShadowsocksX manually!"
        else
            kill -9 "$pid"
        fi
    fi
}

function restartShadowsocksX(){
    ss_app_path="/Applications/ShadowsocksX.app"
    if [ -d "$ss_app_path" ]; then
        open "$ss_app_path"
        echo "restart ShadowSocksX success."
    fi
}

ss_cfg=${1:-"ss_cfg.json"}
if [ -s "$HOME/Library/Preferences/clowwindy.ShadowsocksX.plist" ]; then
    plutil -convert xml1 $HOME/Library/Preferences/clowwindy.ShadowsocksX.plist -o tmp.xml
    lines=(`grep -n "data" tmp.xml | cut -d ':' -f 1`)
    data_start=${lines[0]}
    data_end=${lines[1]}
    data_start_next=$[$data_start + 1]
    data_end_last=$[$data_end - 1]
    if [ -s "$ss_cfg" ]; then
        encodeJson=`cat "$ss_cfg" | base64`
        sed -i.bak "${data_start_next},${data_end_last}d;${data_start}a\\$encodeJson" ./tmp.xml
    else
        echo "can not find json config file or it's empty!"
        exit 1
    fi
    plutil -convert binary1 ./tmp.xml -o ./tmp.plist
    defaults import clowwindy.ShadowsocksX ./tmp.plist
    rm tmp.xml tmp.xml.bak tmp.plist
    echo "done!"
    killShadowsocksX
    restartShadowsocksX
else
    echo "can not find shadowsocks.plist or it's empty!"
    exit 1
fi




