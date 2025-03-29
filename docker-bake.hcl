target "docker-metadata-action" {}

target "hermit-gcc" {
  matrix = {
    arch = ["x86_64"]
  }
  inherits = ["docker-metadata-action"]
  name = "hermit-gcc-${arch}"
  context = "."
  dockerfile = "Dockerfile"
  tags = ["ghcr.io/hermit-os/hermit-gcc:${arch}-dev"]
  args = {
    ARCH = arch
  }
}
