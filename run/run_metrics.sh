#!/bin/bash

set -ex

source ./env.sh

cd ${INSTALL_DIR}/documentserver/server/DocService
NODE_ENV=development-linux NODE_CONFIG_DIR=$PWD/../Common/config ./docservice
