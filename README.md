![Platform: ALL](https://img.shields.io/badge/platform-ALL-green)
![Follow @NUCC Inc. on Twitter](https://img.shields.io/twitter/follow/nucc_inc?label=follow&style=social)
![Tweet about this Project](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Fgithub.com%2Fphx%2Fnucc)

![NUCC logo](./logo.png?raw=true)

# NUCC Distributed Computing to Aid in COVID-19 Research

**Latest Update: April 2, 2020**

Join [The National Upcycled Computing Collective (NUCC)](https://www.nuccinc.org/) in a collaborative effort to combine our resources in order to aid in COVID-19 research.
This project draws heavily from [BOINC's default Docker configurations](https://github.com/BOINC/boinc-client-docker).
The difference is that without registering for any accounts or sharing any personal information, you will automatically be connected to NUCC's ongoing [Rosetta@home](https://boinc.bakerlab.org/)
folding research team that is actively processing COVID-19-specific workloads.

---

### The fastest and easiest way to contribute if you already have Docker installed:

Copy/paste the following one-liner to get started immediately on MacOS or Linux:

`docker run -d --restart always --name boinc -p 31416 -v "${HOME}/.boinc:/var/lib/boinc" -e BOINC_GUI_RPC_PASSWORD="123" -e BOINC_CMD_LINE_OPTIONS="--allow_remote_gui_rpc --attach_project http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec" boinc/client:baseimage-alpine`


### The fastest and easiest way to contribute if you already have BOINC installed natively:
- Windows:
  - `C:\PROGRA~1\BOINC\boinccmd.exe --project_attach http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec`
- MacOS:
  - `(/Applications/BOINCManager.app/Contents/Resources/boinc -redirectio "/Library/Application Support/BOINC Data/" --daemon --allow_remote_gui_rpc --attach_project http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec &) >/dev/null 2>&1 && open /Applications/BOINCManager.app`
- Linux:
  - `boinccmd --project_attach http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec`

Note: If you don't have things configured exactly right, you may have to pass the password located in `gui_rpc_passwd.cfg` in the command line to `boinccmd`.

Example: `boinccmd --passwd <yourpassword> --project_attach http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec`

---

**Contents**
- [Automated Linux/MacOS Docker-based Installation](#automated-linux-and-macos-docker-installation)
- [Automated Windows Native Installation](#automated-windows-native-installation)
- [Automated Windows Docker-based Installation](#windows-docker-installation)
- [Automated MacOS and Linux Native Installation](#automated-macos-and-linux-native-installation)
- [BSD Jail Installation](#bsd-jail-installation)
- [Manual Installation](#manual-installation)
- [Docker Supported Architectures and Tags](#docker-supported-architectures-and-tags)
- [Docker Swarm Mode](#docker-swarm-mode)
- [Viewing and Managing Workloads](#viewing-and-managing-workloads)
- [BOINC Commands and Shortcuts](#boinc-commands-and-shortcuts)
- [Updates](#updates)
- [About NUCC](#about-the-national-upcycled-computing-collective)

---

## Automated Linux and MacOS Docker Installation

If Docker is not already installed, the [`quickstart.sh`](quickstart.sh) script will install Docker via [The Almost Universal Docker Installer](https://github.com/phx/dockerinstall),
then pull [the official boinc/client image from DockerHub](https://hub.docker.com/r/boinc/client) ([`base-alpine`](https://github.com/BOINC/boinc-client-docker/blob/master/Dockerfile.base-alpine) by default).

You can run a custom image by running `IMG=boinc/client[tag-name] ./quickstart.sh` (see [Supported Architectures and Tags](#docker-supported-architectures-and-tags)).

- MacOS 10.8+
- Ubuntu
- Debian 8+
- Raspbian 8+
- CentOS/RHEL/Amazon Linux
- Fedora 30+
- Kali 2018+ (based on Debian Stretch)
- Arch

```
git clone http://github.com/phx/nucc.git
cd nucc
./quickstart.sh
```

*Note: If the script errors out after installing Docker, run it again in a new login shell that recognizes your user as a member of the `docker` group, and you should be squared away.*

If you already have a team or want to specify an alternate project, don't be discouraged -- you can still use `quickstart.sh`!  Simply speficy your project URL and/or weak key
in the supported environment variables:

| Environment variable | Default value if unset |
| :--- | :--- |
| `$IMG` | `boinc/client:baseimage-alpine` |
| `$VOLUME` | `$HOME/.boinc` |
| `$PROJECT_URL` | `http://boinc.bakerlab.org/rosetta/` |
| `$WEAK_KEY` | `2108683_fdd846588bee255b50901b8b678d52ec` |
| `$BOINC_CMD_LINE_OPTIONS` | `--allow_remote_gui_rpc --project_attach ${PROJECT_URL} ${WEAK_KEY}` |
| `$BOINC_GUI_RPC_PASSWORD` | `[prompt]` |

#### Firewall Caveats:

If you are running `firewalld` or `ufw` or something like that, you will need to either create a rule for the `docker0` interface on port `31416`.

Alternately, you can disable the service altogether by running `systemctl disable firewalld` (etc.), and then rebooting.

*This is necessary to be able to resolve DNS inside the containers.*

If you have already installed and spun up a container via `quickstart.sh`, just implement the firewall rules and run `docker restart boinc`.

If you disable the firewall completely, the `boinc` container should spin up immediately after reboot and will be able to process workloads successfully.

---

## Automated Windows Native Installation:

Download the zip file of the repository, unzip it, and run `quickstart.bat --native --attach` from an elevated (Administrator) command prompt.

Alternatively, if you have `git` installed, launch an elevated (Administrator) command promt and run the following:

```
git clone https://github.com/phx/nucc.git
cd nucc
quickstart.bat --native
```

This will install the [Chocolatey](https://chocolatey.org/) package manager, which will then install BOINC.

It will automatically connect to the correct project and start processing workloads immediately.

I find it easier to view and manage by going to `View > Advanced`, as things appear to be more organized.

## Windows Docker Installation:

Download the zip file of the repository, unzip it, and run `quickstart.bat` from an elevated (Administrator) command prompt.

Alternatively, if you have `git` installed, launch an elevated (Administrator) command promt and run the following:

```
git clone https://github.com/phx/nucc.git
cd nucc
quickstart.bat --docker
```

This will install the [Chocolatey](https://chocolatey.org/) package manager, which will then install Docker Desktop.

When Docker Desktop is launched for the first time, you will need to log out and log back in for it to finish starting up.

- Right-click the Docker icon in the taskbar
- Go to Preferences > Resources > Filesharing
- Check to enable the C drive
- Click "Apply and Restart"
- Wait for Docker to *completely* finish restarting
- Run `quickstart.bat --docker` again from an elevated prompt to start processing workloads immediately

*When running the Docker image for the first time, Windows will ask to confirm if Docker can access your C drive.*

---

## Automated MacOS and Linux Native Installation

- Tested Operating Systems:
  - MacOS
  - Ubuntu
  - Debian
  - Kali

```
git clone https://github.com/phx/nucc
cd nucc
./quickstart.sh --native
```

---

## BSD Jail Installation

**[Documentation for FreeBSD (specifically, FreeNAS) can be found in this blog post](https://bookandcode.com/nuccbsd)**.

If you have any trouble, reach out to me on Discord (if you know me), submit an issue, or leave a comment on the post.

---

## Manual Installation

Follow [the official instructions](https://boinc.berkeley.edu/wiki/Installing_BOINC) to install BOINC locally.

After starting BOINC, cancel out of the "Select a Project" window if it pops up, and run the command below to start choochin':

`boinccmd --project_attach http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec`

If running on Linux or MacOS, you may find it easier to go to `View > Advanced` to monitor things.

**Note:** `boinccmd` is typically only in your `$PATH` on Linux. 

---

## Docker Supported Architectures and Tags

Not all of the BOINC images below are compatible with the COVID-19 Rosetta@home workloads.  To be perfectly clear, Rosetta@home
is only handing out ***processor-focused*** workloads.  This means if you want to take advantage of your beefy GPU, you will be better off
focusing on something like [Folding@home](https://foldingathome.org/), which can take advantage of that.  Also, Rosetta@home is not currently
supporting ARM-based workloads.

The current issue with Folding@home is that the number of servers sending data back is causing a DDOS on their systems as they are receiving the folded results.
As a result of this, the work units aren't finishing, and no work can be handed out.  They have engaged several companies to help, but this is the primary reason
for NUCC choosing to work with Rosetta@home for the COVID-19 research in particular, as they are handing out 100% COVID-19-specific work units immediately and efficiently.

NUCC will have additional projects in the future with [Folding@home](https://foldingathome.org/) and [GPUGRID](https://gpugrid.net/),
and we will continue to update this page with instructions on how to connect to those particular projects.

However, in the meantime, [Rosetta@home](https://boinc.bakerlab.org/) remains the best possible solution for continuously receiving
and processing workloads that specifically target COVID-19 in particular, which is why NUCC has chosen the current solution.   

BOINC's default image is `baseimage-ubuntu` or `latest`, which uses `glibc`, however NUCC's default image from the quickstart scripts
is `baseimage-alpine`, which uses `musl` instead.  If this causes any issues with future projects, we will change to the Ubuntu base image,
but for now, Alpine is working perfectly with our Rosetta@home workloads, and the image itself is much leaner, which was our reason for choosing
it as our default. 

If you wish, you can specify the `boinc/client` image with any of the tags below in order to use one of the specialized versions instead of `baseimage-alpine`.

These can be used in the Linux/MacOS one-liner at the top of this page or passed as the `$IMG` environment variable to `quickstart.sh`:
- `IMG=boinc/client:[image-name] ./quickstart.sh`

They can also be passed as a command line argument to to `quickstart.bat`:
- `quickstart.bat --docker --image boinc/client:[image-name]`

---

### x86-64
| Tag | Info |
| :--- | :--- |
| `latest`, `baseimage-ubuntu` | Ubuntu based BOINC client. All of BOINC's  **x86-64** images are based on this. |
| `baseimage-alpine` | Alpine based BOINC client, wich is much slimmer and used by default with [`quickstart.bat`](quickstart.bat) and [`quickstart.sh`](quickstart.sh) |
| `amd` | AMD GPU-savvy BOINC client. Check the usage [below](#amd-gpu-savvy-boinc-client-usage). |
| `intel` | Intel GPU-savvy BOINC client. It supports Broadwell (5th generation) CPUs and beyond. Check the usage [below](#intel-gpu-savvy-boinc-client-usage). |
| `intel-legacy` | Legacy Intel GPU-savvy BOINC client (Sandybridge - 2nd Gen, Ivybridge - 3rd Gen, Haswell - 4th Gen). Check the usage [below](#legacy-intel-gpu-savvy-boinc-client-usage). |
| `multi-gpu` | Intel & Nvidia-savvy BOINC client. Check the usage [below](#multi-gpu-savvy-boinc-client-usage). |
| `nvidia` | NVIDIA-savvy (CUDA & OpenCL) BOINC client. Check the usage [below](#nvidia-savvy-boinc-client-usage). |
| `virtualbox` | VirtualBox-savvy BOINC client. Check the usage [below](#virtualbox-savvy-boinc-client-usage). |

### ARM
| Tag | Info |
| :--- | :--- |
| `arm32v7` | ARMv7 32-bit savvy BOINC client. Check the usage [below](#armv7-32-bit-savvy-boinc-client-usage). |
| `arm64v8` | ARMv8 64-bit savvy BOINC client. Check the usage [below](#armv8-64-bit-savvy-boinc-client-usage). |


#### AMD GPU-savvy BOINC client usage
- Install the [ROCm Driver](https://rocm.github.io/ROCmInstall.html).
- Reboot your system.
- Run the following command.
  - Linux: `IMG=boinc/client:amd ./quickstart.sh`
  - Windows: `quickstart.bat --docker --image boinc/client:amd`

#### Intel GPU-savvy BOINC client usage
- Install the Intel GPU Driver.
- Run the following command:
  - Linux: `IMG=boinc/client:intel ./quickstart.sh`
  - Windows: `quickstart.bat --docker --image boinc/client:intel`

#### Legacy Intel GPU-savvy BOINC client usage
- Install the Intel GPU Driver.
- Run the following command:
  - Linux: `IMG=boinc/client:intel-legacy ./quickstart.sh`
  - Windows: `quickstart.bat --docker --image boinc/client:intel-legacy`

#### Multi GPU-savvy BOINC client usage
- Make sure you have installed the [NVIDIA driver](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#how-do-i-install-the-nvidia-driver).
- Install the NVIDIA-Docker version 2.0 by following the instructions [here](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(version-2.0)).
- Run the following command:
  - Linux: `IMG=boinc/client:multi-gpu ./quickstart.sh`
  - Windows: `quickstart.bat --docker --image boinc/client:multi-gpu`
 
#### NVIDIA-savvy BOINC client usage
- Make sure you have installed the [NVIDIA driver](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#how-do-i-install-the-nvidia-driver).
- Install the NVIDIA-Docker version 2.0 by following the instructions [here](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(version-2.0)).
- Run the following command:
  - Linux: `IMG=boinc/client:nvidia ./quickstart.sh`
  - Windows: `quickstart.bat --docker --image boinc/client:nvidia`

#### VirtualBox-savvy BOINC client usage

- Install the `virtualbox-dkms` package on the host.
- Run the following command:
  - Linux: `IMG=boinc/client:virtualbox ./quickstart.sh`
  - Windows: `quickstart.bat --docker --image boinc/client:virtualbox`

#### ARMv7 32-bit savvy BOINC client usage
- Make sure you have [Docker installed on your Raspberry Pi](https://www.raspberrypi.org/blog/docker-comes-to-raspberry-pi/) or you are using a [Docker friendly OS](https://blog.hypriot.com/).
- Run the following command.
  - Linux: `IMG=boinc/client:arm32v7 ./quickstart.sh`
  - Windows: `quickstart.bat --docker --image boinc/client:arm32v7`

#### ARMv8 64-bit savvy BOINC client usage
- Make sure you are using a [64-bit OS on your Raspberry Pi](https://wiki.ubuntu.com/ARM/RaspberryPi#arm64) and have [Docker installed on your Raspberry Pi](https://www.raspberrypi.org/blog/docker-comes-to-raspberry-pi/).
- Run the following command.
  - Linux: `IMG=boinc/client:arm64v8 ./quickstart.sh`
  - Windows: `quickstart.bat --docker --image boinc/client:arm64v8`

---

## Docker Swarm Mode

You can use a Docker Swarm to launch a large number of clients, for example across a cluster that you are using for BOINC computation. First, start the swarm and create a network,

```sh
docker swarm init
docker network create -d overlay --attachable boinc
```

If you want, you can connect other nodes to your swarm by running the appropriate `docker swarm join` command on worker nodes as prompted above (although you can just run on one node too).

Then launch your clients:

```sh
docker service create \
  --replicas <N> \
  --name boinc \
  --network=boinc \
  -p 31416 \
  -e BOINC_GUI_RPC_PASSWORD="123" \
  -e BOINC_CMD_LINE_OPTIONS="--allow_remote_gui_rpc --attach_project http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec" \
  boinc/client
```

You now have `<N>` clients running, distributed across your swarm. You can issue commands to all of your clients via, 

```sh
docker run --rm --network boinc boinc/client boinccmd_swarm --passwd 123 <args>
```

Note you do not need to specify `--host`. The `boinccmd_swarm` command takes care of sending the command to each of the hosts in your swarm.

Docker Swarm does not support `pid=host` mode. As a result, client settings related to non-boinc CPU usage or exclusion apps will not take effect.

---

## Viewing and Managing Workloads

You have a couple of good options here:

- Best Option: [BOINCTASKS](https://efmer.com/download-boinctasks/)
- View tasks from the native BOINC Manager

*For BSD, there is also the `boinc_curses` TUI application, which allows you to view local tasks, and for various Linux distros, there is the `boinctui` package, which I have personally never tried,
but imagine it is probably similar to `boinc_curses` for BSD.*

**For basic tasks, you can refer to [Boinc Commands and Shortcuts](#boinc-commands-and-shortcuts).**

### BOINCTASKS ([Download Here](https://efmer.com/download-boinctasks/))

This is honestly the best option, especially if you are running BOINC from multiple machines on the same network.  The thing I like most about it is that it doesn't require a native BOINC installation
if all you need is the **BOINC Manager**, like if you are running the *BOINC Client* via Docker or from a different machine on the network.  One of the best features is its ability to scan your network
for BOINC clients and automatically add them to the management interface.  BOINCTASKS is the only option if you want to manage multiple clients from a GUI interface without having to disconnect between
viewing each individual client.  It's a Windows program, but is FULLY-COMPATIBLE with *nix hosts via [Wine](https://www.winehq.org/).  It literally took me less than a minute to get it fully-installed
on my Ubuntu laptop, after which I was able to see all the clients on my local network running BOINC, and remotely manage their tasks.

### Native BOINC Manager ([Official Installation Instructions](https://boinc.berkeley.edu/wiki/Installing_BOINC))

If you are running BOINC via Docker, it's a little redundant to download BOINC natively, but you can do so if you want to view and manage the tasks running from a GUI interface.

- Launch BOINC
- If the "Select a Project" pops up, just cancel out of it if you're connecting to a remote BOINC client or Docker container.
- `File > Select Computer`
  - Enter the computer's IP/hostname and password from `gui_rpc_auth.cfg`, and Click "OK".

If you are running BOINC via Docker on your local machine, the IP address will be `127.0.0.1`.  Otherwise, enter the IP of the **HOST** that Docker is running on (not the IP of the container
from the `docker0` interface).  By specifying `-p 31416` in the `docker run` command, we mapped the communication port used by the BOINC client in the Docker container to the host machine.

`Boingmgr` should have no trouble connecting to any Docker container on the network unless prohibited by firewall rules on operating systems such as CentOS or Fedora,
in which case, you should consult the [#firewall-caveats](Firewall Caveats) mini-section for more information.

---

## BOINC Commands and Shortcuts

Two very good `boinccmd` references:

- [https://boinc.berkeley.edu/wiki/Boinccmd_tool](https://boinc.berkeley.edu/wiki/Boinccmd_tool)
- [https://www.systutorials.com/docs/linux/man/1-boinccmd/](https://www.systutorials.com/docs/linux/man/1-boinccmd/)

#### Acces the shell on the Docker container:

`docker exec -it boinc /bin/sh`

This will allow you to be on the machine and run `boinccmd` commands directly.

#### Execute a specific `boinccmd` command inside local docker container directly from the host:

`docker exec boinc boinccmd --command-arguments-here`

#### Attach to NUCC's Rosetta@home Project (this is done automatically in the quickstart scripts):

**Native Installation:**

`boinccmd --project_attach http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec`

**Docker Installation:**

`docker exec [container-name] boinccmd --attach_project http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec`

### For simplicity, the commands below will be listed as local commands. This means 1 of 3 things:

- You should execute them as-is if running the BOINC client on the host
- You should execute them as-is if you have already exec'd into the Docker container
- You should prepend them with `docker exec [container-name] ` if running them against the Docker container with the BOINC client installed.
  - If BOINC was installed via Docker and one of the quickstart scripts, the container name is `boinc`.
  - Example: `docker exec -it boinc boinccmd --get_state`

#### Request no more work after current Rosetta@home tasks finish:

`boinccmd --project http://boinc.bakerlab.org/rosetta/ nomorework`

This is a "graceful stop" and could take up to 24 hours for workloads to completely stop processing:

Later, you can substitue `nomorework` with `allowmorework` to start pulling tasks again

#### Suspend all tasks for the Rosetta@home project:

`boinccmd --project http://boinc.bakerlab.org/rosetta/ suspend`

#### Resume all tasks for the Rosetta@home project:

`boinccmd --project http://boinc.bakerlab.org/rosetta/ resume`

#### Stop or Start the BOINC Docker container:

`docker stop boinc` and `docker start boinc`

This is not recommended, as your current tasks will be abandoned.

**Best practices would be as follows:**

```sh
docker exec boinc boinccmd --project http://boinc.bakerlab.org/rosetta/ suspend
docker stop boinc
docker start boinc
docker exec boinc boinccmd --project http://boinc.bakerlab.org/rosetta/ resume
```

### Docker Helper Script (`nuccd`):

The `nuccd` helper script will be added to `/usr/local/bin/nuccd` as part of the `quickstart.sh` install script for Docker-based installations on MacOS and Linux:

```sh
#!/bin/bash

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
else
  echo '
USAGE: nuccd [OPTIONS]

allowmorework
nomorwork
suspend
resume
start
stop
remove
uninstall
'
fi
```

## Updates

- As of 10:41 AM Central, [https://boinc.berkeley.edu/](https://boinc.berkeley.edu/) appears to be down, which will cause Windows automated native installation to fail.
- Updated `quickstart.bat` for easier and more automated Windows native installation.
- Should have automated native installation compatible with Fedora/CentOS/RHEL in the near future.
- Automated native installation for Arch will come last (sorry, but you guys should already know what you're doing)
- Will eventually additional parameters to `quickstart.bat` in the future to specify custom project URL and weak key for both native and Docker-based installations.

---

## About The National Upcycled Computing Collective

[The National Upcycled Computing Collective, Inc.](http://nuccinc.org) is a 501(c)(3) Nonprofit Organization [NTEE U41] Computer Science, Technology & Engineering, Research Institute (EIN 82-1177433)
as determined by the Internal Revenue Service.  Our mission is to find new uses for technology, thereby extending life cycles with an intent to re-purpose electronic devices responsibly.  For more
information, please visit [https://www.nuccinc.org/about/](https://www.nuccinc.org/about/).
