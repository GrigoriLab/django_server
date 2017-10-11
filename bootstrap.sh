#!/bin/bash +x

PRJ_NAME=website
DOMAIN=.me
EMAIL_ADDR=grigori.kartashyan@gmail.com
ERROR_LOG_FILE=error.log
CUSTOM_LOG_FILE=custom.log
WEB_SITE=${PRJ_NAME}${DOMAIN}
PRJ_PATH=/home/vagrant
LOG_PATH=${PRJ_PATH}/${PRJ_NAME}/logs

APACHE_PATH=/etc/apache2
PRJ_APACHE_CONF=${APACHE_PATH}/sites-available/${PRJ_NAME}${DOMAIN}.conf
APACHE_CONF=${APACHE_PATH}/apache2.conf

IP_ADDRESS=`ifconfig |grep -A 2 eth1 |grep "inet addr" |awk '{print $2}'|awk -F ":" '{print $2}'`
REPO_NAME=${WEB_SITE}.git
REPO_PATH=/repos/${REPO_NAME}
LIVE_PATH=${PRJ_PATH}/${PRJ_NAME}
GROUP_NAME='vagrant'

mkdir -p ${LOG_PATH}
mkdir -p ${REPO_PATH}
mkdir -p ${PRJ_PATH}/${PRJ_NAME}

apt-get update
apt-get -y install git
apt-get -y install python-pip
pip install Django==1.11.6
apt-get -y install apache2
apt-get -y install python-setuptools
apt-get -y install libapache2-mod-wsgi

#Creating repository
cd ${REPO_PATH}
git init --bare
cd -

#Creating hook for copying files from repo to live directory.
echo "#!/bin/sh" | tee -a ${REPO_PATH}/hooks/post-receive
echo "git --work-tree=${LIVE_PATH} --git-dir=${REPO_PATH} checkout -f" | tee -a ${REPO_PATH}/hooks/post-receive
#sed -i '/TEXT_TO_BE_REPLACED/c\This line is removed by the admin.' /tmp/foo
echo "find ${PRJ_PATH}/${PRJ_NAME} -name settings.py -exec sed -i \"s/ALLOWED_HOSTS\\ \\=\\ \\[\\]/ALLOWED_HOSTS\\ \\=\\ \\[\\'${IP_ADDRESS}\\'\\,\ \\'localhost\\'\\,u\\'${WEB_SITE}\\'\\,\ \\'127\\.0\\.0\\.1\\'\\]/g\" {} \\;" | tee -a ${REPO_PATH}/hooks/post-receive

#Changing permitions 
chmod +x ${REPO_PATH}/hooks/post-receive
chmod 777 ${LOG_PATH}
chmod 777 ${PRJ_PATH}/${PRJ_NAME}
chgrp -R ${GROUP_NAME} ${REPO_PATH}
chmod -R g+rwX ${REPO_PATH}
find ${REPO_PATH} -type d -exec chmod g+s '{}' +


#Creating apache conf file for current site
echo "<VirtualHost *:80>" | tee ${PRJ_APACHE_CONF}
echo "        ServerName ${WEB_SITE}" | tee -a ${PRJ_APACHE_CONF}
echo "        ServerAlias www.${WEB_SITE}" | tee -a ${PRJ_APACHE_CONF}
echo "        ServerAdmin ${EMAIL_ADDR}" | tee -a ${PRJ_APACHE_CONF}
echo "        DocumentRoot ${PRJ_PATH}/${PRJ_NAME}" | tee -a ${PRJ_APACHE_CONF}
echo "        WSGIScriptAlias / ${PRJ_PATH}/${PRJ_NAME}/${PRJ_NAME}/wsgi.py" | tee -a ${PRJ_APACHE_CONF}
echo "        ErrorLog ${LOG_PATH}/${ERROR_LOG_FILE}" | tee -a ${PRJ_APACHE_CONF}
echo "        CustomLog ${LOG_PATH}/${CUSTOM_LOG_FILE} combined" | tee -a ${PRJ_APACHE_CONF}
echo "</VirtualHost>" | tee -a ${PRJ_APACHE_CONF}

#Enable current site
ln -s ${PRJ_APACHE_CONF} ${APACHE_PATH}/sites-enabled/${PRJ_NAME}${DOMAIN}.conf

#Updating apache.conf file
echo "WSGIPythonPath ${PRJ_PATH}/${PRJ_NAME}" | tee -a ${APACHE_CONF}
echo "ServerName localhost" | tee -a ${APACHE_CONF}

echo "<Directory ${PRJ_PATH}/${PRJ_NAME}>" | tee -a ${APACHE_CONF}
echo "        Options Indexes FollowSymLinks" | tee -a ${APACHE_CONF}
echo "        AllowOverride None" | tee -a ${APACHE_CONF}
echo "        Require all granted" | tee -a ${APACHE_CONF}
echo "</Directory>" | tee -a ${APACHE_CONF}


#Restarting Apache server
service apache2 restart

echo "Server address is ${IP_ADDRESS}"
echo "In your project add this remote: 'git remote add live ssh://vagrant@${IP_ADDRESS}${REPO_PATH}' and then push the project 'git push live master' "
echo "Use password 'vagrant' "
echo "Also you should add '${IP_ADDRESS}	${WEB_SITE}' mapping in /etc/hosts file"
echo "Now you can reach the site by typing in browser ${WEB_SITE}"
