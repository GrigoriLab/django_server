#!/bin/bash
HOSTNAME=grigori
TIMEZONE=Armenia/Yerevan

#apt-get update
yum update
#apt-get install -y apache2
yum install -y apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

hostnamectl set-hostname ${HOSTNAME}
#timedatectl list-timezones
timedatectl set-timezone ${TIMEZONE}



