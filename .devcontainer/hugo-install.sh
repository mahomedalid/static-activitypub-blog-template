#!/bin/bash

#|---------------------------------------------------|
#|https://github.com/korkibucek/hugo-install         |
#|                                                   |
#|This script installs Hugo on a linux system        |
#|Visit gohugo.io for more info on Hugo              |
#|---------------------------------------------------|

# Set Hugo version
HUGO_VERSION="0.124.0"  # Replace with the version you want

# Choose Hugo edition: "standard" or "extended"
HUGO_EDITION="extended"

# Detect system architecture
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
  ARCH="64bit"
elif [ "$ARCH" == "aarch64" ]; then
  ARCH="ARM64"
else
  ARCH="32bit"
fi

# Construct the download URL
DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_EDITION}_${HUGO_VERSION}_Linux-${ARCH}.tar.gz"

# Check if the URL exists
if wget -q --method=HEAD "$DOWNLOAD_URL"; then
  # Download and install Hugo
  wget "$DOWNLOAD_URL"
  tar -zxvf hugo_*_${HUGO_VERSION}_Linux-${ARCH}.tar.gz
  sudo mv hugo /usr/local/bin/
  
  # Clean up downloaded files
  rm -rf hugo_*_${HUGO_VERSION}_Linux-${ARCH}.tar.gz
  
  # Verify Hugo installation
  hugo version
else
  echo "The specified Hugo version or edition does not exist. Please double-check the version and edition."
fi