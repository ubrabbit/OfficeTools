#!/bin/bash
# https://helpcenter.onlyoffice.com/installation/docs-community-compile.aspx

set -ex

SETUP_DIR=`pwd`
source ./env.sh

# ubuntu 22.04 参考这里改mysql密码
# https://dademiao.cn/doc/51

# Install NGINX
sudo apt-get -y install nginx
sudo groupadd nginx
sudo useradd -d /home/nginx -g nginx -m nginx

# Disable the default website
sudo rm -f /etc/nginx/sites-enabled/default

# restart NGINX to apply the changes
sudo nginx -s reload


# Installing and configuring Mysql
sudo apt-get -y install mysql-server
sudo -i -u root mysql -uroot -p${MYSQL_PASSWORD} --execute="CREATE DATABASE IF NOT EXISTS onlyoffice;"
sudo -i -u root mysql -uroot -p${MYSQL_PASSWORD} --execute="CREATE USER IF NOT EXISTS 'onlyoffice'@'localhost' IDENTIFIED BY 'onlyoffice';"
sudo -i -u root mysql -uroot -p${MYSQL_PASSWORD} onlyoffice --execute="GRANT ALL privileges ON onlyoffice TO 'onlyoffice'@'localhost';"
sudo -i -u root mysql -uroot -p${MYSQL_PASSWORD} onlyoffice --execute="FLUSH PRIVILEGES;"
sudo -i -u root mysql -uroot -p${MYSQL_PASSWORD} onlyoffice < ${INSTALL_DIR}/documentserver/server/schema/mysql/createdb.sql

#mysql-8
#ALTER USER 'onlyoffice'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_PASSWORD}';
#ALTER USER 'onlyoffice'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_PASSWORD}';
#GRANT ALL PRIVILEGES ON *.* TO `onlyoffice`@`localhost` WITH GRANT OPTION;
#GRANT ALL PRIVILEGES ON `onlyoffice`.`task_result` TO `onlyoffice`@`localhost`;
#GRANT ALL PRIVILEGES ON `onlyoffice`.`doc_changes` TO `onlyoffice`@`localhost`;
#FLUSH PRIVILEGES;

# Installing RabbitMQ
sudo apt-get -y install rabbitmq-server


# config fonts
cd ${INSTALL_DIR}/documentserver/
mkdir -p fonts
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

rsync -avzrl --delete ${SETUP_DIR}/run/ ${RUN_DIR}/
cp -f ${SETUP_DIR}/env.sh ${RUN_DIR}/
chmod 777 ${RUN_DIR}/*.sh

rsync -avzrl --delete ${HOME}/onlyoffice/OfficeDocumentServer/python_example/ ${RUN_DIR}/python_example/
cd ${RUN_DIR}/python_example/
chmod 777 ${RUN_DIR}/*.sh

# 同步运行文件
mkdir -p /var/www/onlyoffice/documentserver/
sudo rsync -avzrl --delete ${HOME}/onlyoffice/OfficeDocumentServer/www/ /var/www/onlyoffice/documentserver/
#groupadd ds && useradd ds -g ds 2>&1 >/dev/null
sudo chown -R ds:ds /var/www/onlyoffice/documentserver/

sudo rsync -avzrl --delete ${HOME}/onlyoffice/OfficeDocumentServer/www/conf/nginx/ /etc/nginx/
sudo rsync -avzrl --delete ${HOME}/onlyoffice/OfficeDocumentServer/www/conf/onlyoffice/ /etc/onlyoffice/
