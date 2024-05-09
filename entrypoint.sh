#!/bin/bash

config_file=/etc/headscale/config.yaml
tmp_config_file=/etc/headscale/config_tmp.yaml

# Scan env variables
env | {
template_formatted=""
while IFS= read -r line; do
  value=${line#*=}
  key=${line%%=*}
  key="${key^}"

  # Convert them to .properties format for yq
  if [[ "${key}" =~ ^HS_.* ]]; then
    key="${key//HS_/}"
    key="${key,,}"
    key="${key//__/.}"
    template_formatted="${template_formatted}"$'\n'"${key}=${value}"
  fi
done

echo -e "$template_formatted"
} | yq -p=props -oy - | sed 's/"true"/true/g;s/"false"/false/g' | tee -a "$tmp_config_file"

yq ". *= load(\"$tmp_config_file\")" "$config_file"

/usr/bin/headscale serve

