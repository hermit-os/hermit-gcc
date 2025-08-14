target "docker-metadata-action" {}

target "hermit-gcc" {
  matrix = {
    item = [
      {
        arch = "aarch64"
        rust_target = "aarch64-unknown-hermit"
      },
      {
        arch = "riscv64"
        rust_target = "riscv64gc-unknown-hermit"
      },
      {
        arch = "x86_64"
        rust_target = "x86_64-unknown-hermit"
      }
    ]
  }
  inherits = ["docker-metadata-action"]
  name = "hermit-gcc-${item.arch}"
  context = "."
  dockerfile = "Dockerfile"
  tags = ["ghcr.io/hermit-os/hermit-gcc:${item.arch}-dev"]
  args = {
    ARCH = item.arch
    RUST_TARGET = item.rust_target
  }
}
