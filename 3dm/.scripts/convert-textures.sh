#!/usr/bin/env bash

WOODS=("oak" "spruce" "birch" "jungle" "acacia" "big_oak")
WOOD_NAMES=("Oak" "Spruce" "Birch" "Jungle" "Acacia" "Dark Oak")

COLOURS=("white" "orange" "magenta" "light_blue" "yellow" "lime" "pink" "gray"
         "silver" "cyan" "purple" "blue" "brown" "green" "red" "black")
COLOUR_NAMES=("White" "Orange" "Magenta" "Light Blue" "Yellow" "Lime" "Pink"
              "Gray" "Light Gray" "Cyan" "Purple" "Blue" "Brown" "Green" "Red"
              "Black")

SOURCES="./.sources"

TOOLTIP="Designed by Lemmmy"

# Transform an input 3dm file to the specified wood type and wool colour
function transform {
  local source=$1

  local dir=$2
  local out="$dir/$(basename "$source")"

  local wood_i=$3
  local wood=${WOODS[$wood_i]}
  local wood_name=${WOOD_NAMES[$wood_i]}

  local colour_i=$4
  local colour=${COLOURS[$colour_i]}
  local colour_name=${COLOUR_NAMES[$colour_i]}

  local old_label=$(cat "$source" | grep -Eo 'label = ".+"' | sed -re 's/label = "(.+)"/\1/')
  local label="$wood_name $old_label"
  if [ -n "$4" ]; then
    label="$colour_name $wood_name $old_label"
  fi

  echo "Converting '$source' to '$label'"

  cat "$source" \
    | sed -re "s|label = \"(.+)\"|label = \"$label\"|g" \
    | sed -re "s|tooltip = \"TOOLTIP\"|tooltip = \"$TOOLTIP\"|g" \
    | sed -re "s|texture = \"planks\"|texture = \"minecraft:blocks/planks_$wood\"|g" \
    | sed -re "s|texture = \"wool\"|texture = \"minecraft:blocks/wool_colored_$colour\"|g" \
    > "$out"
}

# Convert an input 3dm file to all the appropriate types necessary
function convert_source {
  local source=$1
  local source_name=$(basename "$source" | sed 's/\.3dm$//')
  local type=$(echo "$source_name" | cut -d'-' -f1)

  # Iterate over each wood type index
  for wood_i in "${!WOODS[@]}"; do
    local wood=${WOODS[$wood_i]}
    if [[ "$wood_i" == "5" ]]; then
      wood="dark_oak" # more friendly wood name for the directory
    fi
    local dir="$type/$wood"
    mkdir -p "$dir" 2>/dev/null

    # Check if the source file has a wool type
    if grep -i 'texture = "wool"' $source >/dev/null; then
      # Iterate over each colour type index
      for colour_i in "${!COLOURS[@]}"; do
        local colour=${COLOURS[$colour_i]}
        if [[ "$colour_i" == "8" ]]; then
          colour="light_gray" # more friendly colour name for the directory
        fi
        local dir="$type/$wood/$colour"
        mkdir -p "$dir" 2>/dev/null

        # Create the appropriately transformed .3dm file
        transform "$source" "$dir" "$wood_i" "$colour_i"
      done
    else
      # Create the appropriately transformed .3dm file
      transform "$source" "$dir" "$wood_i"
    fi
  done
}

# Process all 3dm files in .sources
for source in $SOURCES/*.3dm; do
  convert_source $source
done