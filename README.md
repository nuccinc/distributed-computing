![Platform: ALL](https://img.shields.io/badge/platform-ALL-green)
![Follow @NUCC Inc. on Twitter](https://img.shields.io/twitter/follow/nucc_inc?label=follow&style=social)
![Tweet about this Project](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Fgithub.com%2Fphx%2Fnucc)

![NUCC logo](./logo.png?raw=true)

# NUCC Distributed Computing to Aid in COVID-19 Research

**Latest Update: March 23, 2020**

Join [The National Upcycled Computing Collective (NUCC)](https://www.nuccinc.org/) in a collaborative effort to combine our resources in order to aid in COVID-19 research.
This project draws heavily from [BOINC's default Docker configurations](https://github.com/BOINC/boinc-client-docker).
The difference is that without registering for any accounts or sharing any personal information, you will automatically be connected to NUCC's ongoing [Rosetta@home](https://boinc.bakerlab.org/)
folding research team that is actively processing COVID-19-specific workloads.

---

### The fastest and easiest way to contribute if you already have Docker installed:

Copy/paste the following one-liner to get started immediately on MacOS or Linux:

`docker run -d --restart always --name boinc -p 31416 -v "${HOME}/.boinc:/var/lib/boinc" -e BOINC_GUI_RPC_PASSWORD="123" -e BOINC_CMD_LINE_OPTIONS="--allow_remote_gui_rpc --attach_project http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec" boinc/client:baseimage-alpine`

---

**Contents**
- [Windows Native Installation](#windows-native-installation)
- [Windows Docker Installation](#windows-docker-installation)
- [BSD Jail Installation](#bsd-jail-installation)
- [Linux/MacOS Docker Installation](#linux-and-macos-docker-installation)
- [Supported Architectures and Tags](#supported-architectures-and-tags)
- [Docker Swarm mode](#docker-swarm-mode)
- [Updates](#updates)
- [About NUCC](#about-the-national-upcycled-computing-collective)

---

## Windows Native Installation:

Download the zip file of the repository, unzip it, and run `quickstart.bat --native --attach` from an elevated (Administrator) command prompt.

Alternatively, if you have `git` installed, launch an elevated (Administrator) command promt and run the following:

```
git clone https://github.com/phx/nucc.git
cd nucc
quickstart.bat --native --attach
```

This will install the [Chocolatey](https://chocolatey.org/) package manager, which will then install BOINC.

BOINC Manager will automatically launch, at which point you will wait for the *Select a Project* window to pop up.

Cancel out of that window, confirm, and hit [Enter] to continue running the script.

It will automatically connect to the correct project and start processing workloads immediately.

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

## BSD Jail Installation

Documentation on this is in progress.  It does work 100% correctly, and documentation will also include FreeNAS-specific instructions.

---

## Linux and MacOS Docker Installation

### If you don't currently have Docker installed:

- Debian
- Raspbian
- Ubuntu
- Kali 2018+ (based on Debian Stretch)
- Arch
- MacOS

```
git clone http://github.com/phx/nucc.git
cd nucc
./quickstart.sh
```

*If the script errors out after installing Docker, run it again in a new login shell that recognizes your user as a member of the `docker` group, and you should be squared away.*

#### RPM-based platforms, please refer to [the official Docker documentation](https://docs.docker.com/install/) for installing Docker for your particular OS:

I am currently working to build these distros into [The Almost Universal Docker Installer](https://github.com/phx/dockerinstall), which is used by [`quickstart.sh`](quickstart.sh).

- [CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)
- [Fedora](https://docs.docker.com/install/linux/docker-ce/fedora/)

### If you already have Docker installed:

```
git clone http://github.com/phx/nucc.git
cd nucc
./quickstart.sh
```

---

## Supported Architectures and Tags

You can specialize the `boinc/client` image with any of the following tags to use one of the specialized container version instead.

These can be used in the Linux/MacOS one-liner at the top of this page or passed as the `$IMG` environment variable to `quickstart.sh`.

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

## Docker Swarm mode

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

## Updates:

- BSD/FreeNAS documentation forthcoming.
- Documentation on remotely monitoring and managing workloads is in the works.

---

## About The National Upcycled Computing Collective

[The National Upcycled Computing Collective, Inc.](http://nuccinc.org) is a 501(c)(3) Nonprofit Organization [NTEE U41] Computer Science, Technology & Engineering, Research Institute (EIN 82-1177433)
as determined by the Internal Revenue Service.  Our mission is to find new uses for technology, thereby extending life cycles with an intent to re-purpose electronic devices responsibly.  For more
information, please visit [https://www.nuccinc.org/about/](https://www.nuccinc.org/about/).
