#! /usr/bin/env bash

DBHOST=localhost
DBUSER=vagrant
DBPASSWD=123456

sudo apt-get -qq update

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

sudo apt-get install -y nginx mysql-server git curl

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get update && sudo apt-get install -y nodejs

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt-get update && sudo apt-get install -y yarn

sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y php7.4 php7.4-common php7.4-cli php7.4-fpm php7.4-xdebug php7.4-mysql php7.4-mbstring php7.4-xml php7.4-zip php7.4-gd


# OCMS START
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE ocms;"

mysql -uroot -p$DBPASSWD -e "CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASSWD';"

mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON *.* TO '$DBUSER'@'localhost' WITH GRANT OPTION;"

mysql -uroot -p$DBPASSWD -e "CREATE USER '$DBUSER'@'%' IDENTIFIED BY '$DBPASSWD';"

mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON *.* TO '$DBUSER'@'%' WITH GRANT OPTION;"

mysql -uroot -p$DBPASSWD -e "FLUSH PRIVILEGES;"

sudo cp /home/vagrant/server/nginx/ocms /etc/nginx/sites-available/ocms
sudo ln -s /etc/nginx/sites-available/ocms /etc/nginx/sites-enabled/
# OCMS END

sudo sed -i "s/bind-address/#bind-address/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart

sudo sed -i "s/sendfile on;/sendfile off;/" /etc/nginx/nginx.conf
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default

sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fixpathinfo=0/" /etc/php/7.4/fpm/php.ini
sudo echo "xdebug.show_error_trace = 1" >> /etc/php/7.4/mods-available/xdebug.ini
sudo echo "xdebug.remote_enable = 1" >> /etc/php/7.4/mods-available/xdebug.ini
sudo echo "xdebug.remote_connect_back = 1" >> /etc/php/7.4/mods-available/xdebug.ini
sudo echo "xdebug.idekey = PHPSTORM" >> /etc/php/7.4/mods-available/xdebug.ini
sudo echo "xdebug.remote_port = 9001" >> /etc/php/7.4/mods-available/xdebug.ini
sudo echo "xdebug.remote_autostart = 0" >> /etc/php/7.4/mods-available/xdebug.ini
sudo echo "xdebug.file_link_format = phpstorm://open?%f:%l" >> /etc/php/7.4/mods-available/xdebug.ini

sudo cp /home/vagrant/server/scripts/fakesendmail.sh /usr/bin/fakesendmail.sh
sudo chown root:root /usr/bin/fakesendmail.sh
sudo chmod 755 /usr/bin/fakesendmail.sh
sudo mkdir /var/mail/sendmail
sudo mkdir /var/mail/sendmail/new
sudo chmod -R 777 /var/mail/sendmail
sudo sed -i "s/;sendmail_path =/sendmail_path = \/usr\/bin\/fakesendmail.sh/" /etc/php/7.4/fpm/php.ini

sudo systemctl reload nginx
sudo systemctl restart php7.4-fpm

sudo cp /home/vagrant/server/scripts/dump.sh /usr/bin/dump.sh
sudo chown root:root /usr/bin/dump.sh
sudo chmod 777 /usr/bin/dump.sh

# Install Composer

curl -sS https://getcomposer.org/installer -o ./composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Install PHPUnit

wget https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
mv phpunit.phar /usr/bin/phpunit

# Install Gulp

sudo yarn global add gulp-cli
