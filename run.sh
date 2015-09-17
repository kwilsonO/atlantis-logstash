CONF_FILE_PATH="atlantis.conf"
REPO_NAME="atlantis-logstash"

if [[! -e $CONF_FILE_PATH]]; then 
	echo "No config file found, looking for atlantis.conf in the current run directory"
	exit 1
fi

echo "Reading config file..."
source "$CONF_FILE_PATH"

if [[ "${LS_COMPONENT_TYPE}" != "router"]] && [[ "${LS_COMPONENT_TYPE}" != "manager" ]] && [[ "${LS_COMPONENT_TYPE}" != "supervisor" ]]; then
	echo "Component type: ${LS_COMPONENT_TYPE} not supported"
	exit 1
fi

if [[ "${LS_REGION}" == "us-east-1" ]] && [[ "${LS_ENVIROMENT}" == "" ]]; then
	echo "No enviroment specified for us-east-1, testflight or prod?"
	exit 1
else
	if [[ "${LS_INDEX_PREFIX}" != "" ]]; then
		echo "Overwriting ${LS_ENVIROMENT} index prefix with ${LS_INDEX_PREFIX}"
	else
		LS_INDEX_PREFIX="$LS_ENVIROMENT"
	fi
fi

#export now updated elastic search index prefix for later use
export LS_ELASTIC_PREFIX="${LS_INDEX_PREFIX}"


if [[ "${LS_ELASTIC_HOSTNAME}" == "" ]]; then
	echo "Elastic search hostname is required, please add to config"
	exit 1
fi

if [[ "${LS_ELASTIC_CLUSTERNAME}" == "" ]]; then
	echo "Elastic search clustername is required, please add to config"
	exit 1
fi



if [[ "${LS_NODE_NAME}" == "" ]]; then
	export LS_NAME="$(uname -n)"
else
	export LS_NAME="$LS_NODE_NAME"
fi

#export the repo path and the repo name
export LS_REPO_ROOT="${LS_PATH}/${REPO_NAME}"
export LS_REPO_NAME="${REPO_NAME}"


if [[ "${LS_SINCEDB_DIR}" == "" ]]; then 
	export LS_SINCEDB="${LS_REPO_ROOT}"
else
	export LS_SINCEDB="${LS_SINCEDB_DIR}"
fi



RUNSCRIPTS="${LS_PATH}/${REPONAME}/scripts/run"
for f in $RUNSCRIPTS/*.sh; do

	echo "Executing run script: $f"
	bash $f

done
