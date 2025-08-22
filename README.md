# mender-client-docker<a name="mender-client-docker"></a>

`mender-client-docker` enables management of containerized applications on Docker-enabled IoT
devices via the [Mender](https://docs.mender.io/) client, without additional host requirements.

<!-- mdformat-toc start --slug=github --maxlevel=6 --minlevel=1 -->

- [mender-client-docker](#mender-client-docker)
  - [Usage](#usage)
    - [`mender-client-docker-launcher` usage](#mender-client-docker-launcher-usage)
      - [`mender-client-docker-launcher` inputs](#mender-client-docker-launcher-inputs)
    - [`mender-client-docker` usage](#mender-client-docker-usage)
- [Contributing](#contributing)
  - [Build the image](#build-the-image)
  - [Test the image](#test-the-image)
    - [devcontainer](#devcontainer)
      - [devcontainer basic usage](#devcontainer-basic-usage)
      - [devcontainer Codespaces usage](#devcontainer-codespaces-usage)
      - [devcontainer pre-commit usage](#devcontainer-pre-commit-usage)
    - [CI/CD](#cicd)
    - [Settings](#settings)

<!-- mdformat-toc end -->

## Usage<a name="usage"></a>

The core Mender client functionality is provided by the `mender-client-docker` image. The
`mender-client-docker-launcher` image offers a convenience layer to manage setup and bringup of a
`mender-client-docker` container on a system, and is the recommended pattern.

The `mender-client-docker` pattern requires a `TENANT_TOKEN` variable to
[authenticate against the Mender host](https://docs.mender.io/client-installation/install-with-debian-package#configure-the-mender-client).
The `mender-client-docker-launcher` can optionally pass the `TENANT_TOKEN` through, or can retrieve
a value from the Mender API using a personal access token `MENDER_PAT` (recommended).

### `mender-client-docker-launcher` usage<a name="mender-client-docker-launcher-usage"></a>

Basic usage:

```bash
export MENDER_PAT=<Mender personal access token>
docker run \
  --rm \
  --name mender-client-docker-launcher \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e MENDER_PAT \
  -e DEVICE_TYPE=<your device type> \
  ghcr.io/rcwbr/mender-client-docker-launcher:0.3.0
```

#### `mender-client-docker-launcher` inputs<a name="mender-client-docker-launcher-inputs"></a>

The following environment variables configure the `mender-client-docker-launcher`:

| Variable       | Default                    | Effect                                                                                                      |
| -------------- | -------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `MENDER_HOST`  | `https://hosted.mender.io` | The URL of the Mender server instance against which to authenticate.                                        |
| `MENDER_PAT`   | N/A                        | If provided, this is the access token used to authenticate to the Mender API and retrieve the tenant token. |
| `TENANT_TOKEN` | N/A                        | If provided, this is the tenant token directly. Precludes the use of `MENDER_PAT`.                          |

### `mender-client-docker` usage<a name="mender-client-docker-usage"></a>

:warning: Requires [Docker compose](https://docs.docker.com/compose/) on the host system.

Prepare a Docker compose file for the setup and client containers:

```yaml
services:
  mender-client-setup:
    image: ghcr.io/rcwbr/mender-client-docker:0.3.0
    container_name: mender-client-setup
    environment:
      DEVICE_TYPE: ${DEVICE_TYPE}
      TENANT_TOKEN: ${TENANT_TOKEN}
    entrypoint: /setup-entrypoint
    volumes:
      - mender-client-config:/etc/mender
  mender-client:
    image: ghcr.io/rcwbr/mender-client-docker:0.3.0
    container_name: mender-client
    volumes:
      - mender-client-config:/etc/mender
      - mender-client-data:/var/lib/mender
    restart: always
    depends_on:
      mender-client-setup:
        condition: service_completed_successfully

volumes:
  mender-client-config:
  mender-client-data:
```

Launch the compose specification:

```bash
export TENANT_TOKEN=<Mender org token>
docker compose up -d
```

# Contributing<a name="contributing"></a>

## Build the image<a name="build-the-image"></a>

Configure a compatible Docker Buildx builder:

```bash
docker builder create --use --bootstrap --driver docker-container
```

Build the image:

```bash
cd docker/mender-client-docker
IMAGE_NAME=mender-client-docker REGISTRY=ghcr.io/rcwbr docker buildx bake -f github-cache-bake.hcl -f cwd://docker-bake.hcl https://github.com/rcwbr/dockerfile-partials.git#0.10.0
```

## Test the image<a name="test-the-image"></a>

Start the container:

```bash
cd test
export TENANT_TOKEN=<your Mender org token>
./test-launch
```

To update the test container to a newly build image without reconfiguring using the TENANT_TOKEN:

```bash
cd test
./test-updated-image
```

### devcontainer<a name="devcontainer"></a>

This repo contains a [devcontainer definition](https://containers.dev/) in the `.devcontainer`
folder. It leverages the
[devcontainer cache build tool](https://github.com/rcwbr/devcontainer-cache-build) and
[layers defined in the dockerfile-partials repo](https://github.com/rcwbr/dockerfile-partials).

#### devcontainer basic usage<a name="devcontainer-basic-usage"></a>

The [devcontainer cache build tool](https://github.com/rcwbr/devcontainer-cache-build) requires
[authentication to the GitHub container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry).

#### devcontainer Codespaces usage<a name="devcontainer-codespaces-usage"></a>

For use with Codespaces, the `*_CONTAINER_REGISTRY_*` GHCR access credentials must be stored as
Codespaces secrets (see
[instructions](https://github.com/rcwbr/devcontainer-cache-build/?tab=readme-ov-file#initialize-script-github-container-registry-setup)),
as must values for `USER`, and `UID` (see
[useradd Codespaces usage](https://github.com/rcwbr/dockerfile-partials/blob/main/README.md#useradd-codespaces-usage)).

#### devcontainer pre-commit usage<a name="devcontainer-pre-commit-usage"></a>

By default, the devcontainer configures [pre-commit](https://pre-commit.com/) hooks in the
repository to ensure commits pass basic testing. This includes enforcing
[conventional commit messages](https://www.conventionalcommits.org/en/v1.0.0/) as the standard for
this repository, via [commitlint](https://github.com/conventional-changelog/commitlint).

### CI/CD<a name="cicd"></a>

This repo uses the [release-it-gh-workflow](https://github.com/rcwbr/release-it-gh-workflow), with
the file-bumper image defined as its automation.

It leverages the
[devcontainer-cache-build workflow](https://github.com/rcwbr/devcontainer-cache-build/blob/main/.github/workflows/devcontainer-cache-build.yaml)
to pre-generate devcontainer images, which are also used for the linting enforcement
[pre-commit workflow](https://github.com/rcwbr/dockerfile-partials/blob/main/.github/workflows/pre-commit.yaml).

### Settings<a name="settings"></a>

The GitHub repo settings for this repo are defined as code using the
[Probot settings GitHub App](https://probot.github.io/apps/settings/). Settings values are defined
in the `.github/settings.yml` file. Enabling automation of settings via this file requires
installing the app.

The settings applied are as recommended in the
[release-it-gh-workflow usage](https://github.com/rcwbr/release-it-gh-workflow/blob/4dea4eaf328b60f92dab1b5bd2a63daefa85404b/README.md?plain=1#L58),
including tag and branch protections, GitHub App and environment authentication, and required
checks.
