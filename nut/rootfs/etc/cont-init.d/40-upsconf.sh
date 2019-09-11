#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: Network UPS Tools
# Configures Network UPS Tools
# ==============================================================================
readonly UPS_CONF=/etc/nut/ups.conf

gen_ups_conf() {
    local driver
    local port
    local runtime1
    local runtime2
    local power1
    local power2
    local upsconf
    # Add overwrite notice to ups.conf
    {
        echo
        echo "# --------------------------------------------------------------------------"
        echo "#"
        echo "# This file was automatically generated by Hass.io Network"
        echo "# UPS Tools add-on. Changes to this file will be overwritten."
        echo "#"
        echo "# --------------------------------------------------------------------------"
    } >> "${UPS_CONF}"

    sed -i '/^#/!d' /etc/nut/ups.conf
    
    upsconf="tecnoware1100"
    
    #### DRIVER e PORT ####
    bashio::log.info "Configuring driver: ${driver}"
    driver=$(bashio::config "nut_parameters.driver")
    port=$(bashio::config "nut_parameters.port")

    {
        echo
        echo "[${upsconf}]"
        echo "  driver = ${driver}"
        echo "  port = ${port}"
    } >> "${UPS_CONF}"
    
    #### BATTERY UPS ####
    #if bashio::config.has_value 'runtimecal'; then
    #RUNTIMECAL=$(bashio::config 'runtimecal')
    bashio::log.info "Configuring runtimecal"
    runtime1=$(bashio::config 'runtimecal.runtime1')
    power1=$(bashio::config 'runtimecal.power1')
    runtime2=$(bashio::config 'runtimecal.runtime2')
    power2=$(bashio::config 'runtimecal.power2')
    echo "  runtimecal = $runtime1,$power1,$runtime2,$power2" >> /etc/nut/ups.conf
    #fi
    
}

# ==============================================================================
# RUN LOGIC
# ------------------------------------------------------------------------------
main() {
    bashio::log.info "Generating ${UPS_CONF}..."
    gen_ups_conf
}
main "$@"