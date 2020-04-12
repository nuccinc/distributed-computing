#!/usr/bin/env bash

### VARIABLES:
IMG_ALPINE='boinc/client:baseimage-alpine'
IMG_UBUNTU='boinc/client:latest'
# Ability to add custom project url via environment variable:
PROJECT_URL="${PROJECT_URL:-http://boinc.bakerlab.org/rosetta/}"
# Ability to add custom weak key via environment variable:
WEAK_KEY="${WEAK_KEY:-2108683_fdd846588bee255b50901b8b678d52ec}"
# Ability to add custom command line options via environment variable:
if [[ ($1 = "--docker") || (-z $1) ]]; then
  BOINC_CMD_LINE_OPTIONS="${BOINC_CMD_LINE_OPTIONS:---allow_remote_gui_rpc --attach_project ${PROJECT_URL} ${WEAK_KEY}}"
fi
# Ability to set custom Docker volume via environment variable:
VOLUME="${VOLUME:-${HOME}/.boinc}"
# Ability to set custom Docker image via environment variable:
IMG="${IMG:-${IMG_ALPINE}}"
# Contents of cc_config.xml:
CC_CONFIG='<cc_config>
   <options>
       <allow_remote_gui_rpc>1</allow_remote_gui_rpc>
   </options>
</cc_config>'

### NUCCD SCRIPT:
read -r -d '' NUCCD <<'EOF'
#!/bin/bash

usage() {
  echo '
USAGE: nuccd [ARGS]

allowmorework    requests more work from current project.
nomorwork        requests no more work after current work units finish.
suspend          suspends all current tasks.
resume           resumes all current tasks.
[boinccmd args]  execute any boinccmd arguments.
start            starts to boinc docker container.
stop             stops the boinc docker container.
remove           removes the boinc docker container.
uninstall        stops and removes container, removes all boinc/client images, and deletes nuccd.
help             shows this help dialog
'
}

if [[ $1 = "allowmorework" ]]; then
  docker exec boinc boinccmd --project http://boinc.bakerlab.org/rosetta/ allowmorework
elif [[ $1 = "nomorework" ]]; then
  docker exec boinc boinccmd --project http://boinc.bakerlab.org/rosetta/ nomorework
elif [[ $1 = "suspend" ]]; then
  docker exec boinc boinccmd --project http://boinc.bakerlab.org/rosetta/ suspend
elif [[ $1 = "resume" ]]; then
  docker exec boinc boinccmd --project http://boinc.bakerlab.org/rosetta/ resume
elif [[ $1 = "stop" ]]; then
  docker stop boinc
elif [[ $1 = "start" ]]; then
  docker start boinc
elif [[ $1 = "remove" ]]; then
  docker stop boinc 2>/dev/null
  docker rm boinc
elif [[ $1 = "uninstall" ]]; then
  docker stop boinc 2>/dev/null
  docker rm boinc 2>/dev/null
  docker images | grep boinc | awk '{print $3}' | xargs docker rmi 2>/dev/null
  sudo rm -f /usr/local/bin/nuccd
elif [[ ($1 = "-h") || (-n $(echo "${@}" | grep help)) ]]; then
  usage
else
  docker exec boinc boinccmd "${@}"
  if [[ $? -ne 0 ]]; then
    usage
  fi
