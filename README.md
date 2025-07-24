# Ansible Execution Environments for SAP LinuxLab Collections

[![Centos9 latest Execution Environment](https://github.com/sap-linuxlab/ansible.executionenvironment/actions/workflows/build-ee-latest.yml/badge.svg)](https://github.com/sap-linuxlab/ansible.executionenvironment/actions/workflows/build-ee-latest.yml)

[![Centos 9 weekky Execution Environment](https://github.com/sap-linuxlab/ansible.executionenvironment/actions/workflows/build-ee-weekly.yml/badge.svg)](https://github.com/sap-linuxlab/ansible.executionenvironment/actions/workflows/build-ee-weekly.yml)

[![Centos 9 weekky Execution Environment](https://github.com/sap-linuxlab/ansible.executionenvironment/actions/workflows/build-ee-stable.yml/badge.svg)](https://github.com/sap-linuxlab/ansible.executionenvironment/actions/workflows/build-ee-stable.yml)

## Overview

The goal of this repository is to create and maintain execution environments for all supported platforms for the community collections. The resulting contaners can be used for consistant development and testing.
This repository should also help to provide recipes to create containers that can be used and maintained by your e.g. in production.
It is planned to create exeution environments with supported ansible versions, python versions on SUSE Leap and Centos

## Requirememts

you need a working podman installation on MacOS, or Linux x86_64.

## Use with ansible-navigator

Create the file `${HOME}/.ansible-navigator.yml` as a default or a `file ansible-navigator.yml` in the root directory of your project with the following content (adapt to your needs):

```[yaml]
---
ansible-navigator:
  execution-environment:
    container-engine: podman
    # Passe diesen Pfad zu deinem Container-Image an
    image: ghcr.io/your-org/sap-ee:latest
    pull:
      # Lädt das Image nur herunter, wenn es lokal nicht vorhanden ist
      policy: missing
    # next lines are optional to pass variable directory
    volume-mounts:
      - src: "./vars"       # directory on host-system
        dest: "/vars"       # target directory in container
```

ansible-navigator will pick this file on the next execution and automatically runs the playbook in this container

## Use with ansible-playbook directly

```bash
podman run --name sap-ee -v ${yourworkdir}:/runner:Z -ti ghcr.io/sap-linuxlab/sap-ee:latest
ansible --version
```

## Maintained images

The execution environments are multi-arch images build for arm64 and amd64 archtectures. (ppc64le is planned)

- ghcr.io/sap-linuxlab/sap-ee:latest        contains the latest collections as published on galaxy.ansible.com
- ghcr.io/sap-linuxlab/sap-ee:latest-dev    contains latest sap collections from sap-linuxlab dev-branch and other latest published collections from galaxy.ansible.com
- ghcr.io/sap-linuxlab/sap-ee:stable        contains well defined collection versions

All other execution environments are tagged with `[dev|stable-]YYMMDD`. For a complete list see [github packages](https://github.com/sap-linuxlab/ansible.executionenvironment/pkgs/container/sap-ee)

The following table contains the list of collections in sap-ee with the according tag.
(latest means latest version from galaxy, dev means current upstream github dev tree)

Collection                   | stable  | latest | latest-dev
-----------------------------|---------|--------|------------
awx.awx                      |  24.6.1 | latest | latest
azure.azcollection           |   3.6.0 | latest | latest
google.cloud                 |   1.6.0 | latest | latest
amazon.aws                   |  10.1.0 | latest | latest
community.aws                |  10.0.0 | latest | latest
vmware.vmware_rest           |   4.8.1 | latest | latest
community.vmware             |   5.7.1 | latest | latest
openstack.cloud              |   1.8.0 | latest | latest
kubernetes.core              |   6.0.0 | latest | latest
kubevirt.core                |   2.2.3 | latest | latest
ovirt.ovirt                  |   3.2.1 | latest | latest
fedora.linux_system_roles    | 1.106.0 | latest | latest
ansible.posix                |   2.0.0 | latest | latest
ansible.utils                |   6.0.0 | latest | latest
community.general            |  11.0.0 | latest | latest
community.crypto             |   3.0.0 | latest | latest
community.sap_libs           |   1.4.2 | latest | dev
community.sap_operations     |   1.0.0 | latest | dev
community.sap_install        |   1.6.0 | latest | dev
community.sap_launchpad      |   1.2.1 | latest | dev
community.sap_infrastructure |   1.1.3 | latest | dev

All Images use:

- python 3.12.x
- ansible-core 2.17.x

## TODO

1. add ppcle platform
2. add suse leap as base image

You can use the execution_environment*.yml files to create your own execution environments
Read [the developer documentation](DEVELOPER.md) for details
