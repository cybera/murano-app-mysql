#!/bin/bash

vol=$(sudo readlink -e /dev/disk/by-uuid/$(sudo lsblk -o name,type,mountpoint,label,uuid | grep -v root | grep -v ephem | grep -v SWAP | grep -v vda | tail -1 | awk '{print $3}'))

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password %ROOT_MYSQL_PASSWORD%'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password %ROOT_MYSQL_PASSWORD%'

sudo mkfs -t ext4 $vol
sudo mkdir /opt/mysql_data
sudo mount $vol /opt/mysql_data

sudo apt-get -y -q install mysql-server
sudo service mysql stop

sudo cp -a /var/lib/mysql/ /opt/mysql_data/
sudo rm -rf /var/lib/mysql/
sudo ln -s /opt/mysql_data/mysql /var/lib/mysql

echo "$vol /opt/mysql_data ext4 defaults 0 1 " | sudo tee --append  /etc/fstab
sudo chown -R mysql:mysql /opt/mysql_data/mysql

echo "/opt/mysql_data/mysql/ r,
/opt/mysql_data/mysql/** rwk," | sudo tee --append /etc/apparmor.d/local/usr.sbin.mysqld

sudo sed -i -e "s/bind-address/#bind-address/g" /etc/mysql/my.cnf

sudo service apparmor restart
sudo service mysql restart

mysql --user=root --password=%ROOT_MYSQL_PASSWORD% -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%CONNECTION_IP%' IDENTIFIED BY '%ROOT_MYSQL_PASSWORD%' WITH GRANT OPTION"
mysql --user=root --password=%ROOT_MYSQL_PASSWORD% -e "FLUSH PRIVILEGES"

echo "[mysqldump]
password=%ROOT_MYSQL_PASSWORD%" | sudo tee --append /root/.my.cnf
sudo chmod 600 /root/.my.cnf
