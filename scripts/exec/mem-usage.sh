#a script used to gather current mem usage
free -m | grep -E "Mem" | awk '{ print $2 "," $3 "," $4 }'
