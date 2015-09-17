myname="$(cat /root/atlantis-analytics/localname)"

echo "${myname} Tail-out:"
tail -n 100 /var/log/atlantis/logstash/out.log
