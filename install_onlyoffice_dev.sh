#!/bin/bash

# 安装onlyoffice，然后配置安装目录 /var/www/onlyoffice 为开发环境

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
sudo echo "deb https://download.onlyoffice.com/repo/debian squeeze main" | sudo tee /etc/apt/sources.list.d/onlyoffice.list

sudo apt-get update
sudo apt-get install ttf-mscorefonts-installer

sudo apt install postgresql postgresql-contrib
sudo -i -u postgres psql -c "CREATE USER onlyoffice WITH PASSWORD 'onlyoffice';"
sudo -i -u postgres psql -c "CREATE DATABASE onlyoffice OWNER onlyoffice;"

sudo apt-get install onlyoffice-documentserver

sudo rsync -avzrl ./nginx/includes/ /etc/nginx/includes/
sudo rsync -avzrl ./nginx/conf.d/ /etc/nginx/conf.d/
sudo cp -f ./nginx/nginx.conf /etc/nginx/nginx.conf

# 杀掉系统启动好的进程，用自己编译的进程替换
ps -ef | grep documentserver | awk '{print $2}' | xargs -I{} sudo kill -9 {}

# 重启，访问http://localhost即可测试
sudo rm -rf /etc/nginx/sites-enabled/onlyoffice-documentserver
sudo systemctl restart nginx
