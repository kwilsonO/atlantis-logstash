URL="https://0.0.0.0:443"
LOGINURL="${URL}/login"
USAGEURL="${URL}/usage"
USER=$(cat $LS_REPO_ROOT/secrets/username.data)
PASSWORD=$(cat $LS_REPO_ROOT/secrets/password.data)
SECRETPATH="${LS_REPO_ROOT}/secrets/secret.data"
NOWTIME="$(TZ="UTC" date +%m-%d-%y-%H-%M-%S)"
USAGEDATAPATH="${LS_REPO_ROOT}/data/usage-cmd-out${NOWTIME}.data"
USERSECRETPARM="User=${USER}"

#LOGIN and get secret
curl -s -k -XPOST "${LOGINURL}?User=${USER}&Password=${PASSWORD}" > $LS_REPO_ROOT/login-output.tmp
MYSECRET=$(cat $LS_REPO_ROOT/login-output.tmp | jq ".Secret" | sed 's/"//g') 

echo $MYSECRET > $SECRETPATH
rm $LS_REPO_ROOT/login-output.tmp

#BUILD USER/SEcret PARM
USERSECRETPARM="${USERSECRETPARM}&Secret=${MYSECRET}"

#CURL API FOR USAGE DATA
curl -s -k -XGET "${USAGEURL}?${USERSECRETPARM}" > $USAGEDATAPATH

#OUTPUT A LIST OF HOSTS TO FILE
TMPOUT=$(cat $USAGEDATAPATH | jq '.Usage[].Host')
LENGTH=$(cat $USAGEDATAPATH | jq '.Usage[].Host | length')

if [ "$LENGTH" = "0" ] || [ "$TMPOUT" = "jq: error: Cannot iterate over null" ]; then
	echo "No Supervisor Hosts found in Usage Data or error parsing..."
	exit 1
fi
cat $USAGEDATAPATH | jq '.Usage[].Host' > "$LS_REPO_ROOT/allhosts${NOWTIME}.tmp"

if [ ! -d $LS_REPO_ROOT/data ]; then 
	mkdir $LS_REPO_ROOT/data
fi

if [ ! -d $LS_REPO_ROOT/data/supervisors ]; then
	mkdir $LS_REPO_ROOT/data/supervisors
fi

#FILTER OUT CONTAINER DATA, ONLY GET TOTAL SUPERVISOR METRICS
TMPOUT=$(cat $USAGEDATAPATH | jq '.Usage[]')
LENGTH=$(cat $USAGEDATAPATH | jq '.Usage[] | length')
if [ "$LENGTH" = "0" ] || [ "$TMPOUT" = "jq: error: Cannot iterate over null" ]; then
	echo "Usage data empty/error when trying to get supervisor metrics..."
	exit 1 
fi

cat $USAGEDATAPATH | jq '.Usage[]' | jq 'del(.Containers)' | jq 'tostring' | sed 's/\\//g' | sed 's/"//g' > "${LS_REPO_ROOT}/data/supervisors/super${NOWTIME}.data"


if [ ! -d $LS_REPO_ROOT/data/containers ]; then
	mkdir $LS_REPO_ROOT/data/containers
fi
#LOOP THROUGH EACH HOST AND GRAB CONTAINER INFO
while read p; do
	tmp=$(echo "${p//\"}")

	if [ ! -d $LS_REPO_ROOT/data/containers/$tmp ]; then 
		mkdir $LS_REPO_ROOT/data/containers/$tmp
	fi

	TMPOUT=$(cat $USAGEDATAPATH | jq ".Usage[${p}].Containers[]")
	LENGTH=$(cat $USAGEDATAPATH | jq ".Usage[${p}].Containers[] | length")
	if [ "$LENGTH" = "0" ] || [ "$TMPOUT" = "jq: error: Cannot iterate over null" ]; then
		echo "No data or error when getting info for: ${p}  ...."
		exit 1
	fi
	cat $USAGEDATAPATH | jq ".Usage[${p}].Containers[]" | jq 'tostring' | sed 's/\\//g' | sed 's/"//g' > "${LS_REPO_ROOT}/data/containers/${tmp}/containers${NOWTIME}.data"
done < "$LS_REPO_ROOT/allhosts${NOWTIME}.tmp"

rm "${LS_REPO_ROOT}/allhosts${NOWTIME}.tmp"
rm "${LS_REPO_ROOT}/data/usage-cmd-out${NOWTIME}.data"

