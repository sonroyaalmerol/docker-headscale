#!/bin/sh

config_file="/etc/headscale/config.yaml"
tmp_config_file="/etc/headscale/config_tmp.yaml"

# Scan env variables
env | {
template_formatted=""
while IFS= read -r line; do
  value=$(echo "$line" | cut -d '=' -f2-)
  key=$(echo "$line" | cut -d '=' -f1)
  key=$(echo "$key" | tr '[:lower:]' '[:upper:]')

  # Convert them to .properties format for yq
  if echo "$key" | grep -Eq '^HS_.*'; then
    key=$(echo "$key" | sed 's/^HS_//')
    key=$(echo "$key" | tr '[:upper:]' '[:lower:]')
    key=$(echo "$key" | sed 's/__/\./g')
    template_formatted="$template_formatted"$'\n'"$key=$value"
  fi
done

echo "$template_formatted"
} | yq -p=props -oy - | sed 's/"true"/true/g;s/"false"/false/g' | tee -a "$tmp_config_file"

yq ". *= load(\"$tmp_config_file\")" "$config_file"

/usr/bin/headscale serve

