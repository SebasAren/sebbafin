#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# install keyd for keybinding changes
dnf5 -y copr enable alternateved/keyd
dnf5 -y install keyd
dnf5 -y copr disable alternateved/keyd

# install ghostty terminal emulator (native GPU-accelerated, pi image support)
dnf5 -y copr enable alternateved/ghostty
dnf5 -y install ghostty
dnf5 -y copr disable alternateved/ghostty

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

### Build tmux from source with Kitty Graphics Protocol support
# Fedora ships tmux 3.5a which lacks --enable-kitty-images.
# tmux 3.6a+ supports KGP natively for inline images in Ghostty.
# Remove the system tmux first to avoid file conflicts.
dnf5 -y remove tmux

# Install build dependencies
dnf5 -y install gcc make libevent-devel ncurses-devel bison pkgconf utf8proc-devel

# Download and build tmux 3.6a
TMUX_VERSION="3.6a"
curl -L "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" -o /tmp/tmux.tar.gz
tar -xzf /tmp/tmux.tar.gz -C /tmp
cd "/tmp/tmux-${TMUX_VERSION}"

./configure \
    --prefix=/usr \
    --enable-kitty-images \
    --enable-sixel \
    --enable-utf8proc \
    --sysconfdir=/etc

make -j"$(nproc)"
make install

# Clean up build artifacts and dependencies
cd /
rm -rf /tmp/tmux-* /tmp/tmux.tar.gz
dnf5 -y remove gcc make libevent-devel ncurses-devel bison utf8proc-devel
dnf5 -y install utf8proc

#### Example for enabling a System Unit File

# enable keyd
systemctl enable keyd
