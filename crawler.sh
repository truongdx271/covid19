#!/bin/bash
# Worldometers COVID-19 Telegram Alert
# By github.com/panophan

COUNTRY="Vietnam"
TELEGRAM_API_KEY="<set-your-api-key-here>"
TELEGRAM_CHAT_ID="<set-chat-id-here>"

CURRENTDIR="$(cd "$(dirname "$0")"; pwd)"
LASTUPDATEFILE="${CURRENTDIR}/.worldometers-corona.log"

function sendTelegram() {
	printf "Worldometers COVID-19 Alert\n\n" > ${CURRENTDIR}/worldometers-data.tmp
	printf "**$COUNTRY** COVID-19 new reports\n\n" >> ${CURRENTDIR}/worldometers-data.tmp
	printf '```\n' >> ${CURRENTDIR}/worldometers-data.tmp
	printf "Total Cases  : $1\n" >> ${CURRENTDIR}/worldometers-data.tmp
	printf "New Cases    : $2\n" >> ${CURRENTDIR}/worldometers-data.tmp
	printf "Total Deaths : $3\n" >> ${CURRENTDIR}/worldometers-data.tmp
	printf "New Deaths   : $4\n" >> ${CURRENTDIR}/worldometers-data.tmp
	printf "Recovered    : $5\n" >> ${CURRENTDIR}/worldometers-data.tmp
	printf "Active Cases : $6\n" >> ${CURRENTDIR}/worldometers-data.tmp
	printf '```\n' >> ${CURRENTDIR}/worldometers-data.tmp
	printf "Data by worldometers.info\n" >> ${CURRENTDIR}/worldometers-data.tmp
	cat ${CURRENTDIR}/worldometers-data.tmp
	echo ""
	urldata=$(python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])" "$(cat ${CURRENTDIR}/worldometers-data.tmp)")
	rm ${CURRENTDIR}/worldometers-data.tmp
	python ${CURRENTDIR}/pusher.py $urldata
}

HTMLDUMP="/tmp/wom-coronavirus.html"
echo '<table>' > ${HTMLDUMP}.tmp
curl -s "https://www.worldometers.info/coronavirus/" | sed ':a;N;$!ba;s/\n/ /g' | sed 's/<tr/\n<tr/g' | sed 's/<\/tr>/<\/tr>\n/g' | grep '<tr' | grep "<th \|${COUNTRY}" >> ${HTMLDUMP}.tmp
echo '</table>' >> ${HTMLDUMP}.tmp
if [[ -f ${HTMLDUMP} ]]; then
	rm ${HTMLDUMP}
fi
##### REFORMATING ######
cat ${HTMLDUMP}.tmp | sed 's/<td[^>]*>/<td>/g' | sed 's/<th[^>]*>/<th>/g' | sed 's/<tr[^>]*>/<tr>/g' | sed 's/<br \/>/ /g' | sed 's/> />/g' | sed 's/ </</g' >> ${HTMLDUMP}.tmpx
rm ${HTMLDUMP}.tmp
cat ${HTMLDUMP}.tmpx | sed 's/<!--/\n<!--/g' | sed 's/-->/-->\n/g' | grep -v '<!--' | sed ':a;N;$!ba;s/\n/ /g' | sed 's/<tr/\n<tr/g' | sed 's/ </</g' | sed 's/> />/g' >> ${HTMLDUMP}.tmp
rm ${HTMLDUMP}.tmpx
cat ${HTMLDUMP}.tmp | sed 's/<td>  */<td>/g' | sed 's/<td><\/td>/<td>-<\/td>/g' >> ${HTMLDUMP}.tmpx
mv ${HTMLDUMP}.tmpx ${HTMLDUMP}
########################

TC=$(cat ${HTMLDUMP} | grep -Po '<td>\K.*?(?=<\/td>)' | head -2 | tail -1)
NC=$(cat ${HTMLDUMP} | grep -Po '<td>\K.*?(?=<\/td>)' | head -3 | tail -1)
TD=$(cat ${HTMLDUMP} | grep -Po '<td>\K.*?(?=<\/td>)' | head -4 | tail -1)
ND=$(cat ${HTMLDUMP} | grep -Po '<td>\K.*?(?=<\/td>)' | head -5 | tail -1)
RC=$(cat ${HTMLDUMP} | grep -Po '<td>\K.*?(?=<\/td>)' | head -6 | tail -1)
AC=$(cat ${HTMLDUMP} | grep -Po '<td>\K.*?(?=<\/td>)' | head -7 | tail -1)

if [[ ! -z ${TC} ]]; then
	if [[ -f ${LASTUPDATEFILE} ]]; then
		CMP1=$(printf "${TC}|${NC}|${TD}|${ND}|${RC}|${AC}" | md5sum | awk '{print $1}')
		CMP2=$(md5sum ${LASTUPDATEFILE} | awk '{print $1}')
		if [[ ${CMP1} != ${CMP2} ]]; then
			sendTelegram "${TC}" "${NC}" "${TD}" "${ND}" "${RC}" "${AC}"
			printf "${TC}|${NC}|${TD}|${ND}|${RC}|${AC}" > ${LASTUPDATEFILE}
		fi
	else
		sendTelegram "${TC}" "${NC}" "${TD}" "${ND}" "${RC}" "${AC}"
		printf "${TC}|${NC}|${TD}|${ND}|${RC}|${AC}" > ${LASTUPDATEFILE}
	fi
fi
