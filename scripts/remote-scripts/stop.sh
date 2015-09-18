CONF_FILE="${LS_REPO_ROOT}/atlantis.config"

#read config file
source "${CONF_FILE}"

echo "${LS_NAME} : ${LS_COMPONENT_TYPE} Stop:"

echo "Stopping logstash..."
myprocid="$(ps -ef | grep "logstash-${LS_VERSION}" | grep -v grep | awk '{print $2}')"

if [ "${myprocid}" = "" ]; then 

	echo "No logstash process found."
else

	echo "Killing proccess pid: ${myprocid}..."
	kill -9 $myprocid

fi
