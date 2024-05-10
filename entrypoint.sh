#!/bin/sh

custom_config_folder="/etc/headscale/config.yaml.d"
config_file="/etc/headscale/config.yaml"
template_config_file="$custom_config_folder/00_template.yaml"

mkdir -p "$custom_config_folder"

rm -rf "$template_config_file"
mv "$config_file" "$template_config_file"

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

env | process_env_variables | yq -p=props -oy - | sed 's/"true"/true/g;s/"false"/false/g' | tee "$custom_config_folder/99_env.yaml"

# rename *.yml to *.yaml
for file in "$custom_config_folder"/*.yml; do
  if [ -e "$file" ]; then
    mv "$file" "${file%.yml}.yaml"
  fi
done

yq eval-all '. as $item ireduce ({}; . * $item )' "$custom_config_folder/"*".yaml" > "$config_file"

/usr/bin/headscale serve

