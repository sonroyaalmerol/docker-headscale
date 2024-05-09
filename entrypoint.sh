#!/bin/sh

config_file="/etc/headscale/config.yaml"
tmp_config_file="/etc/headscale/config_tmp.yaml"

rm -rf "$tmp_config_file"
touch "$tmp_config_file"

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

env | process_env_variables | yq -p=props -oy - | sed 's/"true"/true/g;s/"false"/false/g' | tee "$tmp_config_file"

yq eval-all '. as $item ireduce ({}; . * $item)' "$config_file" "$tmp_config_file"

/usr/bin/headscale serve

