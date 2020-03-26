#!/usr/bin/env bash

IMG_ALPINE='boinc/client:baseimage-alpine'
IMG_UBUNTU='boinc/client:latest'

# Ability to add custom command line options via env if you don't want defaults:
if [[ -z $BOINC_CMD_LINE_OPTIONS ]]; then
  BOINC_CMD_LINE_OPTIONS='--allow_remote_gui_rpc --attach_project http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec'
fi

# Ability to set custom volume via env if you don't want defaults:
if [[ -z $VOLUME ]]; then
  VOLUME="${HOME}/.boinc"
fi

# Check for args:
if [[ $1 = "alpine" ]]; then
  IMG="${IMG_ALPINE}"
elif [[ $1 = "ubuntu" ]]; then
  IMG="${IMG_UBUNTU}"
elif [[ -z $IMG ]]; then
  IMG="${IMG_ALPINE}"
fi

# Check to see if Docker is installed
if ! command -v 'docker' &> /dev/null; then
  echo -e "\nIt looks like you don't have Docker installed."
  read -rp "Would you like to install it now? [y/n] " ans
  if [[ $ans = "y" ]]; then
    if [[ -n $(uname -a | grep -iE '(linux)|(darwin)') ]]; then
      curl -fsSL 'https://raw.githubusercontent.com/phx/dockerinstall/master/install_docker.sh' | bash
    else
      echo -e "\nYour operating system is not currently supported by the Docker auto-installer."
      echo -e "Please download and install Docker before proceeding."
    fi
  else
    echo 'Please install Docker before proceeding.'
  fi
fi

# Check for MacOS:
if [[ -n $(uname -a | grep Darwin) ]]; then
  MACOS=1
fi

# If password not set by env, prompt to set it:
if [[ -z $BOINC_GUI_RPC_PASSWORD ]]; then
  echo
  read -rp 'Please enter a value for the BOINC_GUI_RPC_PASSWORD: ' BOINC_GUI_RPC_PASSWORD
  echo 'This can be changed at any time by changing the value in gui_rpc_auth.cfg'
fi

# Where the magic happens:
docker run -d --restart always --name boinc -p 31416:31416 -v "${VOLUME}:/var/lib/boinc" -e BOINC_GUI_RPC_PASSWORD="${BOINC_GUI_RPC_PASSWORD}" -e BOINC_CMD_LINE_OPTIONS="${BOINC_CMD_LINE_OPTIONS}" "${IMG}"

# Details:
echo
echo "If you wish to manage your tasks on this machine remotely from another machine on the network:"
echo "Manually add the IP to ${VOLUME}/remote_hosts.cfg, and run 'docker restart boinc'."
echo
echo "Run 'docker exec -it boinc /bin/sh' to exec into the container."
echo "Run 'docker exec boin boinccmd --help for commands to execute in this similar manner."
echo
read -rp 'Do you wish to get the current status? [y/n] ' getstatus
if [[ $getstatus = "y" ]]; then
  docker exec boinc boinccmd --get_state
fi
