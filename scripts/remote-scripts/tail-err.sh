myname="$(cat /root/atlantis-analytics/localname)"

echo "${myname} Tail-err:"
tail -n 100 /var/log/atlantis/logstash/err.log
