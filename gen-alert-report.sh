#!/bin/bash
###################################################################
emf=`date +%B`
curyear=`date +%Y`
curmon=`date +%m`
mon=`date "+%b %Y"`
hardlink=https://www.govcert.gov.hk/en/rss_security_alerts.xml
msg_file=/tmp/get_alerts/info/`date +%F`-alert.msg
atf=/tmp/get_alerts/info/all_title_msg
acve=/tmp/get_alerts/info/all_cvenum.msg
alink=/tmp/get_alerts/info/link.msg
aan=/tmp/get_alerts/info/all_alert_num.msg
[ ! -d /tmp/get_alerts/info ] && mkdir -p /tmp/get_alerts/info || echo "alreadt exsit"
curl -s $hardlink | egrep -B15 "$mon" | egrep "pubDate|title|guid" > $msg_file
egrep guid $msg_file | sed  "s/<guid>//g" | sed  "s#</guid>##g" | awk '{print $1}' > $alink

#egrep title $msg_file | cut -d ":" -f2  | sed "s#</title>##g" > $atf
#egrep title $msg_file | egrep -o "[a-Z][0-9][0-9]-$curmon-[0-9][0-9]" > $acve
#cat $alink | egrep -o "[0-9]{4,}" > $aan
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
egrep "<title>" $nf | egrep -o "[a-Z][0-9]{2,}-[0-9]{2,}-[0-9]{2,}" > $cnf
egrep "<title>" $nf | cut -d ":" -f2  | sed "s#</title>##g" > $descf
egrep -i "successful" $nf  > $detailf
d1=`egrep -o "[0-9]{2} $emf $curyear" $nf`
d2=$(date -d "$d1" +"%d/%m/%Y")
echo $d2 ; echo $alnum 
cat $cnf $descf $detailf
echo
done
