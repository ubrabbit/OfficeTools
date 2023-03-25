#!/bin/bash

PARENT_DIR=`dirname ${PWD}`
INSTALL_DIR="${HOME}/onlyoffice/bin"
RUN_DIR="${HOME}/onlyoffice/run"

mkdir -p ${RUN_DIR}
mkdir -p ${RUN_DIR}/log

# onlyoffice 运行时需要的变量
export DB_TYPE=mysql
export DB_PORT=6443
