CONF_FILE_PATH="atlantis.config"
REPO_NAME="atlantis-logstash"


usage()
{

cat <<-EOF
        usage: $0 options

        This script builds a config file with the passed information and sets up logstash.

        Options:
		Default:	
		-R      Which Region to use (us-east-1, eu-west-1, ap-northeast-vpc, etc)
		-e	Which enviroment to use (testflight, prod) us-east only
		-c	Which type of component being set up (manager, router, supervisor)
		-s	Which sub region the supervisor is in (a, d, e)

		Additional:
		-p	The path for the logstash install, needs to be where this is run (default is /opt/atlantis/logstash)
		-o	The path for logstash to log to (default is /var/log/atlantis/logstash)
		-n	The node name of this logstash instance (purely a monitoring tool)
		-i	The index prefix for elastic search (default is enviroment in us-east and none everywhere else)
		-v	The logstash version to use, default is (1.5.4)
		-u	The Elasticsearch hostname (default is master1.elasticsearch.REGION.atlantis.services.ooyala.com)
		-x	The Elasticsearch clustername (default is elasticsearch-atlantis)
		-d	The sincedb location (default is repo root)
		-l	The logstash download url (default is https://download.elastic.co/logstash/logstash/logstash-VERSION.tar.gz

		-h      Show this message

EOF
}

if [ $# -ne 0 ]; then
	OPTREGION=""
	OPTENV=""
	OPTCOMP=""
	OPTSUBREG=""
	OPTPATH="/opt/atlantis/logstash"
	OPTLOGPATH="/var/log/atlantis/logstash"
	OPTNAME=""
	OPTESPREF=""
	OPTLSVER="1.5.4"
	OPTESHN="master1.elasticsearch.\${LS_REGION}.atlantis.services.ooyala.com"
	OPTESCN="elasticsearch-atlantis"
	OPTSDBDIR=""
	OPTLSDLURL="https://download.elastic.co/logstash/logstash/logstash-\${LS_VERION}.tar.gz"

	#handle optional param line args
	while getopts R:e:c:s:p:o:n:i:v:u:x:d:l:h opt; do
		#if a non empty string was passed or health flag
		if [ "${OPTARG}" != "" ] || [ "${opt}" == "h" ] ; then

			case $opt in
				R)
					OPTREGION=$OPTARG
					;;
				e)
					OPTENV=$OPTARG
					;;
				c)
					OPTCOMP=$OPTARG
					;;
				s)
					OPTSUBREG=$OPTARG
					;;
				p)
					OPTPATH=$OPTARG
					;;
				o)
					OPTLOGPATH=$OPTARG
					;;
				n)
					OPTNAME=$OPTARG
					;;
				i)
					OPTESPREF=$OPTARG
					;;
				v)
					OPTLSVER=$OPTARG
					;;
				u)
					OPTESHN=$OPTARG
					;;
				x)
					OPTESCN=$OPTARG
					;;
				d)
					OPTSDBDIR=$OPTARG
					;;

				l)
					OPTLSDLURL=$OPTARG
					;;
				h)
					usage
					exit 0
					;;
				\?)
					echo "Option $opt not recognized..."
					exit 1
			esac
		fi
	done

	if [[ "${OPTCOMP}" == "" ]]; then
		echo "No component specified, please choose either manager, router, or supervisor for the -c flag"
		exit 1		
	fi

	if [[ "${OPTREGION}" == "" ]]; then
		echo "No region specified, please enter a region to the -R flag"
		exit 1
	fi

	if [[ "${OPTREGION}" == "us-east-1" ]]; then
		if [[ "${OPTENV}" == "" ]]; then
			echo "No enviroment specified in us-east-1, please pick either testflight or prod for -e flag"
			exit 1
		fi
	fi

	OPTTEMPLATEDIR=""
	if [[ "${OPTPATH}" == "" ]]; then
		OPTPATH="/opt/atlantis/logstash/${REPO_NAME}"
	else
		OPTPATH="${OPTPATH}/${REPO_NAME}"
	fi
		
	OPTTEMPLATEDIR="${OPTPATH}/template-configs"
	if [[ ! -d $OPTTEMPLATEDIR ]]; then
		echo "Directory ${OPTTEMPLATEDIR} does not exist, please fix config"
		exit 1
	fi

	REGSTR=""
	if [[ "${OPTREGION}" == "us-east-1" ]]; then
		REGSTR=".${OPTENV}"
	fi

	#cp template to root dir
	cp "${OPTTEMPLATEDIR}/atlantis.${OPTREGION}${REGSTR}.config" "${OPTPATH}/atlantis.config"

	#find and replace vars in config
	sed -i.bak -E "s/LS_PATH=\".+?\"/LS_PATH=\"${OPTPATH}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_LOG_PATH=\".+?\"/LS_LOG_PATH=\"${OPTPATH}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_REGION=\".+?\"/LS_REGION=\"${OPTREGION}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_ENVIROMENT=\".+?\"/LS_ENVIROMENT=\"${OPTENV}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_COMPONENT_TYPE=\".+?\"/LS_COMPONENT_TYPE=\"${OPTCOMP}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_SUB_REGION=\".+?\"/LS_SUB_REGION=\"${OPTSUBREG}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_NODE_NAME=\".+?\"/LS_NODE_NAME=\"${OPTNAME}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_INDEX_PREFIX=\".+?\"/LS_INDEX_PREFIX=\"${OPTESPREF}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_VERSION=\".+?\"/LS_VERSION=\"${OPTLSVER}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_ELASTIC_HOSTNAME=\".+?\"/LS_ELASTIC_HOSTNAME=\"${OPTESHN}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_ELASTIC_CLUSTERNAME=\".+?\"/LS_ELASTIC_CLUSTERNAME=\"${OPTESCN}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_SINCEDB_DIR=\".+?\"/LS_SINCEDB_DIR=\"${OPTSDBDIR}\"/g" $OPTPATH/atlantis.config
	sed -i.bak -E "s/LS_DL_URL=\".+?\"/LS_DL_URL=\"${OPTLSDLURL}\"/g" $OPTPATH/atlantis.config




	 

fi

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
