#!/usr/bin/env bash

### VARIABLES:
IMG_ALPINE='boinc/client:baseimage-alpine'
IMG_UBUNTU='boinc/client:latest'
# Ability to add custom command line options via env if you don't want defaults:
if [[ -z $BOINC_CMD_LINE_OPTIONS ]]; then
  if [[ $1 = "native" ]]; then
    BOINC_CMD_LINE_OPTIONS='--allow_remote_gui_rpc --project_attach http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec'
  fi
else
  BOINC_CMD_LINE_OPTIONS='--allow_remote_gui_rpc --attach_project http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec'
fi
# Ability to set custom Docker volume via environment variable:
if [[ -z $VOLUME ]]; then
  VOLUME="${HOME}/.boinc"
fi
# Ability to set custom Docker image via environment variable:
if [[ -z $IMG ]]; then
  IMG="${IMG_ALPINE}"
fi

### FUNCTIONS:
show_help() {
echo -e '
Usage: ./quickstart.sh [--native|--docker]
Installs BOINC client and attaches to NUCC United project.

--native    Automatically installs the BOINC client natively on supported operating systems.
--docker    Installs the BOINC client via Docker (will install Docker if not installed).
--help      Shows this help dialog.

If run without parameters, "--docker" is implied.
'
}
docker_install() {
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
}
not_supported() {
  echo -e '\n[ERROR] This script is not currently supported for your operating system.'
  exit 1
}
distro_check() {
  if [[ -n $arch ]]; then
    DISTRO_NAME='arch'
  elif [[ -n $debian ]]; then
    DISTRO_NAME='debian'
  elif [[ -n $raspbian ]]; then
    DISTRO_NAME='raspbian'
  elif [[ -n $fedora ]]; then
    DISTRO_NAME='fedora'
    version_id=$(echo "$release_info" | grep 'VERSION_ID' | cut -d'=' -f2)
  elif [[ -n $centos ]]; then
    DISTRO_NAME='centos'
  elif [[ -n $kali ]]; then
    DISTRO_NAME='kali'
  elif [[ -n $ubuntu ]]; then
    DISTRO_NAME='ubuntu'
  elif [[ -n $macos ]]; then
    DISTRO_NAME='macos'
  fi
}
pkg_manager_config() {
  if command -v apt-get &> /dev/null; then
    if [[ $USER != 'root' ]]; then
      PKG_MANAGER='sudo apt-get'
    else
      PKG_MANAGER='apt-get'
    fi
    UPDATE_PKG_CACHE="${PKG_MANAGER} update"
    PKG_INSTALL="${PKG_MANAGER} --yes install"
    PKG_REMOVE="${PKG_MANAGER} --silent --yes"
  elif command -v pacman &> /dev/null; then
    if [[ $USER != 'root' ]]; then
      PKG_MANAGER='sudo pacman'
    else
      PKG_MANAGER='pacman'
    fi
    UPDATE_PKG_CACHE="${PKG_MANAGER} -Sy"
    PKG_INSTALL="${PKG_MANAGER} --noconfirm -S"
    PKG_REMOVE="${PKG_MANAGER} --noconfirm -Rsn"
  elif [[ $DISTRO = "centos" ]]; then
    if [[ $USER != 'root' ]]; then
      PKG_MANAGER='sudo yum'
    else
      PKG_MANAGER='yum'
    fi
    UPDATE_PKG_CACHE="${PKG_MANAGER} check-update"
    PKG_INSTALL="${PKG_MANAGER} install -y"
    PKG_REMOVE="${PKG_MANAGER} remove -y"
  elif command -v dnf &> /dev/null; then
    if [[ $USER != 'root' ]]; then
      PKG_MANAGER='sudo dnf'
    else
      PKG_MANAGER='dnf'
    fi
    UPDATE_PKG_CACHE="${PKG_MANAGER} check-update"
    PKG_INSTALL="${PKG_MANAGER} install -y"
    PKG_REMOVE="${PKG_MANAGER} remove -y"
  elif [[ $DISTRO_NAME = "macos" ]]; then
    if command -v brew &> /dev/null; then
      PKG_MANAGER='brew'
      UPDATE_PKG_CACHE="${PKG_MANAGER} update"
      PKG_INSTALL="${PKG_MANAGER} install"
      PKG_REMOVE="${PKG_MANAGER} uninstall"
    else
      echo -e "\nThis installation requires the Homebrew package manager.\n"
      read -rp 'Do you wish to install Homebrew now? [y/n] ' homebrew
      if [[ ($homebrew = y) || ($homebrew = yes) ]]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      else
        not_supported
      fi
    fi
  else
    not_supported
  fi
}
native_install() {
  ### REMOVE LATER
  ### Fail-safe, native install for only tested distros:
  if [[ $DISTRO_NAME != "macos" ]]; then
    not_supported
  fi
  ${UPDATE_PKG_CACHE}
  if [[ $DISTRO_NAME = "macos" ]]; then
    brew cask install boinc
    (/Applications/BOINCmanager.app/Contents/Resources/boinc -redirectio -dir "/Library/Application Support/BOINC Data/" --daemon --attach_project http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec &) >/dev/null 2>&1
    open /Applications/BOINCManager.app
  fi
}

###################################################################
# START:
###################################################################

# Show help:
if [[ -n $(echo "${@}" | grep -E '(\-h)|(help)') ]]; then
  show_help && exit
fi

# If password not set by env, prompt to set it:
if [[ -z $BOINC_GUI_RPC_PASSWORD ]]; then
  echo
  read -rp 'Please enter a value for the BOINC_GUI_RPC_PASSWORD: ' BOINC_GUI_RPC_PASSWORD
  echo 'This can be changed at any time by changing the value in gui_rpc_auth.cfg'
fi

if [[ $1 = "--native" ]]; then
  # Distro Version Info:
  macos="$(uname -a | grep Darwin)"
  if [[ -z $macos ]]; then
    release_info="$(cat /etc/*-release)"
    arch="$(echo "$release_info" | grep -i 'ID=arch')"
    centos="$(echo "$release_info" | grep -iE '(ID="centos")|(ID="rhel")|(ID="amzn")')"
    debian="$(echo "$release_info" | grep -i 'ID=debian')"
    fedora="$(echo "$release_info" | grep -i 'ID=fedora')"
    kali="$(echo "$release_info" | grep -i 'ID=kali')"
    raspbian="$(echo "$release_info" | grep -i 'ID=Raspbian')"
    ubuntu="$(echo "$release_info" | grep -i 'ID=ubuntu')"
    version_id="$(echo "$release_info" | grep 'VERSION_ID' | awk -F '"' '{print $2}' | cut -d'.' -f1)"
    # fedora $version_id determined later in script
    VERSION="$(echo "$release_info" | grep 'VERSION=' | awk -F '(' '{print $2}' | cut -d')' -f1 | tr "[:upper:]" "[:lower:]" | awk '{print $1}' | awk 'NF>0')"
  fi
  distro_check
  native_install
else
  docker_install
fi
