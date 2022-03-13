#!/usr/bin/env bash

# Install gfortran
brew unlink gcc && brew link gcc

# Install cutest
brew tap optimizers/cutest
brew install cutest --without-single
brew install mastsif
source "$(brew --prefix archdefs)/archdefs.bashrc"
source "$(brew --prefix sifdecode)/sifdecode.bashrc"
source "$(brew --prefix mastsif)/mastsif.bashrc"
source "$(brew --prefix cutest)/cutest.bashrc"
export "MYARCH=mac64.osx.gfo"

# Suppress an annoying warning
echo "MACOSX_DEPLOYMENT_TARGET=$(sw_vers -productVersion | cut -d "." -f 1-2)" >> "$GITHUB_ENV"
