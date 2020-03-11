#!/bin/bash

set -e

CMD_WRAPPER="/bin/emptyenv export HOME /var/www s6-setuidgid www-data"

cmd=""
if [ $# -gt 0 ]; then
  cmd="$CMD_WRAPPER $@"
elif [ -t 0 ]; then
  cmd="$CMD_WRAPPER /bin/bash"
fi

exec /init $cmd
