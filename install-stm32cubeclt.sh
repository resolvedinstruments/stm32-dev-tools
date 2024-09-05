#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_installer_script>"
    exit 1
fi

installer_script="$1"

# Check if the installer script is a zip file
if [[ "$installer_script" == *.zip ]]; then
    unzip "$installer_script" -d .
    installer_script=$(ls st-stm32cubeclt_*.sh | sort -V | tail -n 1)
    if [ -z "$installer_script" ]; then
        echo "No corresponding .sh file found for the zip archive."
        exit 1
    fi
fi

# Create a temporary directory and extract installer files to it
tempdir=$(mktemp -d)
trap 'rm -rf "$tempdir"' EXIT
bash "$installer_script" --noexec --target "$tempdir"

# Suggest a default install directory
default_install_dir=$(cat $tempdir/default_install_path.txt)
default_install_dir=$HOME/st/$(basename $default_install_dir)

if [ -d "$default_install_dir" ]; then
    echo "Directory $default_install_dir already exists."
    exit 1
fi

echo "Suggested install directory: $default_install_dir"
read -p "Do you want to use this directory? (y/n): " confirm

if [[ -z "$confirm" || "$confirm" == "y" || "$confirm" == "Y" ]]; then
    install_dir="$default_install_dir"
else
    echo "Installation aborted."
    exit 1
fi

# Create the install directory if it doesn't exist
mkdir -p "$install_dir"
tar zxf "$tempdir"/st-stm32cubeclt*.tar.gz -C "$install_dir"

echo "Installation completed successfully."
