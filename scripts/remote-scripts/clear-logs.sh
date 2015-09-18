CONF_FILE="${LS_REPO_ROOT}/atlantis.config"

#read config file
source "${CONF_FILE}"

echo "${LS_NAME} : ${LS_COMPONENT_TYPE} Clear-logs:"

echo "Clearing logs..."
rm $LS_LOG_PATH/err.log
rm $LS_LOG_PATH/out.log
