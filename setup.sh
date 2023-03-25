#!/bin/bash
# https://helpcenter.onlyoffice.com/installation/docs-community-compile.aspx

set -ex

source ./env.sh


# Install NGINX
sudo apt-get -y install nginx
# Disable the default website
sudo rm -f /etc/nginx/sites-enabled/default

# set up the new website. To do that create the /etc/nginx/sites-available/onlyoffice-documentserver
mkdir -p /etc/nginx/sites-available
sudo cp -f ${PWD}/conf/onlyoffice-documentserver.nginx /etc/nginx/sites-available/onlyoffice-documentserver
if [ ! -e /etc/nginx/sites-enabled/onlyoffice-documentserver ]; then
  sudo ln -s /etc/nginx/sites-available/onlyoffice-documentserver /etc/nginx/sites-enabled/onlyoffice-documentserver
fi


# restart NGINX to apply the changes
sudo nginx -s reload


# Installing and configuring Mysql
sudo apt-get -y install mysql-server
sudo -i -u root mysql -uroot -p${MYSQL_PASSWORD} --execute="CREATE DATABASE IF NOT EXISTS onlyoffice;"
sudo -i -u root mysql -uroot -p${MYSQL_PASSWORD} --execute="CREATE USER 'onlyoffice'@'%' IDENTIFIED BY 'onlyoffice';"
sudo -i -u root mysql -uroot -p${MYSQL_PASSWORD} onlyoffice --execute="GRANT ALL privileges ON onlyoffice TO 'onlyoffice'@'%' IDENTIFIED BY 'onlyoffice';"
sudo -i -u root mysql -uroot -p${MYSQL_PASSWORD} onlyoffice --execute="FLUSH PRIVILEGES;"
sudo -i -u root mysql -uroot -p${MYSQL_PASSWORD} onlyoffice < ${INSTALL_DIR}/documentserver/server/schema/mysql/createdb.sql


# Installing RabbitMQ
sudo apt-get -y install rabbitmq-server


# config fonts
cd ${INSTALL_DIR}/documentserver/
mkdir fonts
LD_LIBRARY_PATH=${PWD}/server/FileConverter/bin server/tools/allfontsgen \
  --input="${PWD}/core-fonts" \
  --allfonts-web="${PWD}/sdkjs/common/AllFonts.js" \
  --allfonts="${PWD}/server/FileConverter/bin/AllFonts.js" \
  --images="${PWD}/sdkjs/common/Images" \
  --selection="${PWD}/server/FileConverter/bin/font_selection.bin" \
  --output-web='fonts' \
  --use-system="true"


# Generate presentation themes
cd ${INSTALL_DIR}/documentserver/
LD_LIBRARY_PATH=${PWD}/server/FileConverter/bin server/tools/allthemesgen \
  --converter-dir="${PWD}/server/FileConverter/bin"\
  --src="${PWD}/sdkjs/slide/themes"\
  --output="${PWD}/sdkjs/common/Images"


# Install Supervisor
sudo apt-get install -y supervisor


# Install bash scripts
sudo apt-get -y install rsync
rsync -avzrl --delete ./run/ ${RUN_DIR}/
cp -f env.sh ${RUN_DIR}/
