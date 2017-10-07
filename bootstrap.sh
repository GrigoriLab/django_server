#!/bin/bash

apt-get update
#apt-get -y install git
#apt-get -y install vim
apt-get -y install python-pip
pip install Django==1.11
apt-get -y install apache2
apt-get -y install python-setuptools
apt-get -y install libapache2-mod-wsgi
cd /var/www
mkdir logs
chmod 777 logs
django-admin.py startproject mysite
IP_ADDRESS=`ifconfig |grep -A 2 eth1 |grep "inet addr" |awk '{print $2}'|awk -F ":" '{print $2}'`
find /var/www/mysite -name settings.py -exec sed -i "s/ALLOWED_HOSTS\ \=\ \[\]/ALLOWED_HOSTS\ \=\ \[\'${IP_ADDRESS}\'\, \'localhost\'\, \'127\.0\.0\.1\'\]/g" {} \;
cp /home/vagrant/sharedFolder/default /etc/apache2/sites-available/000-default.conf
echo "WSGIPythonPath /var/www/mysite" | sudo tee -a /etc/apache2/apache2.conf
service apache2 restart
	




