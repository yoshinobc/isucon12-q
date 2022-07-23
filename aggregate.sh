#!/bin/bash

set -e
set -o pipefail

TIME=$(date "+%Y%m%d_%H%M%S")
LOGDIR=/home/isucon/logs/${TIME}    # log dir

BRANCH=${BRANCH:-$(git rev-parse --abbrev-ref HEAD)}
COMMIT=$(git rev-parse --short HEAD)

slack_code_block='```'

echo -e "!!!!!!!!! LOG START !!!!!!!!!\nSTART=$TIME\nCOMMIT=$COMMIT" | notify_slack

echo
echo ":: BACKUP            ====>"
mkdir -p $LOGDIR
if [ -e /var/log/mysql/mysql-slow.log ]; then
        sudo cp /var/log/mysql/mysql-slow.log ${LOGDIR}/mysql-slow.log.back
fi

if [ -e /var/log/nginx/access_log ]; then
        sudo cp /var/log/nginx/access.log ${LOGDIR}/nginx_access.log.back
fi

echo
echo '`:: ACCESS LOG        ====>`' | notify_slack
sudo alp ltsv -c /home/isucon/alp.yml > ${LOGDIR}/nginx_access.log.${TIME}
cat <(echo $slack_code_block) ${LOGDIR}/nginx_access.log.${TIME} <(echo $slack_code_block) | notify_slack

echo '`:: SLOW QUERY DIGEST ====>`' | notify_slack
sudo pt-query-digest /var/log/mysql/mysql-slow.log > ${LOGDIR}/mysql_slow.log.${TIME}
cat <(echo $slack_code_block) <(head -n30 ${LOGDIR}/mysql_slow.log.${TIME}) <(echo $slack_code_block) | notify_slack
echo -e "LOGTIME=$TIME\nCOMMIT=$COMMIT\n!!!!!!!!! LOG END !!!!!!!!!" | notify_slack
