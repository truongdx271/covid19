#!/bin/bash
# By Truongdx271

COUNTRY="Vietnam"
TELEGRAM_API_KEY="1029193933:AAEqZp7fF5qY0PMUJgyFb6jt8V3pAWaEITQ"
TELEGRAM_CHAT_ID="-484691617"

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
	printf "executing python\n" >> ${CURRENTDIR}/cr.log
	python ${CURRENTDIR}/covid.py $TELEGRAM_API_KEY $TELEGRAM_CHAT_ID $urldata
}

RAW=$(curl -s "https://www.worldometers.info/coronavirus/" | sed 's/<tr/\n<tr/g' | grep "${COUNTRY}" | grep '<tr style="">' | sed 's/<td/\n<td/g' | grep ^'<td' | sed 's/<!--//g' | sed 's/-->//g')

TC=$(echo "${RAW}" | head -2 | tail -1 | grep -Po '>\K.*?(?=<)' | sed 's/^ //g' | sed 's/ $//g' | sed 's/^$/-/g')
NC=$(echo "${RAW}" | head -4 | tail -1 | grep -Po '>\K.*?(?=<)' | sed 's/^ //g' | sed 's/ $//g' | sed 's/^$/-/g')
TD=$(echo "${RAW}" | head -5 | tail -1 | grep -Po '>\K.*?(?=<)' | sed 's/^ //g' | sed 's/ $//g' | sed 's/^$/-/g')
ND=$(echo "${RAW}" | head -6 | tail -1 | grep -Po '>\K.*?(?=<)' | sed 's/^ //g' | sed 's/ $//g' | sed 's/^$/-/g')
RC=$(echo "${RAW}" | head -7 | tail -1 | grep -Po '>\K.*?(?=<)' | sed 's/^ //g' | sed 's/ $//g' | sed 's/^$/-/g')
AC=$(echo "${RAW}" | head -9 | tail -1 | grep -Po '>\K.*?(?=<)' | sed 's/^ //g' | sed 's/ $//g' | sed 's/^$/-/g')

if [[ ! -z ${TC} ]]; then
	if [[ -f ${LASTUPDATEFILE} ]]; then
		printf "upper case\n" >> ${CURRENTDIR}/cr.log
		CMP1=$(printf "${TC}|${NC}|${TD}|${ND}|${RC}|${AC}" | md5sum | awk '{print $1}')
		CMP2=$(md5sum ${LASTUPDATEFILE} | awk '{print $1}')
		if [[ ${CMP1} != ${CMP2} ]]; then
			sendTelegram "${TC}" "${NC}" "${TD}" "${ND}" "${RC}" "${AC}"
			printf "${TC}|${NC}|${TD}|${ND}|${RC}|${AC}" > ${LASTUPDATEFILE}
		fi
	else
		printf "gonna send here\n" > cr.log
		sendTelegram "${TC}" "${NC}" "${TD}" "${ND}" "${RC}" "${AC}"
		printf "${TC}|${NC}|${TD}|${ND}|${RC}|${AC}" > ${LASTUPDATEFILE}
	fi
fi
