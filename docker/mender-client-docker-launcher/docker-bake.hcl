// Expected to be used with https://github.com/rcwbr/dockerfile-partials/blob/main/github-cache-bake.hcl
// For example, docker buildx bake -f github-cache-bake.hcl -f cwd://docker-bake.hcl https://github.com/rcwbr/dockerfile-partials.git#0.10.0

target "default" {
  dockerfile = "cwd://Dockerfile"
  contexts = {
    base_context = "docker-image://docker:27.3.1-cli"
  }
}
