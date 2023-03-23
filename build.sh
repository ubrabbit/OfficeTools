#!/bin/bash

set -ex

source ./env.sh

cd ${PARENT_DIR}/build_tools/tools/linux
./automate.py server
cd -

mkdir -p ${INSTALL_DIR}
rm -rf ${INSTALL_DIR}/documentserver 2&>1 > /dev/null
cp -rf ${PARENT_DIR}/build_tools/out/linux_64/onlyoffice/documentserver ${INSTALL_DIR}/documentserver

# setup env
cd ${PWD}
./setup.sh
