![Platform: Linux and Windows](https://img.shields.io/badge/platform-Linux,%20macOS,%20Windows-green)
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

## If you don't currently have Docker installed:

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

---

### Other platforms, please refer to [the official Docker documentation](https://docs.docker.com/install/) for installing Docker for your particular OS:

- [CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)
- [Fedora](https://docs.docker.com/install/linux/docker-ce/fedora/)
- UNIX: Stay tuned for full docs on how to get COVID-19 research running in a BSD jail (compatible with FreeNAS)

### After installing Docker:

- CentOS
- RHEL
- Fedora

```
git clone http://github.com/phx/nucc.git
cd nucc
./quickstart.sh
```

---

### Updates:

Helper scripts and further documentation will be listed here in the coming days in order to improve cross-platform compatibility.

## About The National Upcycled Computing Collective

[The National Upcycled Computing Collective, Inc.](http://nuccinc.org) is a 501(c)(3) Nonprofit Organization [NTEE U41] Computer Science, Technology & Engineering, Research Institute (EIN 82-1177433)
as determined by the Internal Revenue Service.  Our mission is to find new uses for technology, thereby extending life cycles with an intent to re-purpose electronic devices responsibly.  For more
information, please visit [https://www.nuccinc.org/about/](https://www.nuccinc.org/about/).
