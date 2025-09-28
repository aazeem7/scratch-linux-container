#!/bin/bash
set -euo pipefail

# Variables
WORKDIR="$HOME/scratch-linux"
ROOTFS="$WORKDIR/rootfs"
MUSL_VERSION="1.2.4"
BASH_VERSION="5.2"
COREUTILS_VERSION="9.3"
IMAGE_NAME="scratch-linux"

mkdir -p "$ROOTFS"

echo "==> Installing build dependencies"
apt update
apt install -y build-essential wget curl bison gawk texinfo flex xz-utils libtool \
    m4 automake autoconf pkg-config libncurses-dev zlib1g-dev

cd "$WORKDIR"

# Download sources
echo "==> Downloading sources..."
wget -c "https://musl.libc.org/releases/musl-$MUSL_VERSION.tar.gz"
wget -c "https://ftp.gnu.org/gnu/bash/bash-$BASH_VERSION.tar.gz"
wget -c "https://ftp.gnu.org/gnu/coreutils/coreutils-$COREUTILS_VERSION.tar.gz"

# Extract
echo "==> Extracting sources..."
tar xf "musl-$MUSL_VERSION.tar.gz"
tar xf "bash-$BASH_VERSION.tar.gz"
tar xf "coreutils-$COREUTILS_VERSION.tar.gz"

# Build musl libc
echo "==> Building musl libc..."
cd "$WORKDIR/musl-$MUSL_VERSION"
./configure --prefix="$ROOTFS"
make -j"$(nproc)"
make install

# Build bash
echo "==> Building bash..."
cd "$WORKDIR/bash-$BASH_VERSION"
./configure --prefix="$ROOTFS" --without-bash-malloc --disable-nls --disable-readline LDFLAGS="-static"
make -j"$(nproc)"
make install

# Build coreutils
echo "==> Building coreutils..."
cd "$WORKDIR/coreutils-$COREUTILS_VERSION"
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix="$ROOTFS" LDFLAGS="-static"
make -j"$(nproc)"
make install

# Create minimal necessary directories
echo "==> Creating directory structure..."
mkdir -p "$ROOTFS"/{bin,lib,lib64,etc,usr,tmp,root}

# Fix musl symlink for dynamic loader (adjust if needed)
echo "==> Creating ld-musl.so symlink..."
if [ -f "$ROOTFS/lib/ld-musl-x86_64.so.1" ]; then
  ln -sf lib/ld-musl-x86_64.so.1 "$ROOTFS/lib64/ld-linux-x86-64.so.2"
fi

# Add minimal passwd and group files
echo "==> Creating /etc/passwd and /etc/group..."
cat > "$ROOTFS/etc/passwd" <<EOF
root:x:0:0:root:/root:/bin/bash
EOF

cat > "$ROOTFS/etc/group" <<EOF
root:x:0:
EOF

cat > "$ROOTFS/root/.bashrc" <<EOF
export PS1='\u:\w\$ '
EOF


# Tar the rootfs
echo "==> Creating rootfs tarball..."
cd "$ROOTFS"
tar --numeric-owner -czf "$WORKDIR/rootfs.tar.gz" .

