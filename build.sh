#!/bin/bash

BUILDS_DIR="builds"
mkdir -p $BUILDS_DIR

# If first argument is given, use it as VERSION, else prompt
if [ -n "$1" ]; then
    VERSION="$1"
    NONINTERACTIVE=1
else
    read -p "Enter the Ruby version you want to build (e.g., 2.5.8): " VERSION
    NONINTERACTIVE=0
fi

MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f2)
# Tentative fix for version 3: Use 3.1 docker directory for Ruby 3.1.x through 3.4.x
if [ "$MAJOR" = "3" ] && [ "$MINOR" -ge 1 ] && [ "$MINOR" -le 4 ]; then
    DOCKER_DIR="3.1"
# Tentative fix for version 2: Use 2.5 docker directory for Ruby 2.5.x through 2.7.x
elif [ "$MAJOR" = "2" ] && [ "$MINOR" -ge 5 ] && [ "$MINOR" -le 7 ]; then
    DOCKER_DIR="2.5"
else
    DOCKER_DIR="$MAJOR.$MINOR"
fi
DOCKERFILE="$DOCKER_DIR/Dockerfile"

if [ ! -d "$DOCKER_DIR" ] || [ ! -f "$DOCKERFILE" ]; then
    echo "Directory $DOCKER_DIR or Dockerfile $DOCKERFILE does not exist."
    exit 1
fi

COMMAND=$(command -v docker) || COMMAND=$(command -v podman)
if [ -z "$COMMAND" ]; then
    echo "Docker or Podman is required to run this script."
    exit 1
fi

# Building
$COMMAND build -t ruby-builder \
    --build-arg USERNAME=$(whoami) \
    --build-arg USER_UID=1001 \
    --build-arg USER_GID=1001 \
    --build-arg VERSION=$VERSION $DOCKER_DIR/. \
    --build-arg SPECIFIC_VERSION=$VERSION \
    --build-arg MAJOR_MINOR=$MAJOR.$MINOR
rm -f $BUILDS_DIR/ruby-$VERSION.tar.gz
$COMMAND run --rm ruby-builder cat /ruby-$VERSION.tar.gz > $BUILDS_DIR/ruby-$VERSION.tar.gz

# Installing
if [ "$NONINTERACTIVE" -eq 1 ]; then
    # If second argument is 'install', auto-install
    if [ "$2" == "install" ]; then
        echo "Installing ruby $VERSION..."
        mkdir -p ~/.rbenv/versions/$VERSION
        tar -xzf $BUILDS_DIR/ruby-$VERSION.tar.gz -C ~/.rbenv/versions
    else
        echo "Skipping ruby $VERSION installation (non-interactive mode)."
    fi
else
    echo "Do you want to install ruby $VERSION to your rbenv? (y/n)"
    read INSTALL_RUBY
    if [ "$INSTALL_RUBY" == "y" ]; then
        echo "Installing ruby $VERSION..."
        mkdir -p ~/.rbenv/versions/$VERSION
        tar -xzf $BUILDS_DIR/ruby-$VERSION.tar.gz -C ~/.rbenv/versions
    else
        echo "Skipping ruby $VERSION installation."
    fi
fi
echo "Build process completed. The tarball is located at $BUILDS_DIR/ruby-$VERSION.tar.gz"
