![Platform: Linux and Windows](https://img.shields.io/badge/platform-Linux,%20macOS,%20Windows-green)
![Follow @NUCC Inc. on Twitter](https://img.shields.io/twitter/follow/nucc_inc?label=follow&style=social)

# NUCC Distributed Computing to Aid in COVID-19 Research

**Latest Update: March 22, 2020**

Join [The National Upcycled Computing Collective (NUCC)](https://www.nuccinc.org/) in a collaborative effort to combine our resources in order to aid in COVID-19 research.
This project draws heavily from [BOINC's default Docker configurations](https://github.com/BOINC/boinc-client-docker).
The difference is that without registering for any accounts or sharing any personal information, you will automatically be connected to NUCC's ongoing [Rosetta@home](https://boinc.bakerlab.org/)
folding research team that is actively processing COVID-19-specific workloads.

---

## The fastest and easiest way to contribute if you already have Docker installed:

**Copy/paste the following one-liner to get started immediately:**
`docker run -d --name boinc --net host --pid host -v /opt/appdata/boinc:/var/lib/boinc -e BOINC_GUI_RPC_PASSWORD="123" -e BOINC_CMD_LINE_OPTIONS="--allow_remote_gui_rpc --attach_project http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec" boinc/client:baseimage-alpine`

## If you don't currently have Docker installed:

- Debian
- Raspbian
- Ubuntu
- Kali 2018+ (based on Debian Stretch)
- Arch
- macOS

```
git clone http://github.com/phx/nucc.git
cd nucc
./quickstart.sh
```

### Other platforms, please refer to [the official Docker documentation](https://docs.docker.com/install/) for installing Docker for your particular OS:

- [Windows](https://docs.docker.com/docker-for-windows/install/)
- [CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)
- [Fedora](https://docs.docker.com/install/linux/docker-ce/fedora/)
- UNIX: Stay tuned for full docs on how to get COVID-19 research running in a BSD jail (compatible with FreeNAS)

---

## After installing Docker:

- CentOS
- RHEL
- Fedora

```
git clone http://github.com/phx/nucc.git
cd nucc
./quickstart.sh
```

#### Caveats:

The `docker run` command for Windows may be a bit different syntax-wise.  I will provide updates after I have tested on Windows.

---

### Updates:

Helper scripts and further documentation will be listed here in the coming days in order to improve cross-platform compatibility.

## About The National Upcycled Computing Collective

[The National Upcycled Computing Collective, Inc.](http://nuccinc.org) is a 501(c)(3) Nonprofit Organization [NTEE U41] Computer Science, Technology & Engineering, Research Institute (EIN 82-1177433)
as determined by the Internal Revenue Service.  Our mission is to find new uses for technology, thereby extending life cycles with an intent to re-purpose electronic devices responsibly.  For more
information, please visit [https://www.nuccinc.org/about/](https://www.nuccinc.org/about/).
