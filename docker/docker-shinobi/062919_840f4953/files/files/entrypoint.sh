#!/bin/bash
PROJECT_ROOT=/opt/shinobi
CUSTOM_CONF_DIR=/etc/shinobi/config

# Ensure conf.json to exist
if [ -f "${CUSTOM_CONF_DIR}/conf.json" ]; then
    ln -s "${CUSTOM_CONF_DIR}/conf.json" "${PROJECT_ROOT}/conf.json"
else
    cp "${PROJECT_ROOT}/conf.sample.json" "${PROJECT_ROOT}/conf.json"
fi

# Ensure super.json to exist
if [ -f "${CUSTOM_CONF_DIR}/super.json" ]; then
    ln -s "${CUSTOM_CONF_DIR}/super.json" "${PROJECT_ROOT}/super.json"
else
    cp "${PROJECT_ROOT}/super.sample.json" "${PROJECT_ROOT}/super.json"
fi

# EXEC default CMD or the user's arbitary command
exec "$@"

