#!/bin/bash

set -ex

source ./env.sh

cd ${INSTALL_DIR}/documentserver/server/DocService
export NODE_ENV=development-linux
export NODE_CONFIG_DIR=${INSTALL_DIR}/documentserver/server/Common/config
${INSTALL_DIR}/documentserver/server/DocService/docservice
