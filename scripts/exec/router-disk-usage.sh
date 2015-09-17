#script to get current disk space usage, etc

OUTPUT=$(df -m | grep -E '/dev/xvda|/dev/xvdb' | awk '{ print $1 "," $2 "," $3 "," $4 "," $5 "," $6 }')
#gets rid of newline
echo $OUTPUT
