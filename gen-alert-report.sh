#!/bin/bash
###################################################################
emf=`date +%B`
curyear=`date +%Y`
curmon=`date +%m`
[[ "$1" =~ ^([1-9]|1[0-2])$ ]] && echo "💡 提示：正在查看 $1 月份的 alert 資料..." &&  mon=$(date -d "$(date +%Y)-$1-01" "+%b %Y") || echo "💡 提示：未指定有效月份（參數需為 1 - 12）。預設查看當前月份的 alert 資料..." ; mon=$(date "+%b %Y")
hardlink=https://www.govcert.gov.hk/en/rss_security_alerts.xml
msg_file=/tmp/get_alerts/info/`date +%F`-alert.msg
atf=/tmp/get_alerts/info/all_title_msg
acve=/tmp/get_alerts/info/all_cvenum.msg
alink=/tmp/get_alerts/info/link.msg
aan=/tmp/get_alerts/info/all_alert_num.msg
curl -s $hardlink | egrep -B15 "$mon" | egrep "pubDate|title|guid" > $msg_file
egrep guid $msg_file | sed  "s/<guid>//g" | sed  "s#</guid>##g" | awk '{print $1}' > $alink

#############################################
for link in `cat $alink`
do
alnum=`echo $link  | egrep -o "[0-9]{4,}"` 
tp=/tmp/get_alerts/info
nf=/$tp/$alnum-all.msg
cnf=$tp/$alnum-cve.msg
descf=$tp/$alnum-desc.msg
detailf=$tp/$alnum-detailf.msg
link=${link%$'\r'}
curl -s $link -o $nf
egrep "<title>" $nf | egrep -o "[a-zA-Z][0-9]{2,}-[0-9]{2,}-[0-9]{2,}" > $cnf
egrep "<title>" $nf | cut -d ":" -f2  | sed "s#</title>##g" > $descf
egrep -i "successful" $nf  > $detailf
d1=`egrep -o "[0-9]{2} $emf $curyear" $nf`
d2=$(date -d "$d1" +"%d/%m/%Y")
echo $d2 ; echo $alnum 
cat $cnf $descf $detailf
echo
done
