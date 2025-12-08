// Expected to be used with https://github.com/rcwbr/dockerfile-partials/blob/main/github-cache-bake.hcl
// For example, docker buildx bake -f github-cache-bake.hcl -f cwd://vars.hcl -f cwd://mender-client-docker/docker-bake.hcl https://github.com/rcwbr/dockerfile-partials.git#0.10.0

target "docker-client" {
  context    = "https://github.com/rcwbr/dockerfile_partials.git#0.10.0"
  dockerfile = "docker-client/Dockerfile"
  platforms  = platforms
  contexts = {
    base_context = "docker-image://ubuntu:24.04"
    docker_image = "docker-image://docker:27.3.1-cli"
  }

  // Adapted from https://github.com/rcwbr/dockerfile-partials/blob/main/github-cache-bake.hcl
  cache-from = [
    // Always pull cache from main
    "type=registry,ref=${IMAGE_REF}-cache-docker-client:main",
    "type=registry,ref=${IMAGE_REF}-cache-docker-client:${VERSION}"
  ]
  cache-to = [
    "type=registry,rewrite-timestamp=true,mode=max,ref=${IMAGE_REF}-cache-docker-client:${VERSION}"
  ]
  output = []
}

target "default" {
  context    = "cwd://mender-client-docker"
  dockerfile = "cwd://mender-client-docker/Dockerfile"
  platforms  = platforms
  contexts = {
    base_context = "target:docker-client"
  }
}
