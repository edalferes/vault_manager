
#!/bin/bash
#
# Description: Script for install and configure a single HashiCorp Vault cluster
# Maintainer: Edmilson Alferes <edmilson.alferes@alpheres.com>

# Global Variables
INIT_CONFIG_FILE="vault_init.conf"
LOG_FILE="vault.log"
VAULT_VERSION=""
VAULT_CONFIG_PATH=""
VAULT_ROOT_PATH=""

info_header(){
    echo ""
    echo  "Script: $(basename "$0")"
    echo  "Version: $(cat VERSION)"
    echo  "Maintainer: Edmilson Alferes <edmilson.alferes@alpheres.com>"
    echo  "Description: Script for install and configure a single HashiCorp Vault server."
}

# Use log info <function> <msg>
log_info(){

	TEXT_COLOR_INIT="\e[0;32m"
  TEXT_COLOR_FINAL="\e[0m"
	DT=$(date "+%Y/%m/%d %H:%M:%S")
	STR_CONSOLE="${TEXT_COLOR_INIT} [${DT}] - [INFO] - [${1}]: ${2} ${TEXT_COLOR_FINAL}"
  STR_FILE="[${DT}] - [INFO] - [${1}]: ${2}"
  echo ${STR_CONSOLE}
  echo ${STR_FILE} >> ${LOG_FILE}
}

# Use log warning <function> <msg>
log_warning(){

	TEXT_COLOR_INIT="\e[1;33m"
  TEXT_COLOR_FINAL="\e[0m"
	DT=$(date "+%Y/%m/%d %H:%M:%S")
	STR_CONSOLE="${TEXT_COLOR_INIT} [${DT}] - [INFO] - [${1}]: ${2} ${TEXT_COLOR_FINAL}"
  STR_FILE="[${DT}] - [INFO] - [${1}]: ${2}"
  echo ${STR_CONSOLE}
  echo ${STR_FILE} >> ${LOG_FILE}
}

# Use log error <function> <msg>
log_error(){

	TEXT_COLOR_INIT="\e[1;31m"
  TEXT_COLOR_FINAL="\e[0m"
	DT=$(date "+%Y/%m/%d %H:%M:%S")
	STR_CONSOLE="${TEXT_COLOR_INIT} [${DT}] - [INFO] - [${1}]: ${2} ${TEXT_COLOR_FINAL}"
  STR_FILE="[${DT}] - [INFO] - [${1}]: ${2}"
  echo ${STR_CONSOLE}
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
    VAULT_CONFIG_PATH=$(read_parameters "VAULT_CONFIG_PATH")
    VAULT_ROOT_PATH=$(read_parameters "VAULT_ROOT_PATH")
          
	else
    log_error "validate_parameters" "Configuration file: ${INIT_CONFIG_FILE} not found."
    exit 1 
  fi
}

install_vault() {

	log_info "install_vault" "Install Vault server"

  apt-get update

  apt-get install -f wget unzip

  clear

  vault_package="vault_${VAULT_VERSION}_linux_amd64.zip"

  vault_url_download="https://releases.hashicorp.com/vault/${VAULT_VERSION}/${vault_package}"

  wget -O ${vault_package} -q --show-progress ${vault_url_download}

  unzip ${vault_package} -d /usr/local/bin

  rm -rf ${vault_package}

  vault --version

}

uninstall_vault() {

  log_info "uninstall_vault" "Uninstall vault server"

  vault_stop

  rm -rf /usr/local/bin/vault
  rm -rf ${VAULT_CONFIG_PATH}
  rm -rf ${VAULT_ROOT_PATH}
  rm -rf /etc/systemd/system/vault.service
  systemctl daemon-reload
  userdel vault
}

create_user_vault() {

  log_info "create_user_vault" "Configure system user vault"

  useradd --system --home /etc/vault.d --shell /bin/false vault

}

configure_path() {

	log_info "configure_path_permissions" "Configure path"

  if [ ! -d ${VAULT_CONFIG_PATH} ]; then
    
    log_info "configure_path_permissions" "Directory ${VAULT_CONFIG_PATH} do not exist, creating..."

    mkdir -p ${VAULT_CONFIG_PATH}
    
  fi

  if [ ! -d ${VAULT_ROOT_PATH} ]; then
    
    log_info "configure_path_permissions" "Directory ${VAULT_ROOT_PATH} do not exist, creating..."

    mkdir -p ${VAULT_ROOT_PATH}/data
    mkdir -p ${VAULT_ROOT_PATH}/tls
  fi
}

create_certificate() {

	log_info "create_certificate" "Create Certificate self signed"

}

configure_systemd () {
  
  log_info "configure_systemd" "Configure systemd"

  cat <<EOF | tee /etc/systemd/system/vault.service

[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=${VAULT_CONFIG_PATH}/config.hcl

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=${VAULT_CONFIG_PATH}/config.hcl
ExecReload=/bin/kill --signal HUP 
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitBurst=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
}

configure_server_file() {

  log_info "configure_server_file" "Configure server file: ${VAULT_CONFIG_PATH}/config.hcl"

  cat <<EOF | tee ${VAULT_CONFIG_PATH}/config.hcl

api_addr = "http://0.0.0.0:8200"
cluster_name = "vault"

disable_cache = true
disable_mlock = true
ui = true

listener "tcp" {
   address = "0.0.0.0:8200"
   tls_disable = true
}

storage "file" {
   path  = "${VAULT_ROOT_PATH}/data"
}

EOF

}

configure_permission() {

  log_info "configure_permission" "Configure Permission"

  chown -R vault:vault ${VAULT_CONFIG_PATH} ${VAULT_ROOT_PATH}
}

vault_start() {

  log_info "start_vault" "Start Vault"

  systemctl enable vault.service
  systemctl start vault.service
  systemctl daemon-reload
}

vault_stop() {
  systemctl stop vault.service
  systemctl daemon-reload
}

vault_status() {
  systemctl status vault.service
}

help_info() {

    info_header
    
    echo ""
    echo " Use option to script: " 
    echo ""
    echo " --install          - Install and configure vault server."
    echo " --uninstall        - Uninstall vault server."
    echo " --start            - Start vault server."
    echo " --stop             - Stop vault server."
    echo " --status           - Status vault server."
    echo " --help | -h        - Show this info."
    echo ""
}

main() {

  validate_parameters
  
  local OPTION=${1}

    case ${OPTION} in
        
      --install)
        install_vault
        create_user_vault
        configure_path
        configure_systemd
        configure_server_file
        configure_permission
        vault_start    
      ;;
      --uninstall)
        uninstall_vault
      ;;
      --start)
        vault_start
      ;;
      --stop)
        vault_stop
      ;;
      --status)
        vault_status
      ;;
      --help | -h)
        help_info
      ;;
      *) log_error "main" "Invalid option: ${OPTION}" 
        help_info
      ;;
    esac
}

main $@