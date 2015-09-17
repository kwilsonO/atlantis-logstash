myname="$(cat /root/atlantis-analytics/localname)"

echo "${myname} Clear-logs:"

echo "Clearing logs..."
rm /var/log/atlantis/logstash/err.log
rm /var/log/atlantis/logstash/out.log
