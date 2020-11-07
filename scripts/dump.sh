#! /bin/bash

if [[ $1 = 'load' ]]
then
mysql -u wordpress -p wordpress < /home/vagrant/site/dump.sql
else
mysqldump -u wordpress -p wordpress > /home/vagrant/site/dump.sql
fi