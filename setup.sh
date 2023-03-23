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
cp -f ${PWD}/conf/onlyoffice-documentserver.nginx /etc/nginx/sites-available/onlyoffice-documentserver
sudo ln -s /etc/nginx/sites-available/onlyoffice-documentserver /etc/nginx/sites-enabled/onlyoffice-documentserver

# restart NGINX to apply the changes
sudo nginx -s reload


# Installing and configuring PostgreSQL
sudo apt-get -y install postgresql
sudo -i -u postgres psql -c "CREATE DATABASE onlyoffice;"
sudo -i -u postgres psql -c "CREATE USER onlyoffice WITH password 'onlyoffice';"
sudo -i -u postgres psql -c "GRANT ALL privileges ON DATABASE onlyoffice TO onlyoffice;"
psql -hlocalhost -Uonlyoffice -d onlyoffice -f ${INSTALL_DIR}/documentserver/server/schema/postgresql/createdb.sql


# Installing RabbitMQ
sudo apt-get -y install rabbitmq-server
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
