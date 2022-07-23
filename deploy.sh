#!/bin/bash

set -e
set -o pipefail

TIME=$(date "+%Y%m%d_%H%M%S")
LOGDIR=/home/isucon/logs/${TIME}    # log dir

##############################################################
SERVICE=isuports
SYSTEMD_SERVICE=${SERVICE:-isucari} # systemd app service name
WORKDIR=/home/isucon     # app root dir 
GITROOT=${WORKDIR}/webapp           # git managed root dir
WEBROOT=${WORKDIR}/webapp           # webapp root dir
APPROOT=${WEBROOT}/go               # application root dir [make,make clean]
##############################################################

BRANCH=${BRANCH:-$(git rev-parse --abbrev-ref HEAD)}
COMMIT=$(git rev-parse --short HEAD)

echo -e "!!!!!!!!! RELOAD START !!!!!!!!!\nSTART=$TIME\nCOMMIT=$COMMIT"

# checkout current branch
git fetch origin
git reset --hard $BRANCH
git pull origin $BRANCH

echo ":: BUILD APP         ====>"
cd $APPROOT
make clean
make
cd -

echo
echo ":: CLEAR LOGS        ====>"
sudo truncate -s 0 -c /var/log/nginx/access.log
sudo bash -c ':>/var/log/mysql/mysql-slow.log'
if [ "$(pgrep mysql | wc -l)" != "0" ]; then
	sudo mysqladmin flush-logs
fi

echo
echo ":: COPY CONFIGS      ====>"
if [ -e etc/sysctl.d/99-isucon.conf ]; then
	cp etc/sysctl.d/99-isucon.conf /etc/sysctl.d/99-isucon.conf
fi
sudo sysctl -p /etc/sysctl.d/99-isucon.conf

# import configs
sudo chown -R root:root $GITROOT/etc/nginx
sudo chown -R root:root $GITROOT/etc/mysql
sudo cp -r $GITROOT/etc/nginx/* /etc/nginx
sudo cp -r $GITROOT/etc/mysql/* /etc/mysql
sudo chown -R isucon:isucon $GITROOT/etc/nginx
sudo chown -R isucon:isucon $GITROOT/etc/mysql

echo
echo ":: RESTART SERVICES  ====>"
set +e
pkill -f pprof
set -e
sudo systemctl daemon-reload
sudo systemctl restart nginx
sudo systemctl restart mysql
sudo systemctl restart ${SYSTEMD_SERVICE}

#go tool pprof -seconds 80 -http=0.0.0.0:1080 http://localhost:6060/debug/pprof/profile &

echo
echo ":: DROP CACHE        ====>"
sudo bash -c 'sync; echo 3 > /proc/sys/vm/drop_caches'

cd $GITROOT
ENDTIME=$(date "+%Y%m%d_%H%M%S")
echo -e "!!!!!!!!! RELOAD END AT $ENDTIME !!!!!!!!!"