fi
EOF

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
        if ! command -v 'curl' &> /dev/null; then
          echo -e '\nPlease install curl and run this script again.\n'
          exit
        fi
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
  mkdir -p "${VOLUME}"
  sudo chown -R "${LOGNAME}" "${VOLUME}"
  echo "${CC_CONFIG}" > "${VOLUME}/cc_config.xml"
  sudo docker stop boinc 2>/dev/null
  sudo docker rm boinc 2>/dev/null
  sudo docker run -d --restart always --name boinc -p 31416:31416 -v "${VOLUME}:/var/lib/boinc" -e BOINC_GUI_RPC_PASSWORD="${BOINC_GUI_RPC_PASSWORD}" -e BOINC_CMD_LINE_OPTIONS="${BOINC_CMD_LINE_OPTIONS}" "${IMG}"
  if [[ $? -ne 0 ]]; then
    echo -e "\nIf you are running a firewall like firewalld or ufw, you will need to"
    echo -e "disable it or create a rule for port 31416, reboot, and run $0 again.\n"
    exit
  fi

  # Details:
  echo -e "\nRun 'docker exec -it boinc /bin/sh' to exec into the container."
  echo -e "Run 'docker exec boin boinccmd --help for commands to execute in this similar manner.\n"
  read -rp 'Do you wish to get the current status? [y/n] ' getstatus
  if [[ $getstatus = "y" ]]; then
    sudo docker exec boinc boinccmd --get_state
  fi
  echo -e "\nInstalling nuccd helper script to /usr/local/bin..."
  echo "$NUCCD" | sudo tee /usr/local/bin/nuccd > /dev/null
  sudo chmod +x /usr/local/bin/nuccd
  /usr/local/bin/nuccd --help
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
  pkg_manager_config
  ${UPDATE_PKG_CACHE}
  if [[ $DISTRO_NAME = "macos" ]]; then
    brew cask install boinc
    CONFIG_DIR='/Library/Application Support/BOINC Data'
    echo "$BOINC_GUI_RPC_PASSWORD" > "${CONFIG_DIR}/gui_rpc_auth.cfg"
    echo "$CC_CONFIG" > "${CONFIG_DIR}/cc_config.xml"
    echo '127.0.0.1' > "${CONFIG_DIR}/remote_hosts.cfg"
    (/Applications/BOINCmanager.app/Contents/Resources/boinc -redirectio -dir "${CONFIG_DIR}/" --daemon --allow_remote_gui_rpc --attach_project "${PROJECT_URL}" "${WEAK_KEY}" &) >/dev/null 2>&1
    open /Applications/BOINCManager.app
  elif [[ ($DISTRO_NAME = "ubuntu") || ($DISTRO_NAME = "kali") ]]; then
      echo -e '\nPlease select the appropriate BOINC client:\n'
      echo '1) boinc-client (DEFAULT)'
      echo '2) boinc-client-nvidia-cuda (NVIDIA CUDA support)'
      echo '3) boinc-client-opencl (AMD/ATI OpenCL support)'
      echo
      read -rp 'Selection Number: ' boinc_client
    if [[ $boinc_client -eq 1 ]]; then
      packages='boinc-client'
    elif [[ $boinc_client -eq 2 ]]; then
      packages='boinc-client-nvidia-cuda'
    elif [[ $boinc_client -eq 3 ]]; then
      packages='boinc-client-opencl'
    else
      packages='boinc-client'
    fi
  else
    if [[ $DISTRO_NAME = "centos" ]]; then
      wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
      sudo yum localinstall -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
      ${UPDATE_PKG_CACHE}
    fi
    packages='boinc-client'
    echo -e '\nThe following will allow you to install BOINC local management utilities:'
    read -rp 'Do you intend to manage projects from this local machine from a GUI or TUI interface? [y/n] ' local_mgmt
    echo
    if [[ ($local_mgmt = 'y') || ($local_mgmt = 'yes') ]]; then
      if [[ ($DISTRO_NAME != "fedora") && ($DISTRO_NAME != "centos") ]]; then
        echo -e 'Please select your preferred BOINC Manager:\n'
        echo '1) boinc-manager - GUI interface to control and monitor the BOINC core client'
        echo '2) boinctui - Fullscreen terminal user interface (TUI) for BOINC core client'
        echo '3) BOTH'
        echo
        read -rp 'Selection Number: ' boinc_manager
        if [[ $boinc_manager -eq 1 ]]; then
          packages="${packages} boinc-manager"
        elif [[ $boinc_manager -eq 2 ]]; then
          packages="${packages} boinctui"
        elif [[ $boinc_manager -eq 3 ]]; then
          packages="${packages} boinc-manager boinctui"
        fi
      else
        packages="${packages} boinc-manager"
      fi
    fi
    ${PKG_INSTALL} ${packages}
    if [[ ($DISTRO_NAME = "fedora") || ($DISTRO_NAME = "centos") ]]; then
      CONFIG_DIR='/var/lib/boinc'
      BOINC_DIR="${CONFIG_DIR}"
    else
      CONFIG_DIR='/etc/boinc-client'
      BOINC_DIR='/usr/lib/boinc-client'
    fi
    BOINC_CMD_LINE_OPTIONS="${BOINC_CMD_LINE_OPTIONS:---allow_remote_gui_rpc --daemon --dir ${BOINC_DIR} --project_attach ${PROJECT_URL} ${WEAK_KEY}}"
    echo "$BOINC_GUI_RPC_PASSWORD" | sudo tee "${CONFIG_DIR}/gui_rpc_auth.cfg" > /dev/null
    echo "$CC_CONFIG" | sudo tee "${CONFIG_DIR}/cc_config.xml" > /dev/null
    echo '127.0.0.1' | sudo tee "${CONFIG_DIR}/remote_hosts.cfg" > /dev/null
    sudo chown -R boinc:boinc "$BOINC_DIR"
    if [[ $LOGNAME != "root" ]]; then
      sudo usermod -G boinc -a "$LOGNAME"
      sudo chmod g+rw ${CONFIG_DIR}/gui_rpc_auth.cfg
      sudo chmod g+rw ${CONFIG_DIR}/*.*
      sudo ln -sf "${CONFIG_DIR}/gui_rpc_auth.cfg" "/home/${LOGNAME}/gui_rpc_auth.cfg"
      sudo chown boinc:boinc "/home/${LOGNAME}/gui_rpc_auth.cfg"
      sudo chown "$LOGNAME" "${CONFIG_DIR}/gui_rpc_auth.cfg"
    fi
    if [[ $DISTRO_NAME = "kali" ]]; then
      sudo sed -i 's/User=boinc/User=root/' '/lib/systemd/system/boinc-client.service'
      sudo systemctl daemon-reload
    fi
    sudo systemctl stop boinc-client.service
    sudo systemctl start boinc-client.service
    sudo systemctl enable boinc-client.service
    sleep 5
    boinccmd --passwd "$(cat "${CONFIG_DIR}/gui_rpc_auth.cfg")" --project_attach "${PROJECT_URL}" "${WEAK_KEY}"
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
  echo -e 'This can be changed at any time by changing the value in gui_rpc_auth.cfg\n'
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
  echo
  if [[ $DISTRO_NAME != "macos" ]]; then
    read -rp 'Would you like to get the current state? [y/n] ' get_state
    if [[ ($get_state = 'y') || ($get_state = 'yes') ]]; then
      boinccmd --get_state
    fi
  fi
  echo -e "\nFeel free to launch a BOINC Manager or use the command 'boinccmd' to monitor your tasks.\n"
else
  docker_install
  echo -e "\nIf have just now installing Docker, please run su - ${LOGNAME} to inherit docker group privileges."
fi
