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

### RM DOCKER :
rm_containers;

### DELETE DATA DIRECTORY :
DATA_DIRECTORY=${DIR}/data/${INSTANCE_NAME}
confirm_action "delete all files in ${DATA_DIRECTORY} (y/n) ?"
if [[ $? -eq 0 ]]
then
  (cd $DIR && sudo rm -Rvf ${DATA_DIRECTORY})
  echo " --- delete done ...";
else
  echo "--- skip delete";
fi
