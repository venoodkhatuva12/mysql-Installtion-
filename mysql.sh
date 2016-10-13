#!/bin/bash
#Script made for MySQL Installtion
#Author: Vinod.N K
#Usage: MYSQL, Ulimit, OpenSSL, Gcc, for portal installation
#Distro : Linux -Centos, Rhel, and any fedora
#Check whether root user is running the script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Update yum repos.and install development tools
whiptail --title " MOOFWD PORTAL INSTALLATION Portal!! " --msgbox "Starting installation of Portal... Choose Ok to continue." 10 60
echo "Starting installation of Portal..."
sudo yum update -y
sudo yum install newt -y
sudo yum groupinstall "Development Tools" -y
sudo yum install screen -y

# Installing needed dependencies and setting ulimit
whiptail --title "MOOFWD PORTAL INSTALLATION Portal!!! " --msgbox " Installing  needed dependencies for Portal. Choose Ok to continue." 10 60
sudo yum install  gcc openssl openssl-devel pcre-devel git unzip wget -y
sed -i -e '/# End of file/d' /etc/security/limits.conf
echo "* soft    nofile  99999
*       hard    nofile  99999
*       soft    noproc  20000
*       hard    noproc  20000
# End of file" >> /etc/security/limits.conf
sudo sysctl -w fs.file-max=6816768
sudo sysctl -p

# Remi-Repo for mysql and php
echo "Installing the Remi Repo..."
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm && rpm -Uvh epel-release-latest-6.noarch.rpm
sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/remi.repo
sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

# Yum update with new repo
sudo yum update -y

# Install MySQL v5
whiptail --title " MySQL INSTALLATION!! " --msgbox "Do You Want to Install MySQL? . Choose Ok to continue." 10 60
sudo yum install -y mysql mysql-server
echo "Configuring MySQL data-dir..."
sudo sed -i /datadir/d /etc/my.cnf
sudo sed -i '4 i datadir=/var/lib/mysql' /etc/my.cnf
sudo /etc/init.d/mysqld restart
# password for root user of mysql
PASS=$(whiptail --title " MySQL Installation " --passwordbox "Please Enter the Password for MySQL root" 8 78 --title "password dialog" 3>&1 1>&2 2>&3)
sudo /usr/bin/mysqladmin -u root password "$PASS"

sleep 2
#ask user about MySQL username
username=$(whiptail --title " MySQL Installation " --inputbox "Please enter username for MySQL you wish to add ?" 10 60 username 3>&1 1>&2 2>&3)
#ask user about allowed hostname
host=$(whiptail --title " MySQL Installation " --inputbox "Please Enter Host for MySQL To Allow Access Eg: %,ip or hostname ?" 10 60 host 3>&1 1>&2 2>&3)
#ask user about password
password=$(whiptail --title " MySQL Installation " --passwordbox "Please Enter the Password for MySQL ($username)" 8 78 --title "password dialog" 3>&1 1>&2 2>&3)
#mysql query that will create new user, grant privileges on database with entered password
mysql -uroot -p"$PASS" -e "GRANT ALL PRIVILEGES ON dbname.* TO '$username'@'$host' IDENTIFIED BY '$password'"

whiptail --title " MySQL INSTALLATION!! " --msgbox "MySQL Installation Complete click ok to proceed . Choose Ok to continue." 10 60
