# Build your own customized MultiArch Build environment for consistent testing

If you just want to use the maintained execution environments you can stop reading here.
Continue reading if you want to create your own customized execution environments.

## Run your development container

The easiest way to create a build environment is to use the community ansible build environment.
If you do not want to use that, feel free to create your own build environment.

1. Clone this repository to your local filesystem

   ```bash
   git clone https://github.com/sap-linuxlab/ansible.executionenvironment
   ```

2. Change to the root of the cloned repo and remember the path

   ```bash
   cd ansible.executionenvironment
   export ee_dir=$(pwd)
   ```

3. Start the build environment

   ```bash
   podman run --privileged --name ansible_dev -ti -v ${ee_dir}:/workdir ghcr.io/ansible/community-ansible-dev-tools
   ```

## Create the execution environment

To create a SAP EE with galaxy collections only run the following command:

```bash
ansible-builder create -v3 [-f execution-environment.yml]
```

<!--
Add the following line to the created Containerfile to connect to your repo, if you host on ghcr.io and do not create the image in a workflow:

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

## Cleanup-Workflow (GHCR)

Der Workflow `.github/workflows/cleanup-old-containers.yml` löscht alte Container-Images (z. B. `sap-ee:dev*`) aus dem GitHub Container Registry der Organisation. Mit dem temporären `GITHUB_TOKEN` tritt der Fehler „missing field `id`“ auf; es wird ein **klassischer Personal Access Token (PAT)** benötigt.

### Token anlegen (einmalig)

1. **PAT erstellen** (als Benutzer mit Schreibrechten auf die Packages der Organisation):
   - GitHub → dein Profil (oben rechts) → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)** → **Generate new token (classic)**.
   - Scopes: **`read:packages`** und **`delete:packages`** anhaken.
   - Unter „Organization access“ die gewünschte Organisation (z. B. `sap-linuxlab`) auf **Grant** setzen, damit der Token auf die Org-Packages zugreifen darf.
   - Token erzeugen und den Wert sicher kopieren (nur einmal sichtbar).

2. **Secret im Repository oder in der Organisation ablegen:**
   - **Variante A – nur dieses Repo:** Repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**. Name: `GHCR_CLEANUP_TOKEN`, Value: der PAT.
   - **Variante B – mehrere Repos:** Organisation → **Settings** → **Secrets and variables** → **Actions** → **New organization secret**. Name: `GHCR_CLEANUP_TOKEN`, Value: der PAT. Zugriff auf „Repository access“ beschränken (z. B. nur dieses Repo), wenn gewünscht.

Der Workflow nutzt `account: ${{ github.repository_owner }}`, also den Organisationsnamen – bei Repos unter einer Organisation ist keine weitere Anpassung nötig.

### Alternative Action

Die offizielle Action `actions/delete-package-versions` funktioniert mit `GITHUB_TOKEN`, unterstützt für Container-Packages aber **keine Tag-Muster** (z. B. `dev*`); gefiltert wird nach API-Versionsnamen (Digest), nicht nach Tags. Für „nur `dev*`-Tags bereinigen, 5 behalten, älter als 6 Wochen löschen“ ist `snok/container-retention-policy` mit PAT die passende Wahl.

## Changes for building supported EE for RHAAP

If you want to add supported Automation Hub content, get your Automation Hub token from [Red Hat Automation Hub](https://console.redhat.com/ansible/automation-hub/token) and export it in the environment variable `ANSIBLE_GALAXY_SERVER_RH_CERTIFIED_REPO_TOKEN`, login to `registry.redhat.io` with your RedHat credentials and run the following commands:

```bash
export ANSIBLE_GALAXY_SERVER_RH_CERTIFIED_REPO_TOKEN=_your token_
podman login registry.redhat.io
ansible-builder build -v 3 \
  --tag myregistry/sap-rh-ee:version \
  --build-arg ANSIBLE_GALAXY_SERVER_RH_CERTIFIED_REPO_TOKEN \
  -f execution-environment-rh.yml
```
