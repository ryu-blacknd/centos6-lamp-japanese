#!/bin/sh

#
# Stop SeLinux
#
echo -e "\033[0;32m[Stop selinux]\033[0;39m"
setenforce 0
sed -i -e 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

#
# Stop iptables
#
echo -e "\033[0;32m[Stop iptables]\033[0;39m"
/sbin/iptables -F
/sbin/service iptables stop

#
# SSH Setting
#
echo -e "\033[0;32m[SSH Setting]\033[0;39m"
# sed -i -e 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -e 's/^#PermitEmptyPasswords/PermitEmptyPasswords/' /etc/ssh/sshd_config

#
# Stop Services
#
echo -e "\033[0;32m[Stop Service]\033[0;39m"
if [ -f '/etc/rc.d/init.d/iptables'  ]; then chkconfig iptables off;  fi
if [ -f '/etc/rc.d/init.d/ip6tables' ]; then chkconfig ip6tables off; fi
if [ -f '/etc/rc.d/init.d/iscsi'     ]; then chkconfig iscsi off;     fi
if [ -f '/etc/rc.d/init.d/iscsid'    ]; then chkconfig iscsid off;    fi
if [ -f '/etc/rc.d/init.d/netfs'     ]; then chkconfig netfs off;     fi
if [ -f '/etc/rc.d/init.d/udev-post' ]; then chkconfig udev-post off; fi

#
# yum repository
#
echo -e "\033[0;32m[yum repository]\033[0;39m"
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL
rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi

#
# yum Install
#
echo -e "\033[0;32m[yum update]\033[0;39m"
yum --enablerepo=remi -y update

echo -e "\033[0;32m[yum install Development Tools]\033[0;39m"
yum --enablerepo=remi -y groupinstall "Development Tools"

echo -e "\033[0;32m[yum install others]\033[0;39m"
yum --enablerepo=remi -y install sudo mlocate man finger wget w3m vim-enhanced yum-cron openssl-devel zlib-devel curl-devel syslog httpd httpd-devel php php-devel php-pear php-mysql php-gd php-mbstring ImageMagick ImageMagick-devel php-pecl-imagick mysql-server phpmyadmin java-1.7.0-openjdk-devel tomcat

chkconfig yum-cron on


#
# Git
#
echo -e "\033[0;32m[Git]\033[0;39m"
yum remove -y git
mkdir -p ~/src
cd ~/src
wget https://git-core.googlecode.com/files/git-1.9.0.tar.gz
tar zxf git-1.9.0.tar.gz
cd git-1.9.0
./configure --prefix=/usr/local/
make; make install


#
# Bash
#
echo -e "\033[0;32m[Bash]\033[0;39m"
cd
sed -i -e "s/^\export PATH$/PATH=$PATH:/usr/local/bin\nexport PATH/" .bash_profile


#
# Sudoers
#
 echo -e "\033[0;32m[Sudoers]\033[0;39m"
 sed -i -e 's/^Defaults    requiretty/#Defaults    requiretty/' /etc/sudoers
 echo "tomcat  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers


#
# ntp
#
echo -e "\033[0;32m[ntp]\033[0;39m"
/sbin/service ntpd start
/sbin/chkconfig ntpd on


#
# PHP
#
echo -e "\033[0;32m[PHP Setting]\033[0;39m"
sed -i -e "s/^\[Date\]$/[Date]\ndate.timezone = 'Asia\/Tokyo'/" /etc/php.ini


#
# MySQL
#
echo -e "\033[0;32m[MySQL]\033[0;39m"
sed -i -e "s/^\[mysqld\]$/[mysqld]\ncharacter-set-server = utf8/" /etc/my.cnf
sed -i -e "s/^\[mysql\]$/[mysql]\ndefault-character-set = utf8/" /etc/my.cnf
sed -i -e "s/^\[mysqldump\]$/[mysqldump]\ndefault-character-set = utf8/" /etc/my.cnf
/sbin/service mysqld start
SQL="UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1');
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE DATABASE redmine default character set utf8;
GRANT ALL on redmine.* to redmine IDENTIFIED BY 'redmine';
FLUSH PRIVILEGES;"
mysql -u root -e "$SQL"
/sbin/service mysqld restart
/sbin/chkconfig mysqld on


#
# Tomcat - GitBucket, Jenkins
#
echo -e "\033[0;32m[Tomcat]\033[0;39m"
cd /var/lib/tomcat/webapps
wget https://github.com/takezoe/gitbucket/releases/download/2.7/gitbucket.war
wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war
chkconfig tomcat on


#
# Apache
#
echo -e "\033[0;32m[Apache]\033[0;39m"
cp gitbucket.conf /etc/httpd/conf.d/
cp jenkins.conf /etc/httpd/conf.d/
touch /var/www/html/index.php
echo "<?php phpinfo(); ?>" >> /var/www/html/index.php
chown -R apache. /var/www/html
/sbin/service httpd start
/sbin/chkconfig httpd on


#
# Complete
#
echo -e "\033[0;32m[Complete]\033[0;39m"
echo -e "\033[0;32mPlease Reboot!\033[0;39m"
