CONF_FILE_PATH="atlantis.config"
REPO_NAME="atlantis-logstash"

if [[ ! -f $CONF_FILE_PATH ]]; then
        echo "No config file found, please use a pre-existing configuration or fill in the template in the template-configs folder"
	exit 1
fi

echo "Reading config file..."
source $CONF_FILE_PATH

if [[ "${LS_NODE_NAME}" == "" ]]; then
	export LS_NAME="$(uname -n)"
else
	export LS_NAME="${LS_NODE_NAME}"
fi

#export the repo path and the repo name
export LS_REPO_ROOT="${LS_PATH}/${REPO_NAME}"
export LS_REPO_NAME="${REPO_NAME}"

if [[ "${LS_SINCEDB_DIR}" == "" ]]; then
	export LS_SINCEDB="${LS_REPO_ROOT}"
else
	export LS_SINCEDB="${LS_SINCEDB_DIR}"
fi

SETUPSCRIPTS="${LS_REPO_ROOT}/scripts/setup"


for f in $SETUPSCRIPTS/*.sh; do

	echo "Executing setup script: $f"
	bash $f	
done
