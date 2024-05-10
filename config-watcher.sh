#!/bin/sh

. /srv/docker-headscale/helper/vars.sh
. /srv/docker-headscale/helper/functions.sh

# Start watching for changes
inotifywait -m -e modify,create,delete "$custom_config_folder" |
while read -r directory event file; do
    merge_config_folder "$custom_config_folder" "$config_file"
    supervisorctl restart headscale
done
