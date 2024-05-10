#!/bin/sh

env_to_properties() {
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

merge_config_folder() {
    yq eval-all '. as $item ireduce ({}; . * $item )' "$1/"*".yaml" > "$2"
}