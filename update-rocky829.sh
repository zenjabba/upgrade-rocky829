#!/bin/bash

# Function to perform dnf update
function update_dnf() {
    echo "Starting dnf update..."
    while true; do
        dnf update --allowerasing -y

        # Check if the dnf update was successful
        if [ $? -eq 0 ]; then
            echo "dnf update completed successfully."
            rm -f /opt/rocky-leapp-upgrade-started
            reboot
        else
            echo "dnf update failed. Retrying..."
            sleep 5
        fi
    done
}

# Function to install elevate release package
function install_elevate() {
    sudo yum install -y http://repo.almalinux.org/elevate/elevate-release-latest-el$(rpm --eval %rhel).noarch.rpm
}

# Function to install leapp packages
function install_leapp_packages() {
    sudo yum install -y leapp-upgrade leapp-data-rocky
}

# Function to clean up repository configurations
function cleanup_repos() {
    rm -rf /etc/yum.repos.d/CentOS-Stream-*
}

# Function to configure Firewalld settings
function configure_firewalld() {
    sed -i "s/^AllowZoneDrifting=.*/AllowZoneDrifting=no/" /etc/firewalld/firewalld.conf
}

# Function to remove unnecessary package
function remove_unnecessary_package() {
    yum remove redhat-logos -y 
}

# Function to run leapp preupgrade
function run_leapp_preuprade() {
    leapp preupgrade
}

# Function to set leapp answer
function set_leapp_answer() {
    leapp answer --section check_vdo.no_vdo_devices=True
}

# Function to perform the leapp upgrade
function upgrade_leapp() {
    if sudo leapp upgrade; then
        # If the upgrade is successful, touch the upgrade started file
        touch /opt/rocky-leapp-upgrade-started
        
        # Then reboot the system
        echo "Upgrade successful. Rebooting now..."
        sudo reboot
    else
        echo "Leapp upgrade failed. No actions taken."
    fi
}

# Main script execution
if [ -f /opt/rocky-leapp-upgrade-started ]; then
    echo "Rocky LEAPP upgrade already started"
    update_dnf
fi

install_elevate
install_leapp_packages
cleanup_repos
configure_firewalld
remove_unnecessary_package
run_leapp_preuprade
set_leapp_answer
upgrade_leapp
