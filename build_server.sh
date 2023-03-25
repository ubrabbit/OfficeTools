#!/bin/bash

set -ex

source ./env.sh

cd ${PARENT_DIR}/build_tools/tools/linux
./automate_server.py server
cd -

rsync -avzrl --delete ${PARENT_DIR}/build_tools/out/linux_64/onlyoffice/documentserver/ ${INSTALL_DIR}/documentserver/
