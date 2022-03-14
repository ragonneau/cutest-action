#!/usr/bin/env bash

# Run the installation scripts
if [[ "$RUNNER_OS" == "Linux" ]]; then
    source $GITHUB_ACTION_PATH/install_linux.sh
elif [[ "$RUNNER_OS" == "macOS" ]]; then
    source $GITHUB_ACTION_PATH/install_macos.sh
else
    exit 1
fi

# Set the environment variables
{
    echo "ARCHDEFS=$ARCHDEFS"
    echo "SIFDECODE=$SIFDECODE"
    echo "CUTEST=$CUTEST"
    echo "MASTSIF=$MASTSIF"
    echo "MYARCH=$MYARCH"
} >> "$GITHUB_ENV"

# Set the output of the action
echo "::set-output name=version::$(cut -d " " -f 4 "$CUTEST/version")"
