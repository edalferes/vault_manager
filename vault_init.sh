
#!/bin/bash
#
# Description: Script for install and configure a single HashiCorp Vault cluster
# Maintainer: Edmilson Alferes <edmilson.alferes@alpheres.com>

# Global Variables
INIT_CONFIG_FILE="vault_init.conf"
LOG_FILE="vault.log"
VAULT_VERSION=""


# Use log info <function> <msg>
log_info(){

	TEXT_COLOR_INIT="\e[0;32m"
  TEXT_COLOR_FINAL="\e[0m"
	DT=$(date "+%Y/%m/%d %H:%M:%S")
	STR_CONSOLE="${TEXT_COLOR_INIT} [${DT}] - [INFO] - [${1}]: ${2} ${TEXT_COLOR_FINAL}"
  STR_FILE="[${DT}] - [INFO] - [${1}]: ${2}"
  echo -e ${STR_CONSOLE}
  echo ${STR_FILE} >> ${LOG_FILE}
}

# Use log warning <function> <msg>
log_warning(){

	TEXT_COLOR_INIT="\e[1;33m"
  TEXT_COLOR_FINAL="\e[0m"
	DT=$(date "+%Y/%m/%d %H:%M:%S")
	STR_CONSOLE="${TEXT_COLOR_INIT} [${DT}] - [INFO] - [${1}]: ${2} ${TEXT_COLOR_FINAL}"
  STR_FILE="[${DT}] - [INFO] - [${1}]: ${2}"
  echo -e ${STR_CONSOLE}
  echo ${STR_FILE} >> ${LOG_FILE}
}

# Use log error <function> <msg>
log_error(){

	TEXT_COLOR_INIT="\e[1;31m"
  TEXT_COLOR_FINAL="\e[0m"
	DT=$(date "+%Y/%m/%d %H:%M:%S")
	STR_CONSOLE="${TEXT_COLOR_INIT} [${DT}] - [INFO] - [${1}]: ${2} ${TEXT_COLOR_FINAL}"
  STR_FILE="[${DT}] - [INFO] - [${1}]: ${2}"
  echo -e ${STR_CONSOLE}
  echo ${STR_FILE} >> ${LOG_FILE}
}

# Read key file config <key>
read_parameters () {

    local KEY=${1}
    RESULT=$(grep "${KEY}" ${INIT_CONFIG_FILE} | sed -nr "s/${KEY}:(.+)/\\1/p")
    echo ${RESULT}
}

validate_parameters() {

  if [ -e ${INIT_CONFIG_FILE} ]; then

    # reader parameters.
    VAULT_VERSION=$(read_parameters "VAULT_VERSION")        
	else
    log_error "validate_parameters" "Configuration file: ${INIT_CONFIG_FILE} not found."
    exit 1 
  fi
}

check_app() {

  log_info "check_app" "Verifying that the client has the apps"

  curl --version > /dev/null
  if [[ ${?} != 0 ]]; then
    log_error "check_app" "The curl app was not found, install curl to continue"
    exit 1
  fi

  wget --version > /dev/null
  if [[ ${?} != 0 ]]; then
    log_error "check_app" "The wget app was not found, install wget to continue"
    exit 1
  fi

  unzip -h > /dev/null
  if [[ ${?} != 0 ]]; then
    log_error "check_app" "The unzip app was not found, install curl to continue"
    exit 1
  fi
}


install_vault() {

	log_info "install_vault" "Install Vault"

  vault_package="vault_${VAULT_VERSION}_linux_amd64.zip"

  vault_url_download="https://releases.hashicorp.com/vault/${VAULT_VERSION}/${vault_package}"

  wget -O ${vault_package} -q --show-progress ${vault_url_download}

  sudo unzip ${vault_package} -d /usr/local/bin

  rm -rf ${vault_package}

  vault --version

}

configure_path_permissions() {

	log_info "configure_path_permissions" "Configure path and permissions"

}

create_certificate() {

	log_info "create_certificate" "Create Certificate self signed"

}

main() {
  validate_parameters
  check_app
  install_vault
}

main $@