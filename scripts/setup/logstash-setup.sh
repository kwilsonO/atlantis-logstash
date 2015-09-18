#read config file
source "${LS_REPO_ROOT}/atlantis.config"

wget "${LS_DL_URL}"
tar -xzf "logstash-${LS_VERSION}.tar.gz"
rm "logstash-${LS_VERSION}.tar.gz"

if [ ! -d "${LS_LOG_PATH}" ]; then 
	mkdir -p ${LS_LOG_PATH}
fi
