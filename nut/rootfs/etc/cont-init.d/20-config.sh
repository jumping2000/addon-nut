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
sed -i '/^#/!d' /config/nut/ups.conf

#### EDIT UPS.CONF FILE ####
echo "[ups_config]" >> /config/nut/ups.conf

#### DRIVER UPS ####
#if bashio::config.has_value 'nut_parameters'; then
NUT_PARAMETER=$(bashio::config 'nut_parameters')
NUT_DRIVER=$(bashio::config 'nut_parameters.driver')
echo "  driver = $NUT_DRIVER" >> /config/nut/ups.conf

NUT_PORT=$(bashio::config 'nut_parameters.port')
echo "  port = $NUT_PORT" >> /config/nut/ups.conf
#fi

#### BATTERY UPS ####
#if bashio::config.has_value 'runtimecal'; then
RUNTIMECAL=$(bashio::config 'runtimecal')
RUNTIMECAL_RUNTIME1=$(bashio::config 'runtimecal.runtime1')
RUNTIMECAL_POWER1=$(bashio::config 'runtimecal.power1')
RUNTIMECAL_RUNTIME2=$(bashio::config 'runtimecal.runtime2')
RUNTIMECAL_POWER2=$(bashio::config 'runtimecal.power2')
echo "  runtimecal = $RUNTIMECAL_RUNTIME1,$RUNTIMECAL_POWER1,$RUNTIMECAL_RUNTIME2,$RUNTIMECAL_POWER2" >> /config/nut/ups.conf
#fi

# Replace config files with user config files
bashio::log.info "Copying user config files"

# Copy user config files
cp -rf /config/nut/. /etc/nut/

# Fix permissions
chmod -R 660 /etc/nut/*
chown -R root:nut /etc/nut/*
