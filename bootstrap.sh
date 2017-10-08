#!/bin/bash +x

PRJ_NAME=website
DOMAIN=.me
EMAIL_ADDR=grigori.kartashyan@gmail.com
ERROR_LOG_FILE=error.log
CUSTOM_LOG_FILE=custom.log

APACHE_PATH=/etc/apache2
APACHE_DEFAULT_CONF=${APACHE_PATH}/sites-available/000-default.conf
PRJ_APACHE_CONF=${APACHE_PATH}/sites-available/${PRJ_NAME}${DOMAIN}.conf
APACHE_CONF=${APACHE_PATH}/apache2.conf

IP_ADDRESS=`ifconfig |grep -A 2 eth1 |grep "inet addr" |awk '{print $2}'|awk -F ":" '{print $2}'`
LOG_PATH=/var/www/logs
PRJ_PATH=/var/www
REPO_NAME=${PRJ_NAME}${DOMAIN}.git
REPO_PATH=/repos/${REPO_NAME}
LIVE_PATH=${PRJ_PATH}/${PRJ_NAME}
GROUP_NAME='vagrant'

apt-get update
apt-get -y install git
apt-get -y install python-pip
pip install Django==1.11.6
apt-get -y install apache2
apt-get -y install python-setuptools
apt-get -y install libapache2-mod-wsgi

mkdir -p ${REPO_PATH}
cd ${REPO_PATH}
git init --bare

echo "#!/bin/sh" | tee -a ${REPO_PATH}/hooks/post-receive
echo "git --work-tree=${LIVE_PATH} --git-dir=${REPO_PATH} checkout -f" | tee -a ${REPO_PATH}/hooks/post-receive
#sed -i '/TEXT_TO_BE_REPLACED/c\This line is removed by the admin.' /tmp/foo
echo "find ${PRJ_PATH}/${PRJ_NAME} -name settings.py -exec sed -i \"s/ALLOWED_HOSTS\\ \\=\\ \\[\\]/ALLOWED_HOSTS\\ \\=\\ \\[\\'${IP_ADDRESS}\\'\\,\ \\'localhost\\'\\,u\\'${PRJ_NAME}${DOMAIN}\\'\\,\ \\'127\\.0\\.0\\.1\\'\\]/g\" {} \\;" | tee -a ${REPO_PATH}/hooks/post-receive
chmod +x ${REPO_PATH}/hooks/post-receive

chgrp -R ${GROUP_NAME} ${REPO_PATH}
chmod -R g+rwX ${REPO_PATH}
find ${REPO_PATH} -type d -exec chmod g+s '{}' +

mkdir -p ${LOG_PATH}
chmod 777 ${LOG_PATH}

mkdir -p ${PRJ_PATH}/${PRJ_NAME}
chmod 777 ${PRJ_PATH}/${PRJ_NAME}

echo "<VirtualHost *:80>" | tee ${PRJ_APACHE_CONF}
echo "        ServerName ${PRJ_NAME}${DOMAIN}" | tee -a ${PRJ_APACHE_CONF}
echo "        ServerAlias www.${PRJ_NAME}${DOMAIN}" | tee -a ${PRJ_APACHE_CONF}
echo "        ServerAdmin ${EMAIL_ADDR}" | tee -a ${PRJ_APACHE_CONF}
echo "        DocumentRoot ${PRJ_PATH}/${PRJ_NAME}" | tee -a ${PRJ_APACHE_CONF}
echo "        WSGIScriptAlias / ${PRJ_PATH}/${PRJ_NAME}/${PRJ_NAME}/wsgi.py" | tee -a ${PRJ_APACHE_CONF}
echo "        ErrorLog ${LOG_PATH}/${ERROR_LOG_FILE}" | tee -a ${PRJ_APACHE_CONF}
echo "        CustomLog ${LOG_PATH}/${CUSTOM_LOG_FILE} combined" | tee -a ${PRJ_APACHE_CONF}
echo "</VirtualHost>" | tee -a ${PRJ_APACHE_CONF}

#Enable site
ln -s ${PRJ_APACHE_CONF} ${APACHE_PATH}/sites-enabled/${PRJ_NAME}${DOMAIN}.conf

echo "WSGIPythonPath ${PRJ_PATH}/${PRJ_NAME}" | tee -a ${APACHE_CONF}

service apache2 restart
echo "Server address is ${IP_ADDRESS}"
echo "In your project add this remote: 'git remote add live ssh://vagrant@${IP_ADDRESS}${REPO_PATH}' "
echo "Use password 'vagrant' "
echo "Also you should add '${IP_ADDRESS}	${PRJ_NAME}${DOMAIN}' mapping in /etc/hosts file"
echo "Now you can reach the site by typing in browser ${PRJ_NAME}${DOMAIN}"
