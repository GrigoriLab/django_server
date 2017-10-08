#!/bin/bash +x

PRJ_NAME=grigori
DOMAIN=.me
EMAIL_ADDR=grigori.kartashyan@gmail.com
ERROR_LOG_FILE=error.log
CUSTOM_LOG_FILE=custom.log
APACHE_DEFAULT_CONF=/etc/apache2/sites-available/000-default.conf
APACHE_CONF=/etc/apache2/apache2.conf
IP_ADDRESS=`ifconfig |grep -A 2 eth1 |grep "inet addr" |awk '{print $2}'|awk -F ":" '{print $2}'`
LOG_PATH=/var/www/logs
PRJ_PATH=/var/www

apt-get update
apt-get -y install python-pip
pip install Django==1.11
apt-get -y install apache2
apt-get -y install python-setuptools
apt-get -y install libapache2-mod-wsgi

mkdir -p ${LOG_PATH}
chmod 777 ${LOG_PATH}

cd ${PRJ_PATH}
django-admin.py startproject ${PRJ_NAME}
find ${PRJ_PATH}/${PRJ_NAME} -name settings.py -exec sed -i "s/ALLOWED_HOSTS\ \=\ \[\]/ALLOWED_HOSTS\ \=\ \[\'${IP_ADDRESS}\'\, \'localhost\'\, \'127\.0\.0\.1\'\]/g" {} \;

echo "<VirtualHost *:80>" | tee ${APACHE_DEFAULT_CONF}
echo "        ServerName ${PRJ_NAME}${DOMAIN}" | tee -a ${APACHE_DEFAULT_CONF}
echo "        ServerAlias www.${PRJ_NAME}${DOMAIN}" | tee -a ${APACHE_DEFAULT_CONF}
echo "        ServerAdmin ${EMAIL_ADDR}" | tee -a ${APACHE_DEFAULT_CONF}
echo "        DocumentRoot ${PRJ_PATH}/${PRJ_NAME}" | tee -a ${APACHE_DEFAULT_CONF}
echo "        WSGIScriptAlias / ${PRJ_PATH}/${PRJ_NAME}/${PRJ_NAME}/wsgi.py" | tee -a ${APACHE_DEFAULT_CONF}
echo "        ErrorLog ${LOG_PATH}/${ERROR_LOG_FILE}" | tee -a ${APACHE_DEFAULT_CONF}
echo "        CustomLog ${LOG_PATH}/${CUSTOM_LOG_FILE} combined" | tee -a ${APACHE_DEFAULT_CONF}
echo "</VirtualHost>" | tee -a ${APACHE_DEFAULT_CONF}

echo "WSGIPythonPath ${PRJ_PATH}/${PRJ_NAME}" | tee -a ${APACHE_CONF}

service apache2 restart
echo "Server address is ${IP_ADDRESS}"

