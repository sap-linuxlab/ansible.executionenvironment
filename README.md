# Execution Enviroments

This repository maintains the configuration to produce reproducible ansible execution environments, which can be used for testing, e.g with ansible-navigator or directly

It is planned to create exeution environments with supported ansible versions, python versions on SUSE Leap and Centos

## Requirememts
you need a working podman installation on MacOS, or Linux x86_64.
use

## Use with ansible-navigator

## Use with ansible-playbook

```bash
podman run --name sap-ee -v ${yourworkdir}:/runner:Z -ti ghcr.io/sap-linuxlab/sap-ee:stable
ansible --version
```

## Maintained images

ghcr.io/sap-linuxlab/sap-ee:stable

## TODO

1. add ppcle platform
2. add suse leap as base image



# Create MultiArch Build environment for consistent testing

## Overview

The goal of this repository is to create execution environments for all supported platforms for the community collections.
The resulting contaners can the be used for development and testing.
This repository should help to provide recipe to create containers that can be used in production.

## Requirements

To create your execution environment you need a working podman installation on you rbuild host.

## Run your development container

The easiest way to create a build environment is to use the community ansible build environment.

1. Clone this repository to your local filesystem

   ```bash
   git clone https://github.com/sap-linuxlab/ansible.executionenvironment
   ```

2. Change to the root of the cloned repo and remember the path

   ```bash
   cd ansible.executionenvironment
   ee_dir=$(pwd)
   ```

3. Start the build environment

   ```bash
   podman run --privileged --name ansible_dev_arm -ti -v ${ee_dir}:/workdir ghcr.io/ansible/community-ansible-dev-tools
   ```

>[!NOTE]
> The base image used is currently only available for x86_64 and arm.
>
> The procedure has only been tested on MacOS yet.

## Create the execution environment

To create a SAP EE with galaxy collections only run the following command:

```bash
ansible-builder create -v3 [-f execution-environment.yml]
```

<!--
Add the following line to the created Containerfile to connect to your repo, if you host on ghcr.io:

```bash
LABEL TBD org....
```
-->

For easier copy and paste set the variable `sap_ee_container` to the name of your final container, e.g.:

```bash
sap_ee_container='ghcr.io/sap-linuxlab/sap-ee:latest'
```

This following commands creates the multiarch manifest and cross build the execution environments:

```bash
podman manifest create ${sap_ee_container}
podman build --platform linux/arm64 --layers=false --manifest ${sap_ee_container} --tag sap_ee_arm64 -f context/Containerfile context
podman build --platform linux/amd64 --layers=false --manifest ${sap_ee_container} --tag sap_ee_amd64 -f context/Containerfile context
podman build --platform linux/ppc64le --layers=false --manifest ${sap_ee_container} --tag sap_ee_ppc64le -f context/Containerfile context
```

After building check the manifest

```bash
podman manifest inspect ${sap_ee_container} | grep arch
```

Example Output:

```json
{
    "schemaVersion": 2,
    "mediaType": "application/vnd.oci.image.index.v1+json",
    "manifests": [
        {
            "mediaType": "application/vnd.oci.image.manifest.v1+json",
            "size": 913,
            "digest": "sha256:35786bff9b3a96e5fa18ebd368623886d235015317ae27c7427671e5bf8da6d0",
            "platform": {
                "architecture": "amd64",
                "os": "linux"
            }
        },
        {
            "mediaType": "application/vnd.oci.image.manifest.v1+json",
            "size": 913,
            "digest": "sha256:d485c5c2ac5ed42d5248af1274f7c04b414993c3e10ec8dc2aec899c4cab1fe6",
            "platform": {
                "architecture": "arm64",
                "os": "linux"
            }
        }
    ]
}
```

Now login to the registry and upload to the multiarch containerfile, e.g.

```bash
podman login
podman manifest push ${sap_ee_container}
```

For the podman login command use your github username with a personal access token.

>[!NOTE]
> *Known Bug:* When building on Apple Silcon the images are all get the variant v8 detected in the images.
> It's not annotated in the manifest or image, but when executing such an image you will get the error message:
> `WARNING: image platform (linux/amd64/v8) does not match the expected platform (linux/amd64)`
> It can be safely ignored

# Changes for building supported EE for RHAAP

If you want to add supported Automation Hub content, get your Automation Hub token from [here](https://console.redhat.com/ansible/automation-hub/token) and export it in the environment variable `ANSIBLE_GALAXY_SERVER_RH_CERTIFIED_REPO_TOKEN`, login to `registry.redhat.io` with your RedHat credentials and run the following commands:

```bash
export ANSIBLE_GALAXY_SERVER_RH_CERTIFIED_REPO_TOKEN=_your token_
podman login registry.redhat.io
ansible-builder build -v 3 \
  --tag myregistry/sap-rh-ee:version \
  --build-arg ANSIBLE_GALAXY_SERVER_RH_CERTIFIED_REPO_TOKEN \
  -f execution-environment-rh.yml
```


> [!NOTE]
> the power base image awx-ee is not available publically. The RHEL version needs extra packages

# TODO

- create containers based on centos-stream base image and suse-leap
- create ppcle64 version in multiarch
- create pipeline jobs to create weekly, and stable on demand
  (when version list is updated on push)
