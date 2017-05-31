#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/util.sh
usage() { echo "Usage: $0 [-n appname] [-y yes to all]" 1>&2; exit 1; }
while getopts ":n:f:y" o; do
    case "${o}" in
        n)
          INSTANCE_NAME=${OPTARG}
          ;;
        f)
          FILE_NAME=${OPTARG}
          ;;
        y)
          ALL_YES=0
            ;;
        *)
            usage
            ;;
    esac
done

backupPath="$DIR/backup/"

if [[ -z $FILE_NAME ]]
then
  FILE_NAME=$(ls -t $backupPath/*${INSTANCE_NAME}.tar.gz | head -1)
fi

INSTANCE_NAME=${INSTANCE_NAME:-"default"}
read_env_file;
build_var;


confirm_action "Restore backup $FILE_NAME (y/n) ?"
if [[ $? -eq 0 ]]
then
  sudo docker stop ${LDAP_NAME}
  echo "RESTORE BACKUP --"
  sudo rm -Rvf $DIR/data/${INSTANCE_NAME}
  (cd $DIR/data && sudo tar -xvzf $FILE_NAME)
  sudo docker start ${LDAP_NAME}
  echo " --- done restore ...> $FILE_NAME ";
else
  echo "--- skip restore";
fi
