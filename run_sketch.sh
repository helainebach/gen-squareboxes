#!/bin/bash

# Find the directory containing build.pde
sketch_dir=$(find . -type f -name "build.pde" -exec dirname {} \; | head -n 1)

if [ -z "$sketch_dir" ]; then
  echo "Error: build.pde not found."
  exit 1
fi

# Run the Processing sketch
processing-java --sketch=$(pwd)/$sketch_dir --run