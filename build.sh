#!/bin/bash

# 需要确保 /usr/bin/python 是python2

set -ex

source ./env.sh

cd ${PARENT_DIR}/build_tools/tools/linux
./automate.py
cd -

mkdir -p ${INSTALL_DIR}
rm -rf ${INSTALL_DIR}/documentserver 2&>1 > /dev/null
cp -rf ${PARENT_DIR}/build_tools/out/linux_64/onlyoffice/documentserver ${INSTALL_DIR}/documentserver
