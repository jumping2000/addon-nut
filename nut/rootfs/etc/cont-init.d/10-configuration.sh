#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: Network UPS Tools
# Configures Network UPS Tools
# ==============================================================================

readonly BASE_DIR=/etc/nut
readonly UPS_CONF=${BASE_DIR}/ups.conf
readonly NUT_CONF=${BASE_DIR}/nut.conf
readonly UPSD_CONF=${BASE_DIR}/upsd.conf
readonly USERS_CONF=${BASE_DIR}/upsd.users
readonly UPSMON_CONF=${BASE_DIR}/upsmon.conf


override_notice() {
    local file=${1}
    {
        echo
        echo "# --------------------------------------------------------------------------"
        echo "#"
        echo "# This file was automatically generated by Hass.io Network"
        echo "# UPS Tools add-on. Changes to this file will be overwritten."
        echo "#"
        echo "# --------------------------------------------------------------------------"
        echo
    } > "${file}"
}

gen_upsd_users() {
    local username
    local password

    # Add overwrite notice to ups.conf
    override_notice ${USERS_CONF}

    for user in $(bashio::config "users|keys[]"); do

        bashio::config.require.username "users[${user}].username"
        username=$(bashio::config "users[${user}].username")

        bashio::log.info "Configuring user: ${username}"
        if ! bashio::config.true 'i_like_to_be_pwned'; then
            bashio::config.require.safe_password "users[${user}].password"
        else
            bashio::config.require.password "users[${user}].password"
        fi
        password=$(bashio::config "users[${user}].password")

        {
            echo
            echo "[${username}]"
            echo "  password = ${password}"
        } >> "${USERS_CONF}"

        for instcmd in $(bashio::config "users[${user}].instcmds"); do
            echo "  instcmds = ${instcmd}" >> "${USERS_CONF}"
        done

        for action in $(bashio::config "users[${user}].actions"); do
            echo "  actions = ${action}" >> "${USERS_CONF}"
        done

        if bashio::config.has_value "users[${user}].upsmon"; then
            upsmon=$(bashio::config "users[${user}].upsmon")
            echo "  upsmon ${upsmon}" >> "${USERS_CONF}"
        fi
    done
}

gen_ups_conf() {
    local upsname
    local driver
    local port
    local desc
    local battery_voltage_high
    local battery_voltage_low
    local charge_time
    local idle_time
    local runtime1
    local runtime2

    ## delete configuration line ##
    sed -i '/^#/!d' "${UPS_CONF}"

    # Add overwrite notice to ups.conf
    override_notice ${UPS_CONF}

    #### DRIVER e PORT ####
    for conf in $(bashio::config "devices|keys[]"); do
        upsname=$(bashio::config "devices[${conf}].upsname")
        driver=$(bashio::config "devices[${conf}].driver")
        port=$(bashio::config "devices[${conf}].port")
        desc=$(bashio::config "devices[${conf}].desc")
        bashio::log.info "Configuring UPS: ${upsname}"
        {
            echo
            echo "[${upsname}]"
            echo "  driver = ${driver}"
            echo "  port = ${port}"
            echo "  desc= ${port}"
        } >> "${UPS_CONF}"

        if bashio::config.has_value "devices[${conf}].battery_voltage_high"; then
            battery_voltage_high=$(bashio::config "devices[${conf}].battery_voltage_high")
            echo "  default.battery.voltage.high = ${battery_voltage_high}" >> "${UPS_CONF}"
        fi
        if bashio::config.has_value "devices[${conf}].battery_voltage_low"; then
            battery_voltage_low=$(bashio::config "devices[${conf}].battery_voltage_low")
            echo "  default.battery.voltage.low= ${battery_voltage_low}" >> "${UPS_CONF}"
        fi
        if bashio::config.has_value "devices[${conf}].charge_time"; then
            charge_time=$(bashio::config "devices[${conf}].charge_time")
            echo "  chargetime = ${charge_time}" >> "${UPS_CONF}"
        fi
        if bashio::config.has_value "devices[${conf}].idle_load"; then
            idle_load=$(bashio::config "devices[${conf}].idle_load")
            echo "  idleload = ${idle_load}" >> "${UPS_CONF}"
        fi
        runtime1=$(bashio::config "devices[${conf}].runtime1")
        runtime2=$(bashio::config "devices[${conf}].runtime2")
        {
            echo "  runtimecal = $runtime1,100,$runtime2,50" 
            echo ""
        } >> "${UPS_CONF}"
        
        while read -r option; do
            echo "  ${option}" >> "${UPS_CONF}"
        done <<< $(bashio::config "devices[${conf}].config")
    done  
}

gen_nut_conf() {
    bashio::log.info "Generating ${NUT_CONF}..."
    local mode

    override_notice ${NUT_CONF}
    mode=$(bashio::config "nut.mode")
    echo "MODE=${mode}" >> "${NUT_CONF}"
}

gen_upsd_conf() {
    bashio::log.info "Generating ${UPSD_CONF}..."
    override_notice ${UPSD_CONF}
    while read -r option; do
        echo "${option}" >> "${UPSD_CONF}"
    done <<< $(bashio::config "upsd")
}

gen_upsmon_conf() {
    bashio::log.info "Generating ${UPSMON_CONF}..."
    poweroff_wait=$(bashio::config "nut.poweroff_wait")
    sed -i "s/%%poweroff_wait%%/${poweroff_wait}/g" ${UPSMON_CONF}
}

fix_permissions() {
    bashio::log.info "Setting permissions..."
    chmod -R 660 ${BASE_DIR}/*
    chown -R root:nut ${BASE_DIR}/*
}

# ==============================================================================
# RUN LOGIC
# ------------------------------------------------------------------------------
main() {
    gen_ups_conf
    gen_nut_conf
    gen_upsd_conf
    gen_upsd_users
    gen_upsmon_conf
    fix_permissions
}
main "$@"

