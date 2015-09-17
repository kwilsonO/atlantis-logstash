#USED TO DELETE OLDER FILES
DATADIR="${LS_REPO_ROOT}/data"
SUPDIR="${DATADIR}/supervisors"
CONDIR="${DATADIR}/containers"

if [[ ! -d $CONDIR ]]; then
	mkdir -p $CONDIR
fi

if [[ ! -d $SUPDIR ]]; then
	mkdir -p $SUPDIR
fi

for d in $CONDIR/*; do
	if [ -d $d ]; then
		cd $d
		(ls -t | head -n 5; ls)|sort|uniq -u|xargs --no-run-if-empty rm 
	fi
done

cd $SUPDIR
(ls -t | head -n 5; ls)|sort|uniq -u|xargs --no-run-if-empty rm
