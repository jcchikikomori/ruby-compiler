# Ruby Builder for rbenv

Hassle-free Ruby builder using Virtualization for rbenv.

## Motive

My goal is to spare users the pain of setting up legacy Ruby on Rails projects, especially on Apple Silicon (M1 and later), Arch Linux, and newer Ubuntu releases.

The best thing on this one is, it can install onto your `rbenv`!

Suck on that, GCC 14!

## Requirements

- [Homebrew](https://brew.sh) - Custom installation is not supported!
- Docker or Podman (OSS) running on Ubuntu
- [rbenv](https://github.com/rbenv/rbenv) - Ruby Version Manager

## How to use

### Build & install Ruby

Just execute `./build.sh`.

#### Currently supported versions

- 2.5.0 to 2.7.x
  - Uses the Dockerfile specialized for ruby 2.5, using Ubuntu 20.04
- 3.1.x to 3.4.x
  - Uses the Dockerfile specialized for ruby 3.1, using Ubuntu 22.04

### TODOs

- [x] Dynamic script to install any releases of Ruby.
- [x] Linter for shell scripts.
- [x] Own pre-commit config for shell scripting.
- [ ] Arch Linux support or any Linux distro that uses rolling release.
- [ ] ARM support (for Apple Silicon or RPi).
- [ ] Support older versions of ruby.
- [ ] Support modern versions of ruby.
