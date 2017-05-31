#!/bin/bash
ALL_YES=1;
usage() { echo "Usage: $0 [-n appname] [-y yes to all]" 1>&2; exit 1; }
confirm_action () {
  if [[ ALL_YES -eq 0 ]];then return 0;fi;
  read -p "${1}" -n 1 -r
  echo # empty line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
     return 1 # handle exits from shell or function but don't exit interactive shell
  fi
  return 0;
}

read_env_file(){
  ENV_FILE=$DIR/config/$INSTANCE_NAME.env
  if [[ ! -f "$ENV_FILE" ]]; then
      echo "Environment file $ENV_FILE not found"
      echo "Please provide a valid env file name"
      echo "Example : "
      echo "    $0         : will use the file config/default.env"
      echo "    $0 -n test : will use the file config/test.env"
      exit 0
  fi
  source $ENV_FILE
}

build_var(){
  LDAP_NAME=${INSTANCE_NAME}_ldap
  LDAP_ADMIN_NAME=${INSTANCE_NAME}_ldap_admin
  DOCKER_NETWORK=${DOCKER_NETWORK:-"www"}
}

rm_containers(){
  sudo docker ps -a |grep --quiet ${LDAP_NAME}
  if [[ $? -eq 0 ]]; then
    sudo docker rm -vf ${LDAP_NAME}
  fi;
  sudo docker ps -a |grep --quiet ${LDAP_ADMIN_NAME}
  if [[ $? -eq 0 ]]; then
    sudo docker rm -vf ${LDAP_ADMIN_NAME}
  fi;
}

print_conf(){
  echo "-- CONFIGURATION :"
  echo "-----------------------------------------------------"
  echo "LDAP_PORT=               "${LDAP_PORT}
  echo "LDAP_DOMAIN=             "${LDAP_DOMAIN}
  echo "LDAP_ORGANISATION=       "${LDAP_ORGANISATION}
  echo "LDAP_ADMIN_PASSWORD=     "${LDAP_ADMIN_PASSWORD}
  echo "LDAP_SEARCHBASE=         "${LDAP_SEARCHBASE}
  echo "LDAP_BINDDN=             "${LDAP_BINDDN}
  echo "LDAP_ADMIN_VIRTUAL_HOST= "${LDAP_ADMIN_VIRTUAL_HOST}
  echo "DOCKER_NETWORK=          "${DOCKER_NETWORK}
  echo "-----------------------------------------------------"
}
