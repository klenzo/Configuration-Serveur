#!/bin/bash

function depot_update() {
    if [[ $DEPOT_UPDATE == true ]]; then
        apt-get update
    fi
}

function package_upgrade() {
    if [[ $PACKAGE_UPGRADE == true ]]; then
        apt-get upgrade -y
    fi
}

function package_install(){
    echo "
    apt-get install $@
    "
    # apt-get install $@
}