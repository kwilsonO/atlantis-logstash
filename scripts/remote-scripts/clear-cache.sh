CONF_FILE="${LS_REPO_ROOT}/atlantis.config"

#read config file
source "${CONF_FILE}"


echo "${LS_NAME} : ${LS_COMPONENT_TYPE} Status:"

echo ".sincedb files to be deleted:"
echo "$(ls ${LS_SINCEDB}/.sincedb*)"
echo "Deleting .sincedb file..."
rm "${LS_SINCEDB}/.sincedb*"
