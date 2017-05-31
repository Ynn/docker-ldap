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

### CREATE ARCHIVE  :
dateFileFormat="+%Y%m%dT%H%M%S"
backupPath="$DIR/backup/"
backupFilePath="$backupPath/$(date "$dateFileFormat")-${INSTANCE_NAME}.tar.gz"

confirm_action "Create backup $backupFilePath (y/n) ?"
if [[ $? -eq 0 ]]
then
  (cd $DIR/data && sudo tar -cvzf $backupFilePath ${INSTANCE_NAME})
  echo " --- done ...> $backupFilePath ";
else
  echo "--- skip archive";
fi

confirm_action "Clean older backups ?"
if [[ $? -eq 0 ]]
then
  sudo ls -t $backupPath/*${INSTANCE_NAME}.tar.gz | sed -e '1,5d' | sudo xargs -I% -d '\n' rm -v %
  echo " --- done cleaning ... ";
else
  echo "--- skip cleaning";
fi
