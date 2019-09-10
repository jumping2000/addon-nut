#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: Network UPS Tools
# Ensures the configuration exists
# ==============================================================================
declare -a CONF_FILES=("nut.conf" "ups.conf" "upsd.conf" "upsmon.conf" "upssched.conf")

# Ensure configuration exists
if ! bashio::fs.directory_exists "/share/nut/"; then
    mkdir -p /share/nut \
        || bashio::exit.nok "Failed to create NUT configuration directory"

    # Copy template files
    bashio::log.info "Copying config template files"
    for file in "${CONF_FILES[@]}"; do
        cp "/etc/nut/${file}" /share/nut/
    done
fi

chmod -R 776 /share/nut
sed '/^#/!d' /share/nut/ups.conf

#### EDIT UPS.CONF FILE ####
echo "[ups_config]" >> /share/nut/ups.conf

#### DRIVER UPS ####
if [ "$NUT_PARAMETERS" -gt "0" ]; then
   NUT_PARAMETERS_VALUE=$(bashio::config 'nut_parameters')
   NUT_DRIVER=$(bashio::config 'nut_parameters.driver | length')
   if [ "$NUT_SERVER_DRIVER" -gt "0" ]; then 
      NUT_SERVER_DRIVER_VALUE=$(bashio::config 'nut_parameters.driver')
      echo "  driver = $NUT_SERVER_DRIVER" >> /share/nut/ups.conf
   fi
fi

#### BATTERY UPS ####
if [ "$BATTERY_PARAMETERS" -gt "0" ]; then
   BATTERY_PARAMETERS_VALUE=$(bashio::config 'battery_parameters')
   RUNTIMECAL=$(bashio::config 'battery_parameters.runtimecal | length')
   if [ "$RUNTIMECAL" -gt "0" ]; then 
      RUNTIMECAL_RUNTIME1=$(bashio::config 'battery_parameters.runtimecal.runtime1')
      RUNTIMECAL_POWER1=$(bashio::config 'battery_parameters.runtimecal.power1')
      RUNTIMECAL_RUNTIME2=$(bashio::config 'battery_parameters.runtimecal.runtime2')
      RUNTIMECAL_POWER2=$(bashio::config 'battery_parameters.runtimecal.power2')
      echo "  runtimecal = $RUNTIMECAL_RUNTIME1,$RUNTIMECAL_POWER1,$RUNTIMECAL_RUNTIME2,$RUNTIMECAL_POWER2" >> /share/nut/ups.conf
   fi
fi

# Replace config files with user config files
bashio::log.info "Copying user config files"

# Copy user config files
cp -rf /share/nut/. /etc/nut/

# Fix permissions
chmod -R 660 /etc/nut/*
chown -R root:nut /etc/nut/*
