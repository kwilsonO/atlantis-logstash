myid="$(ps -ef | grep 'logstash-1.5.3' | grep -v grep | awk '{print $2}')"
myname="$(cat /root/atlantis-analytics/localname)"
REPOTYPE="${myname%%-*}"
echo "${myname} Status:"

if [ "${myid}" = "" ]; then 

	echo "No logstash process found."
else

	echo "[${myid}] atlantis-logstash-${REPOTYPE} running."

fi
