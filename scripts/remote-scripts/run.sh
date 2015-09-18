CONF_FILE="${LS_REPO_ROOT}/atlantis.config"

#read config vars
source "$CONF_FILE"

echo "${LS_NAME} : ${LS_COMPONENT_TYPE} Run:"

echo "Starting logstash run script..."
bash $LS_REPO_ROOT/run.sh
