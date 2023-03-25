#!/bin/bash

set -ex

source ./env.sh

cd ${INSTALL_DIR}/documentserver/server/Metrics
${INSTALL_DIR}/documentserver/server/Metrics/metrics ./config/config.js
