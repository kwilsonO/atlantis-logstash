#read config file
source "${LS_REPO_ROOT}/atlantis.config"

LSCONFIGDIR="${LS_REPO_ROOT}/config"
LSTEMPLATESDIR="${LSCONFIGDIR}/templates"
LSCONFIGFILE="atlantis-${LS_COMPONENT_TYPE}-logstash.conf"
LSBINDIR="${LS_REPO_ROOT}/logstash-${LS_VERSION}/bin"

#Instance Data gathering

URL="http://169.254.169.254/latest/meta-data"
declare -A INSTANCEDATA
INSTANCEDATA["#INSTFULLHOST#"]="hostname"
INSTANCEDATA["#INSTID#"]="instance-id"
INSTANCEDATA["#INSTTYPE#"]="instance-type"
INSTANCEDATA["#INSTLOCALHST#"]="local-hostname"
INSTANCEDATA["#INSTLOCALIPV4#"]="local-ipv4"
INSTANCEDATA["#INSTMACADDR#"]="mac"
INSTANCEDATA["#INSTPUBHOST#"]="public-hostname"
INSTANCEDATA["#INSTPUBIP#"]="public-ipv4"
INSTANCEDATA["#INSTSECG#"]="security-groups"

declare -A NODEDATA
NODEDATA["#INDEXPREFIX#"]="${LS_ELASTIC_PREFIX}"
NODEDATA["#ESHOSTNAME#"]="${LS_ELASTIC_HOSTNAME}"
NODEDATA["#ESCLUSTERNAME#"]="${LS_ELASTIC_CLUSTERNAME}"
NODEDATA["#LSREPOROOT#"]="${LS_REPO_ROOT}"

if [ -e "${LSCONFIGDIR}/${LSCONFIGFILE}" ]; then
	echo "Removing old conf file..."
		rm "${LSCONFIGDIR}/${LSCONFIGFILE}"
fi

#copy fresh template
echo "Copying fresh template and inserting values..."
cp ${LSTEMPLATESDIR}/${LSCONFIGFILE}.template ${LSCONFIGDIR}/${LSCONFIGFILE}

#download and insert instance data
for i in "${!INSTANCEDATA[@]}"
do
	VAL=$(curl -s "${URL}/${INSTANCEDATA[${i}]}")
	#replace any spaces with colon
	VAL=$(echo $VAL | sed 's/ /:/g')
	SEDSTR="s|${i}|${VAL}|g"
	sed -i $SEDSTR ${LSCONFIGDIR}/${LSCONFIGFILE} 
done

#insert node data
for i in "${!NODEDATA[@]}"
do
	SEDSTR="s|${i}|${NODEDATA[${i}]}|g"
	sed -i $SEDSTR ${LSCONFIGDIR}/${LSCONFIGFILE}
done
					
		
#Other Logstash run setup

#sincedb stuff
export SINCEDB_DIR="${LS_SINCEDB}"

if [ -e "${LS_LOG_GPATH}/out.log" ]; then
	rm "${LS_LOG_PATH}/out.log"
fi
if [ -e "${LS_LOG_PATH}/err.log" ]; then
	rm "${LS_LOG_PATH}/err.log"
fi

$LSBINDIR/logstash -f "${LSCONFIGDIR}/${LSCONFIGFILE}" > $LS_LOG_PATH/out.log 2> $LS_LOG_PATH/err.log &
