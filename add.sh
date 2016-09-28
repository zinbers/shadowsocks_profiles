#!/bin/bash
if [ -s "$HOME/Library/Preferences/clowwindy.ShadowsocksX.plist" ]; then
    plutil -convert xml1 $HOME/Library/Preferences/clowwindy.ShadowsocksX.plist -o tmp.xml
    lines=(`grep -n "data" tmp.xml | cut -d ':' -f 1`)
    data_start=${lines[0]}
    data_end=${lines[1]}
    data_start_next=$[$data_start + 1]
    data_end_last=$[$data_end - 1]
    if [ -s ./ss_cfg.json ]; then
        encodeJson=`cat ./ss_cfg.json | base64`
        sed -i.bak "${data_start_next},${data_end_last}d;${data_start}a\\$encodeJson" ./tmp.xml
    else
        echo "can not find json config file or it's empty!"
        exit 1
    fi
    plutil -convert binary1 ./tmp.xml -o ./tmp.plist
    defaults import clowwindy.ShadowsocksX ./tmp.plist
    rm tmp.xml tmp.xml.bak tmp.plist
    echo "done! please restart shadowsocks!"
else
    echo "can not find shadowsocks.plist or it's empty!"
    exit 1
fi



