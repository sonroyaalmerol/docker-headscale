#!/bin/sh

config_file="/etc/headscale/config.yaml"
tmp_config_file="/etc/headscale/config_tmp.yaml"

process_env_variables() {
  while IFS='=' read -r key value; do
    key=$(echo "$key" | tr '[:lower:]' '[:upper:]')

    # Convert them to .properties format for yq
    if echo "$key" | grep -Eq '^HS_.*'; then
      key=$(echo "$key" | sed 's/^HS_//')
      key=$(echo "$key" | tr '[:upper:]' '[:lower:]')
      key=$(echo "$key" | sed 's/__/\./g')
      printf "%s=%s\n" "$key" "$value"
    fi
  done
}

env | process_env_variables | yq -p=props -oy - | sed 's/"true"/true/g;s/"false"/false/g' | tee -a "$tmp_config_file"

yq ". *= load(\"$tmp_config_file\")" "$config_file"

/usr/bin/headscale serve

