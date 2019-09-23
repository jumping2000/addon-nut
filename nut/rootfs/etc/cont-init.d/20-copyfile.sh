#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: Network UPS Tools
# Ensures the configuration exists
# ==============================================================================
declare -a CONF_FILES=("nut.conf" "ups.conf" "upsd.conf" "upsmon.conf" "upssched.conf")

#set -e
# Ensure configuration exists
if ! bashio::fs.directory_exists "/share/nut"; then
    mkdir -p /share/nut \
        || bashio::exit.nok "Failed to create NUT configuration directory"
fi

# Copy configuration file on share folder
bashio::log.info "Copying user config files on share folder"
for file in "${CONF_FILES[@]}"; do
    cp "/etc/nut/${file}" /share/nut
done

chmod -R 777 /share/nut/*
