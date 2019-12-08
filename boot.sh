#!/usr/bin/env bash

# update
echo "================================================================================"
echo ">>> Updating yum"
echo "================================================================================"
yum update -y
yum upgrade -y
yum install vim -y

# apache
echo "================================================================================"
echo ">>> Installing Apache"
echo "================================================================================"
yum -y -q install httpd
VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/var/www/"
  ServerName localhost
  <Directory "/var/www/">
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
EOF
)
systemctl restart httpd
systemctl enable httpd
# chown -R apache:apache /var/www/

# firewall
# echo "================================================================================"
# echo ">>> Setting up the firewall"
# echo "================================================================================"
# systemctl start firewalld
# systemctl enable firewalld
# firewall-cmd --permanent --zone=public --add-service=http
# firewall-cmd --permanent --zone=public --add-service=https
# systemctl reload firewalld
# systemctl stop firewalld
# systemctl disable firewalld

# php
echo "================================================================================"
echo ">>> Installing PHP 7.4"
echo "================================================================================"
yum install epel-release yum-utils -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum-config-manager --enable remi-php74
yum install php php-fpm php-mysqlnd php-opcache php-gd php-xml php-mbstring -y -y
systemctl start php-fpm
systemctl enable php-fpm
systemctl restart httpd
setsebool -P httpd_execmem 1

echo "================================================================================"
echo ">>> Installing Percona MySQL 5.7"
echo "================================================================================"
yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm -y
yum install http://repo.percona.com/centos/7/RPMS/x86_64/Percona-Server-selinux-56-5.6.42-rel84.2.el7.noarch.rpm -y
yum install Percona-Server-server-57 -y

echo "================================================================================"
echo ">>> Setting MySQL Password"
echo "================================================================================"
systemctl start mysql
password=$(cat /var/log/mysqld.log | grep "A temporary password is generated for" | tail -1 | sed -n 's/.*root@localhost: //p')
newPassword="this1sMyP@55w0rd"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$newPassword'; FLUSH PRIVILEGES;" > tmp.sql 
mysql --connect-expired-password -uroot -p$password < tmp.sql
echo "[client]" > /root/.my.cnf
echo "user=root" >> /root/.my.cnf
echo "password=${newPassword}" >> /root/.my.cnf
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ">>> Make sure you change the MySQL password"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
systemctl enable mysql
systemctl restart mysql

echo "================================================================================"
echo ">>> Completed installation of MySQL, Apache and PHP"
echo "================================================================================"
setenforce 0
systemctl restart httpd php-fpm
ifconfig
echo "================================================================================"
echo ">>> Done."
echo "================================================================================"