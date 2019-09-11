#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: Network UPS Tools
# Ensures the configuration exists
# ==============================================================================
declare -a CONF_FILES=("nut.conf" "ups.conf" "upsd.conf" "upsmon.conf" "upssched.conf")

#set -e
# Ensure configuration exists
if ! bashio::fs.directory_exists "/config/nut/"; then
    mkdir -p /config/nut \
        || bashio::exit.nok "Failed to create NUT configuration directory"

    # Copy template files
    bashio::log.info "Copying config template files"
    for file in "${CONF_FILES[@]}"; do
        cp "/etc/nut/${file}" /config/nut
    done
fi

chmod -R 777 /config/nut

bashio::log.info "Copying user config files"

# Copy user config files
cp -rf /config/nut/. /etc/nut/

# Fix permissions
chmod -R 660 /etc/nut/*
chown -R root:nut /etc/nut/*
