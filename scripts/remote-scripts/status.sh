CONF_FILE="${LS_REPO_ROOT}/atlantis.config"

#read in config
source "$CONF_FILE"

myprocid="$(ps -ef | grep "logstash-${LS_VERSION}" | grep -v grep | awk '{print $2}')"

#time running math
NOW=$(date +%s)
DIFF=$(($NOW-$LS_START_TIME))
TIMERUN=$(date -u -d @$DIFF +%H:%M:%S)
START=$(date -u -d @$LS_START_TIME +%c)

echo "${LS_NAME} : ${LS_COMPONENT_TYPE} Status:"

if [ "${myprocid}" = "" ]; then 

	echo "No logstash process found."
else

	echo "[${myprocid}] atlantis-logstash running for ${TIMERUN} since ${START}"

fi
