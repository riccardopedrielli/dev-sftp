#!/usr/bin/env bash

# shellcheck disable=SC2155,SC1090

set -Eeuo pipefail
trap 'echo_error Error: program exited with status ${?}' ERR

# Arguments
readonly SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
readonly SCRIPT=$(basename "${0}")
readonly COMMAND="${1:-}"
readonly ARGS=("${@:2}")

# Settings
readonly SERVICE_NAME="sftp"
readonly SERVICE="dev-${SERVICE_NAME}"
readonly SETTINGS_FILE="settings.env"
readonly EXTERNAL_SETTINGS_DIR="${HOME}/.config/docker-dev-tools/${SERVICE}"
readonly EXTERNAL_SETTINGS_FILE="${EXTERNAL_SETTINGS_DIR}/${SETTINGS_FILE}"

print_usage()
{
    echo
    echo "Usage: ${SCRIPT} <command>"
    echo
    echo "Commands:"
    echo "    up       Bring up the service."
    echo "    down     Bring down the service."
    echo "    prune    Bring down the service and delete the data."
    echo "    info     Show informations about the service: name, config, status."
    echo "    logs     Show service's logs, takes the same arguments as \"docker-compose logs\"."
    echo

    exit 1
}

echo_error()
{
    echo "$(tput setaf 1)${*}$(tput sgr0)"
}

check_bin()
{
    if ! command -v "${1}" &> /dev/null; then
        echo_error "Error: \"${1}\" is required but not installed."
        exit 1
    fi
}

load_settings()
{
    set -o allexport

    if [ -r "${SETTINGS_FILE}" ]; then
        source "${SETTINGS_FILE}"
    fi

    if [ -r "${EXTERNAL_SETTINGS_FILE}" ]; then
        source "${EXTERNAL_SETTINGS_FILE}"
    fi

    set +o allexport
}

service_up()
{
    docker-compose -p ${SERVICE} pull
    docker-compose -p ${SERVICE} up -d --force-recreate --remove-orphans
}

service_down()
{
    docker-compose -p ${SERVICE} down --remove-orphans
}

service_prune()
{
    service_down

    DATA_DIR_VAR="${SERVICE_NAME^^}_DATA_DIR"

    if rm -rf "${!DATA_DIR_VAR}" 2> /dev/null || sudo rm -rf "${!DATA_DIR_VAR}"; then
        echo "Data drectory removed: ${!DATA_DIR_VAR}"
    else
        echo "Error removing data directory: ${!DATA_DIR_VAR}"
    fi
}

service_info()
{
    echo
    echo "Service: ${SERVICE}"

    echo
    echo "Configuration"
    echo "-------------"

    local AWK_FILES=()

    if [ -r "${EXTERNAL_SETTINGS_FILE}" ]; then
        AWK_FILES+=("${EXTERNAL_SETTINGS_FILE}")
    fi

    AWK_FILES+=("${SETTINGS_FILE}")

    # shellcheck disable=SC2068
    awk -F'=' "!d[\$1]++ \
                { \
                    gsub (\"=\",\" \") ; \
                    if(FILENAME==\"${EXTERNAL_SETTINGS_FILE}\") \$2=\"[external]\" ; \
                    print \$1\" \"\$2 \
                }" \
        ${AWK_FILES[@]} | \
    sort | \
    column -t

    echo
    echo "Status"

    local -r STATUS=$(docker-compose -p ${SERVICE} ps 2> /dev/null)

    if [ "$(echo "${STATUS}" | wc -l)" -gt 2 ]; then
        echo "${STATUS}" | awk 'NR>1'
    else
        echo "------"
        echo "The service is not running"
    fi

    echo
}

service_logs()
{
    # shellcheck disable=SC2068
    docker-compose -p ${SERVICE} logs ${ARGS[@]:-}
}

main()
{
    check_bin docker
    check_bin docker-compose

    cd "${SCRIPT_DIR}"

    load_settings

    case ${COMMAND} in

        up)
            service_up
            ;;

        down)
            service_down
            ;;

        prune)
            service_prune
            ;;

        info)
            service_info
            ;;

        logs)
            service_logs
            ;;

        *)
            print_usage
            ;;

    esac
}

main
