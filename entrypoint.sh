#!/bin/sh

. /srv/docker-headscale/helper/vars.sh
. /srv/docker-headscale/helper/functions.sh

# Set process UID and GID at runtime
if [ -n "$PUID" ] && [ -n "$PGID" ]; then
    groupmod -g $PGID headscale
    usermod -u $PUID -g $PGID headscale
fi
chown -R headscale: /etc/headscale
chown -R headscale: /var/lib/headscale

mkdir -p "$custom_config_folder"

rm -rf "$template_config_file"
mv "$config_file" "$template_config_file"

env | env_to_properties | yq -p=props -oy - | sed 's/"true"/true/g;s/"false"/false/g' | tee "$custom_config_folder/99_env.yaml"

# rename *.yml to *.yaml
for file in "$custom_config_folder"/*.yml; do
  if [ -e "$file" ]; then
    mv "$file" "${file%.yml}.yaml"
  fi
done

merge_config_folder "$custom_config_folder" "$config_file"

/usr/bin/supervisord -c /srv/docker-headscale/supervisord.conf

