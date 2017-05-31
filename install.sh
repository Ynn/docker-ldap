#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/util.sh
usage() { echo "Usage: $0 [-n appname] [-y yes to all]" 1>&2; exit 1; }
while getopts ":n:y" o; do
    case "${o}" in
        n)
          INSTANCE_NAME=${OPTARG}
          ;;
        y)
          ALL_YES=0
            ;;
        *)
            usage
            ;;
    esac
done



INSTANCE_NAME=${INSTANCE_NAME:-"default"}
read_env_file;
build_var;
echo "Check configuration :"
print_conf;
confirm_action "Use this configuration ? (y/n)"
if [[ ! $? -eq 0 ]]; then
  echo "--- abort";
  exit 1;
fi

sudo docker network ls |grep --quiet ${DOCKER_NETWORK}
if [[ ! $? -eq 0 ]]; then
  sudo docker network create  ${DOCKER_NETWORK};
fi;

# Remove all containers :
rm_containers;

(cd $DIR && \
	sudo docker run \
	--network=${DOCKER_NETWORK} \
	--name ${LDAP_NAME}\
	--hostname ${LDAP_NAME}\
	--env LDAP_ORGANISATION="${LDAP_ORGANISATION}" \
	--env LDAP_DOMAIN="${LDAP_DOMAIN}" \
	--env LDAP_ADMIN_PASSWORD="${LDAP_ADMIN_PASSWORD}" \
	-v ${DIR}/data/${INSTANCE_NAME}/slapd/database:/var/lib/ldap \
	-v ${DIR}/data/${INSTANCE_NAME}/slapd/config:/etc/ldap/slapd.d \
	-v ${DIR}/backup:/backup \
	--detach osixia/openldap:1.1.8 \
)

(cd $DIR && \
	sudo docker run \
	--network=${DOCKER_NETWORK} \
	--name ${LDAP_ADMIN_NAME} \
  --env VIRTUAL_PORT=80 \
  --env PHPLDAPADMIN_HTTPS=false \
  --env HTTPS_METHOD=nohttp \
  --env LETSENCRYPT_HOST="${LETSENCRYPT_HOST}"\
  --env LETSENCRYPT_EMAIL="${LETSENCRYPT_EMAIL}"\
  --env VIRTUAL_HOST="${LDAP_ADMIN_VIRTUAL_HOST}" \
  -p 3333:80 \
	--hostname "${LDAP_ADMIN_NAME}" --link ${LDAP_NAME}:ldap-host --env PHPLDAPADMIN_LDAP_HOSTS=ldap-host --detach osixia/phpldapadmin:0.6.12 \
)
#  --env VIRTUAL_PORT=443 \
#  --env VIRTUAL_PROTO=https \
#	 \

echo "Go to: http://localhost:${LDAP_PORT}"
echo "Login DN: ${LDAP_BINDDN}"
echo "Password: ${LDAP_ADMIN_PASSWORD}"
